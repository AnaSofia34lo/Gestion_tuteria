import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_tutorias/core/reglas_tutoria.dart';
import 'package:gestion_tutorias/local/app_database.dart';
import 'package:gestion_tutorias/local/inscripcion_local_data_source.dart';
import 'package:gestion_tutorias/models/inscripcion.dart';
import 'package:gestion_tutorias/models/sesion.dart';
import 'package:gestion_tutorias/remote/inscripcion_remote_data_source.dart';
import 'package:gestion_tutorias/repositories/inscripcion_repository.dart';

final ahora = DateTime(2026, 11, 5, 9, 30);

/// Simula Firestore: confirmar lee la sesión y escribe inscripción + contador
/// en un solo paso, como haría una transacción.
class FakeRemote implements InscripcionRemoteDataSource {
  bool sinConexion = false;
  final sesiones = <String, Sesion>{};
  final inscripciones = <String, Inscripcion>{};
  int envios = 0;

  @override
  Future<Sesion> obtenerSesion(String sesionId) async => sesiones[sesionId]!;

  @override
  Future<EstadoInscripcion> confirmar(Inscripcion inscripcion) async {
    envios++;
    if (sinConexion) throw const SocketException('offline');
    // Reintento de algo ya confirmado: idempotente, no consume otro cupo.
    final existente = inscripciones[inscripcion.id];
    if (existente != null) return existente.estado;

    final actualizada = ReglasTutoria.confirmarCupo(
      sesiones[inscripcion.sesionId]!,
      ahora: ahora,
    );
    sesiones[actualizada.id] = actualizada;
    inscripciones[inscripcion.id] = inscripcion.copyWith(
      estado: EstadoInscripcion.confirmada,
    );
    return EstadoInscripcion.confirmada;
  }
}

Sesion sesion({int capacidad = 3, int ocupados = 0}) => Sesion(
  id: 's1',
  asignaturaId: '8',
  tutorUid: 'tutor-1',
  inicio: DateTime(2026, 11, 6, 10),
  capacidad: capacidad,
  cuposOcupados: ocupados,
  estado: EstadoSesion.publicada,
);

