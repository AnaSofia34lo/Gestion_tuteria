import 'dart:async';

import 'package:gestion_tutorias/core/app_logger.dart';
import 'package:gestion_tutorias/core/reglas_tutoria.dart';
import 'package:gestion_tutorias/local/inscripcion_local_data_source.dart';
import 'package:gestion_tutorias/models/inscripcion.dart';
import 'package:gestion_tutorias/models/perfil.dart';
import 'package:gestion_tutorias/models/sesion.dart';
import 'package:gestion_tutorias/remote/inscripcion_remote_data_source.dart';

/// Resultado de una ronda de sincronización, para mostrarlo en la UI.
class ResultadoSync {
  final int confirmadas;
  final int rechazadas;
  final int pendientes;
  const ResultadoSync({
    this.confirmadas = 0,
    this.rechazadas = 0,
    this.pendientes = 0,
  });

  String get resumen {
    final partes = <String>[
      if (confirmadas > 0) '$confirmadas confirmada(s)',
      if (rechazadas > 0) '$rechazadas rechazada(s)',
      if (pendientes > 0) '$pendientes pendiente(s) sin conexión',
    ];
    return partes.isEmpty ? 'No hay solicitudes pendientes' : partes.join(', ');
  }
}

/// Local-first para solicitudes de inscripción:
/// 1. Valida reglas y guarda en Drift como SOLICITADA + pendingSync.
/// 2. La confirmación requiere conexión y la decide el servidor (atómica).
/// 3. Solo se marca sincronizada con respuesta remota satisfactoria.
class InscripcionRepository {
  final InscripcionLocalDataSource local;
  final InscripcionRemoteDataSource? remote;
  final Duration syncTimeout;
  final DateTime Function() reloj;
  Future<ResultadoSync>? _syncEnCurso;

  InscripcionRepository({
    required this.local,
    this.remote,
    this.syncTimeout = const Duration(seconds: 10),
    DateTime Function()? reloj,
  }) : reloj = reloj ?? DateTime.now;

  Future<List<Inscripcion>> misInscripciones(String uid) =>
      local.delEstudiante(uid);

  Stream<List<Inscripcion>> observarMisInscripciones(String uid) =>
      local.observarDelEstudiante(uid);

  /// Funciona sin conexión. Devuelve la inscripción pendiente: mostrarla no
  /// equivale a tener la plaza garantizada.
  Future<Inscripcion> solicitar({
    required Sesion sesion,
    required Perfil estudiante,
  }) async {
    if (estudiante.rol != Rol.estudiante) {
      throw const ReglaNegocioException(
        'Solo los estudiantes solicitan inscripción',
      );
    }
    final ahora = reloj();
    ReglasTutoria.validarSolicitud(
      sesion,
      estudianteUid: estudiante.uid,
      inscripcionesDelEstudiante: await local.delEstudiante(estudiante.uid),
      ahora: ahora,
    );
    final inscripcion = Inscripcion(
      id: Inscripcion.idPara(sesion.id, estudiante.uid),
      sesionId: sesion.id,
      estudianteUid: estudiante.uid,
      estudianteNombre: estudiante.nombre,
      tutorUid: sesion.tutorUid,
      estado: EstadoInscripcion.solicitada,
      updatedAt: ahora,
      asignaturaNombre: sesion.asignaturaNombre,
      inicioSesion: sesion.inicio,
    );
    await local.guardar(inscripcion);
    AppLogger.debug('Inscripción ${inscripcion.id} guardada localmente');
    return inscripcion;
  }

  /// Envía las solicitudes pendientes del usuario. Si ya hay un envío en
  /// curso, se reutiliza para no mandar la misma solicitud dos veces.
  Future<ResultadoSync> sincronizarPendientes(String uid) {
    return _syncEnCurso ??= _sincronizar(uid).whenComplete(() {
      _syncEnCurso = null;
    });
  }

  Future<ResultadoSync> _sincronizar(String uid) async {
    final remoteSource = remote;
    final pendientes = await local.pendientes(uid);
    if (remoteSource == null) {
      return ResultadoSync(pendientes: pendientes.length);
    }

    var confirmadas = 0;
    var rechazadas = 0;
    var siguenPendientes = 0;
    for (final inscripcion in pendientes) {
      try {
        final estado = await remoteSource
            .confirmar(inscripcion)
            .timeout(syncTimeout);
        final aplicada = await local.aplicarConfirmacion(inscripcion, estado);
        if (aplicada) {
          confirmadas++;
        } else {
          siguenPendientes++;
        }
      } on ReglaNegocioException catch (error) {
        // Rechazo definitivo: se conserva la evidencia y no se reenvía.
        await local.marcarRechazada(inscripcion, error.message);
        rechazadas++;
      } catch (error) {
        AppLogger.warning('Sync de inscripción pendiente: $error');
        await local.registrarFalloTemporal(
          inscripcion.id,
          'Sin confirmar. Reintenta cuando tengas conexión.',
        );
        siguenPendientes++;
      }
    }
    return ResultadoSync(
      confirmadas: confirmadas,
      rechazadas: rechazadas,
      pendientes: siguenPendientes,
    );
  }

