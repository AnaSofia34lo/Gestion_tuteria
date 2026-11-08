import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_tutorias/core/reglas_tutoria.dart';
import 'package:gestion_tutorias/models/inscripcion.dart';
import 'package:gestion_tutorias/models/sesion.dart';

final ahora = DateTime(2026, 11, 5, 9, 30);
final manana10 = DateTime(2026, 11, 6, 10);

Sesion sesion({
  String id = 's1',
  String tutor = 'tutor-1',
  DateTime? inicio,
  int capacidad = 3,
  int ocupados = 0,
  EstadoSesion estado = EstadoSesion.publicada,
}) => Sesion(
  id: id,
  asignaturaId: '8',
  tutorUid: tutor,
  inicio: inicio ?? manana10,
  capacidad: capacidad,
  cuposOcupados: ocupados,
  estado: estado,
);

Inscripcion inscripcion(
  String estudiante, {
  EstadoInscripcion estado = EstadoInscripcion.confirmada,
  String sesionId = 's1',
}) => Inscripcion(
  id: 'i-$estudiante',
  sesionId: sesionId,
  estudianteUid: estudiante,
  estado: estado,
  updatedAt: ahora,
);

Matcher rechazo(String parte) => throwsA(
  isA<ReglaNegocioException>().having(
    (e) => e.message,
    'message',
    contains(parte),
  ),
);