void main() {
  late AppDatabase db;
  late InscripcionLocalDataSource local;
  late FakeRemote remote;

  InscripcionRepository repo({bool conRemoto = true}) => InscripcionRepository(
    local: local,
    remote: conRemoto ? remote : null,
    reloj: () => ahora,
  );

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    local = InscripcionLocalDataSource(db);
    remote = FakeRemote()..sesiones['s1'] = sesion();
  });
  tearDown(() => db.close());

  test('sin conexión la solicitud queda guardada como pendiente', () async {
    final r = repo(conRemoto: false);
    final creada = await r.solicitar(sesion: sesion(), estudianteUid: 'e1');

    final mias = await r.misInscripciones('e1');
    expect(mias.single.id, creada.id);
    expect(mias.single.estado, EstadoInscripcion.solicitada);
    expect(mias.single.pendingSync, isTrue);

    final resultado = await r.sincronizarPendientes('e1');
    expect(resultado.pendientes, 1);
  });

  test('no permite solicitar dos veces la misma sesión', () async {
    final r = repo(conRemoto: false);
    await r.solicitar(sesion: sesion(), estudianteUid: 'e1');
    await expectLater(
      r.solicitar(sesion: sesion(), estudianteUid: 'e1'),
      throwsA(isA<ReglaNegocioException>()),
    );
    expect(await r.misInscripciones('e1'), hasLength(1));
  });

  test(
    'fallo temporal conserva el pendiente y el reintento no duplica',
    () async {
      final r = repo();
      final creada = await r.solicitar(sesion: sesion(), estudianteUid: 'e1');

      remote.sinConexion = true;
      var resultado = await r.sincronizarPendientes('e1');
      expect(resultado.pendientes, 1);
      final pendiente = (await local.porId(creada.id))!;
      expect(pendiente.pendingSync, isTrue);
      expect(pendiente.ultimoError, isNotNull);

      remote.sinConexion = false;
      resultado = await r.sincronizarPendientes('e1');
      expect(resultado.confirmadas, 1);
      expect(
        (await local.porId(creada.id))!.estado,
        EstadoInscripcion.confirmada,
      );
      expect(remote.inscripciones, hasLength(1));
      expect(remote.sesiones['s1']!.cuposOcupados, 1);

      // Nada pendiente: no se vuelve a enviar.
      final enviosAntes = remote.envios;
      await r.sincronizarPendientes('e1');
      expect(remote.envios, enviosAntes);
    },
  );

  test('escenario 1: dos estudiantes por el último cupo', () async {
    remote.sesiones['s1'] = sesion(capacidad: 2, ocupados: 1);
    final r = repo();
    final a = await r.solicitar(sesion: sesion(), estudianteUid: 'e1');
    final b = await r.solicitar(sesion: sesion(), estudianteUid: 'e2');

    await r.sincronizarPendientes('e1');
    final resultadoB = await r.sincronizarPendientes('e2');

    expect((await local.porId(a.id))!.estado, EstadoInscripcion.confirmada);
    final rechazada = (await local.porId(b.id))!;
    expect(rechazada.estado, EstadoInscripcion.rechazada);
    expect(rechazada.pendingSync, isFalse);
    expect(rechazada.ultimoError, 'No quedan cupos en esta sesión');
    expect(resultadoB.rechazadas, 1);
    expect(remote.sesiones['s1']!.cuposDisponibles, 0);

    // Un rechazo definitivo no se reenvía indefinidamente.
    final enviosAntes = remote.envios;
    await r.sincronizarPendientes('e2');
    expect(remote.envios, enviosAntes);
  });

  test('solo sincroniza pendientes de la cuenta actual', () async {
    final r = repo();
    await r.solicitar(sesion: sesion(), estudianteUid: 'e1');
    await r.solicitar(sesion: sesion(), estudianteUid: 'e2');

    await r.sincronizarPendientes('e1');

    expect(remote.inscripciones.values.map((i) => i.estudianteUid), ['e1']);
    expect((await r.misInscripciones('e2')).single.pendingSync, isTrue);
    expect(await r.misInscripciones('otro'), isEmpty);
  });

  test('confirmación antigua no pisa una edición local más reciente', () async {
    final r = repo(conRemoto: false);
    final enviada = await r.solicitar(sesion: sesion(), estudianteUid: 'e1');
    await local.guardar(
      enviada.copyWith(
        estado: EstadoInscripcion.cancelada,
        updatedAt: ahora.add(const Duration(minutes: 1)),
      ),
    );

    final aplicada = await local.aplicarConfirmacion(
      enviada,
      EstadoInscripcion.confirmada,
    );

    expect(aplicada, isFalse);
    final actual = (await local.porId(enviada.id))!;
    expect(actual.estado, EstadoInscripcion.cancelada);
    expect(actual.pendingSync, isTrue);
  });

  test('SQLite conserva la solicitud después de cerrar y reabrir', () async {
    final dir = await Directory.systemTemp.createTemp('tutorias-test-');
    final file = File('${dir.path}/tutorias.sqlite');
    final primera = AppDatabase.forTesting(NativeDatabase(file));
    late Inscripcion creada;
    try {
      creada = await InscripcionRepository(
        local: InscripcionLocalDataSource(primera),
        reloj: () => ahora,
      ).solicitar(sesion: sesion(), estudianteUid: 'e1');
    } finally {
      await primera.close();
    }

    final reabierta = AppDatabase.forTesting(NativeDatabase(file));
    try {
      final guardada = await InscripcionLocalDataSource(
        reabierta,
      ).porId(creada.id);
      expect(guardada!.estado, EstadoInscripcion.solicitada);
      expect(guardada.pendingSync, isTrue);
    } finally {
      await reabierta.close();
      await dir.delete(recursive: true);
    }
  });
}