  /// Trae lo que cambiaron otros roles (asistencia registrada por el tutor).
  /// Sin conexión se conserva lo que ya hay en Drift.
  Future<void> refrescarDesdeServidor(String uid) async {
    final remoteSource = remote;
    if (remoteSource == null) return;
    try {
      final remotas = await remoteSource
          .delEstudiante(uid)
          .timeout(syncTimeout);
      await local.fusionarRemotas(remotas);
    } catch (error) {
      AppLogger.warning('No se pudo refrescar inscripciones: $error');
    }
  }

  /// Cancelar una solicitud que nunca llegó al servidor es local. Cancelar
  /// una plaza confirmada requiere conexión porque libera el cupo en
  /// Firestore de forma atómica.
  Future<void> cancelar(Inscripcion inscripcion, {Sesion? sesion}) async {
    final ahora = reloj();
    final inicio = sesion?.inicio ?? inscripcion.inicioSesion;
    if (inicio != null && !ahora.isBefore(inicio)) {
      throw const ReglaNegocioException(
        'No se puede cancelar después del inicio de la sesión',
      );
    }
    if (inscripcion.estado == EstadoInscripcion.solicitada &&
        inscripcion.pendingSync) {
      // Si el envío está en curso, se espera para no cancelar a ciegas.
      await _syncEnCurso;
      final actual = await local.porId(inscripcion.id);
      if (actual != null &&
          actual.estado == EstadoInscripcion.solicitada &&
          actual.pendingSync) {
        await local.guardar(
          actual.copyWith(
            estado: EstadoInscripcion.cancelada,
            updatedAt: ahora,
            pendingSync: false,
            limpiarError: true,
          ),
        );
        return;
      }
      inscripcion = actual ?? inscripcion;
    }
    if (inscripcion.estado != EstadoInscripcion.confirmada) {
      throw const ReglaNegocioException(
        'Solo se cancela una inscripción solicitada o confirmada',
      );
    }
    final remoteSource = remote;
    if (remoteSource == null) {
      throw const ReglaNegocioException(
        'Necesitas conexión para liberar una plaza confirmada',
      );
    }
    try {
      await remoteSource.cancelar(inscripcion).timeout(syncTimeout);
    } on ReglaNegocioException {
      rethrow;
    } catch (error) {
      AppLogger.warning('Cancelación sin conexión: $error');
      throw const ReglaNegocioException(
        'Necesitas conexión para liberar una plaza confirmada',
      );
    }
    await local.guardar(
      inscripcion.copyWith(
        estado: EstadoInscripcion.cancelada,
        updatedAt: ahora,
        pendingSync: false,
        limpiarError: true,
      ),
    );
  }

  /// Quita de Drift un intento rechazado o cancelado.
  Future<void> descartar(Inscripcion inscripcion) async {
    if (inscripcion.estado.esActiva) {
      throw const ReglaNegocioException(
        'Cancela la inscripción antes de descartarla',
      );
    }
    await local.eliminar(inscripcion.id);
  }

  // ----- Tutor y coordinación -----

  Stream<List<Inscripcion>> observarInscritos(Sesion sesion) {
    final remoteSource = remote;
    if (remoteSource == null) return Stream.value(const []);
    return remoteSource.observarInscritos(sesion);
  }

  /// Regla 4: solo el tutor de la sesión, después del inicio.
  Future<void> registrarAsistencia({
    required Inscripcion inscripcion,
    required Sesion sesion,
    required Perfil tutor,
    required bool asistio,
  }) async {
    final actualizada = ReglasTutoria.registrarAsistencia(
      inscripcion,
      sesion,
      actorUid: tutor.uid,
      asistio: asistio,
      ahora: reloj(),
    );
    final remoteSource = remote;
    if (remoteSource == null) {
      throw const ReglaNegocioException('Sin conexión con el servidor');
    }
    await remoteSource.registrarAsistencia(actualizada).timeout(syncTimeout);
  }

  Future<List<Inscripcion>> inscritosDelServidor(Sesion sesion) async {
    final remoteSource = remote;
    if (remoteSource == null) {
      throw const ReglaNegocioException('Sin conexión con el servidor');
    }
    return remoteSource.inscritos(sesion).timeout(syncTimeout);
  }
}