void main() {
  group('Estados de la sesión', () {
    test('transiciones permitidas y terminales', () {
      expect(
        EstadoSesion.propuesta.puedePasarA(EstadoSesion.publicada),
        isTrue,
      );
      expect(
        EstadoSesion.propuesta.puedePasarA(EstadoSesion.rechazada),
        isTrue,
      );
      expect(EstadoSesion.propuesta.puedePasarA(EstadoSesion.cerrada), isFalse);
      expect(EstadoSesion.rechazada.siguientes, isEmpty);
      expect(EstadoSesion.cerrada.siguientes, isEmpty);
    });

    test('no se rechaza una sesión ya publicada', () {
      expect(() => ReglasTutoria.rechazar(sesion()), rechazo('publicada'));
    });
  });

  group('Regla 1: publicar', () {
    final propuesta = sesion(estado: EstadoSesion.propuesta);

    test('publica una sesión futura válida', () {
      final publicada = ReglasTutoria.publicar(
        propuesta,
        sesionesDelTutor: const [],
        ahora: ahora,
      );
      expect(publicada.estado, EstadoSesion.publicada);
    });

    test('rechaza sesión pasada, capacidad fuera de rango o sin tutor', () {
      expect(
        () => ReglasTutoria.publicar(
          sesion(
            estado: EstadoSesion.propuesta,
            inicio: DateTime(2026, 11, 5, 8),
          ),
          sesionesDelTutor: const [],
          ahora: ahora,
        ),
        rechazo('futuras'),
      );
      for (final capacidad in [0, 11]) {
        expect(
          () => ReglasTutoria.publicar(
            sesion(estado: EstadoSesion.propuesta, capacidad: capacidad),
            sesionesDelTutor: const [],
            ahora: ahora,
          ),
          rechazo('entre 1 y 10'),
        );
      }
      expect(
        () => ReglasTutoria.publicar(
          sesion(estado: EstadoSesion.propuesta, tutor: ' '),
          sesionesDelTutor: const [],
          ahora: ahora,
        ),
        rechazo('tutor'),
      );
    });

    test('exige franja fija de hora en punto', () {
      expect(
        () => ReglasTutoria.publicar(
          sesion(
            estado: EstadoSesion.propuesta,
            inicio: DateTime(2026, 11, 6, 10, 30),
          ),
          sesionesDelTutor: const [],
          ahora: ahora,
        ),
        rechazo('franja fija'),
      );
    });

    test('un tutor no publica dos sesiones en la misma franja', () {
      expect(
        () => ReglasTutoria.publicar(
          propuesta,
          sesionesDelTutor: [sesion(id: 's0')],
          ahora: ahora,
        ),
        rechazo('en esa franja'),
      );
    });
  });

  group('Reglas 2 y 3: inscripción y cupos', () {
    test('no se solicita en sesión no publicada o ya iniciada', () {
      expect(
        () => ReglasTutoria.validarSolicitud(
          sesion(estado: EstadoSesion.propuesta),
          estudianteUid: 'e1',
          inscripcionesDelEstudiante: const [],
          ahora: ahora,
        ),
        rechazo('publicadas'),
      );
      expect(
        () => ReglasTutoria.validarSolicitud(
          sesion(),
          estudianteUid: 'e1',
          inscripcionesDelEstudiante: const [],
          ahora: manana10,
        ),
        rechazo('ya inició'),
      );
    });

    test('no permite dos inscripciones activas en la misma sesión', () {
      expect(
        () => ReglasTutoria.validarSolicitud(
          sesion(),
          estudianteUid: 'e1',
          inscripcionesDelEstudiante: [
            inscripcion('e1', estado: EstadoInscripcion.solicitada),
          ],
          ahora: ahora,
        ),
        rechazo('activa'),
      );
      // Una cancelada no bloquea volver a solicitar.
      ReglasTutoria.validarSolicitud(
        sesion(),
        estudianteUid: 'e1',
        inscripcionesDelEstudiante: [
          inscripcion('e1', estado: EstadoInscripcion.cancelada),
        ],
        ahora: ahora,
      );
    });

    test('escenario 1: dos estudiantes por el último cupo, solo uno entra', () {
      // Cada confirmación lee el estado remoto actualizado (transacción).
      var remoto = sesion(capacidad: 2, ocupados: 1);
      remoto = ReglasTutoria.confirmarCupo(remoto, ahora: ahora);
      expect(remoto.cuposDisponibles, 0);
      expect(
        () => ReglasTutoria.confirmarCupo(remoto, ahora: ahora),
        rechazo('No quedan cupos'),
      );
    });

    test('escenario 2: cancelar una confirmada libera el cupo', () {
      final llena = sesion(capacidad: 1, ocupados: 1);
      final r = ReglasTutoria.cancelar(inscripcion('e1'), llena, ahora: ahora);
      expect(r.inscripcion.estado, EstadoInscripcion.cancelada);
      expect(r.sesion.cuposDisponibles, 1);
      expect(r.inscripcion.estado.tieneAsistencia, isFalse);

      // Y la cancelada ya no puede recibir asistencia.
      expect(
        () => ReglasTutoria.registrarAsistencia(
          r.inscripcion,
          llena,
          actorUid: 'tutor-1',
          asistio: true,
          ahora: manana10,
        ),
        rechazo('confirmadas'),
      );
    });

    test('cancelar una solicitada no altera el contador', () {
      final s = sesion(ocupados: 2);
      final r = ReglasTutoria.cancelar(
        inscripcion('e1', estado: EstadoInscripcion.solicitada),
        s,
        ahora: ahora,
      );
      expect(r.sesion.cuposOcupados, 2);
    });

    test('no se cancela después del inicio', () {
      expect(
        () => ReglasTutoria.cancelar(
          inscripcion('e1'),
          sesion(),
          ahora: manana10,
        ),
        rechazo('después del inicio'),
      );
    });
  });

  group('Regla 4: asistencia y cierre', () {
    final despues = manana10.add(const Duration(minutes: 70));

    test('solo el tutor de la sesión registra asistencia y tras el inicio', () {
      expect(
        () => ReglasTutoria.registrarAsistencia(
          inscripcion('e1'),
          sesion(),
          actorUid: 'otro-tutor',
          asistio: true,
          ahora: despues,
        ),
        rechazo('Solo el tutor'),
      );
      expect(
        () => ReglasTutoria.registrarAsistencia(
          inscripcion('e1'),
          sesion(),
          actorUid: 'tutor-1',
          asistio: true,
          ahora: ahora,
        ),
        rechazo('después del inicio'),
      );
      final r = ReglasTutoria.registrarAsistencia(
        inscripcion('e1'),
        sesion(),
        actorUid: 'tutor-1',
        asistio: false,
        ahora: despues,
      );
      expect(r.estado, EstadoInscripcion.noAsistio);
    });

    test('escenario 3: cerrar con asistencia incompleta se bloquea', () {
      final inscritos = [
        inscripcion('e1', estado: EstadoInscripcion.asistio),
        inscripcion('e2'),
        inscripcion('e3', estado: EstadoInscripcion.cancelada),
      ];
      expect(
        () => ReglasTutoria.cerrar(
          sesion(estado: EstadoSesion.realizada),
          inscripciones: inscritos,
          ahora: despues,
        ),
        rechazo('Faltan 1'),
      );

      inscritos[1] = inscripcion('e2', estado: EstadoInscripcion.noAsistio);
      final cerrada = ReglasTutoria.cerrar(
        sesion(estado: EstadoSesion.realizada),
        inscripciones: inscritos,
        ahora: despues,
      );
      expect(cerrada.estado, EstadoSesion.cerrada);
    });

    test('no se cierra antes de que termine la sesión', () {
      expect(
        () => ReglasTutoria.cerrar(
          sesion(estado: EstadoSesion.realizada),
          inscripciones: const [],
          ahora: manana10.add(const Duration(minutes: 30)),
        ),
        rechazo('haya terminado'),
      );
    });
    test('no se cierra una sesión publicada: primero debe estar realizada', () {
      expect(
        () => ReglasTutoria.cerrar(
          sesion(),
          inscripciones: const [],
          ahora: despues,
        ),
        rechazo('no puede pasar a cerrada'),
      );
    });

    test('solo el tutor marca realizada y cuando termina la franja', () {
      expect(
        () => ReglasTutoria.marcarRealizada(
          sesion(),
          actorUid: 'otro',
          ahora: despues,
        ),
        rechazo('Solo el tutor'),
      );
      expect(
        () => ReglasTutoria.marcarRealizada(
          sesion(),
          actorUid: 'tutor-1',
          ahora: manana10.add(const Duration(minutes: 30)),
        ),
        rechazo('cuando termine'),
      );
      final realizada = ReglasTutoria.marcarRealizada(
        sesion(),
        actorUid: 'tutor-1',
        ahora: despues,
      );
      expect(realizada.estado, EstadoSesion.realizada);
    });
  });

  group('Propuesta del tutor', () {
    test('valida franja, capacidad y fecha antes de crearla', () {
      ReglasTutoria.validarPropuesta(
        sesion(estado: EstadoSesion.propuesta),
        ahora: ahora,
      );
      expect(
        () => ReglasTutoria.validarPropuesta(
          sesion(estado: EstadoSesion.propuesta, capacidad: 12),
          ahora: ahora,
        ),
        rechazo('entre 1 y 10'),
      );
      expect(
        () => ReglasTutoria.validarPropuesta(sesion(), ahora: ahora),
        rechazo('debe ser propuesta'),
      );
    });
  });
}
