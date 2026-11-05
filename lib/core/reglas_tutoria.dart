import 'package:gestion_tutorias/models/inscripcion.dart';
import 'package:gestion_tutorias/models/sesion.dart';

/// Rechazo de una regla del dominio. Se muestra en la interfaz y no se
/// reporta como fallo inesperado.
class ReglaNegocioException implements Exception {
  final String message;
  const ReglaNegocioException(this.message);

  @override
  String toString() => message;
}

/// Reglas obligatorias del caso G61-5. Son funciones puras: reciben `ahora`
/// para poder probarlas y para que el Repository las reutilice antes de
/// escribir en Drift o Firestore.
class ReglasTutoria {
  ReglasTutoria._();

  static void _transicion(EstadoSesion desde, EstadoSesion hacia) {
    if (!desde.puedePasarA(hacia)) {
      throw ReglaNegocioException(
        'No se puede pasar una sesión de ${desde.name} a ${hacia.name}',
      );
    }
  }

  /// Regla 1: solo se publica una sesión futura, con capacidad entre 1 y 10,
  /// tutor asignado y sin choque con otra sesión publicada del mismo tutor.
  static Sesion publicar(
    Sesion sesion, {
    required List<Sesion> sesionesDelTutor,
    required DateTime ahora,
  }) {
    _transicion(sesion.estado, EstadoSesion.publicada);
    if (sesion.tutorUid.trim().isEmpty) {
      throw const ReglaNegocioException('La sesión no tiene tutor asignado');
    }
    if (!sesion.inicio.isAfter(ahora)) {
      throw const ReglaNegocioException('Solo se publican sesiones futuras');
    }
    if (!sesion.esFranjaFija) {
      throw const ReglaNegocioException(
        'La sesión debe iniciar en una franja fija (hora en punto)',
      );
    }
    if (sesion.capacidad < Sesion.capacidadMinima ||
        sesion.capacidad > Sesion.capacidadMaxima) {
      throw const ReglaNegocioException(
        'La capacidad debe estar entre 1 y 10 estudiantes',
      );
    }
    final choque = sesionesDelTutor.any(
      (otra) =>
          otra.id != sesion.id &&
          otra.tutorUid == sesion.tutorUid &&
          otra.estado == EstadoSesion.publicada &&
          otra.inicio.isAtSameMomentAs(sesion.inicio),
    );
    if (choque) {
      throw const ReglaNegocioException(
        'El tutor ya tiene una sesión publicada en esa franja',
      );
    }
    return sesion.copyWith(estado: EstadoSesion.publicada);
  }

  static Sesion rechazar(Sesion sesion) {
    _transicion(sesion.estado, EstadoSesion.rechazada);
    return sesion.copyWith(estado: EstadoSesion.rechazada);
  }

  /// Regla 3 (parte local): un estudiante no puede tener dos inscripciones
  /// activas en la misma sesión. Además la sesión debe estar publicada y sin
  /// iniciar para aceptar la solicitud.
  static void validarSolicitud(
    Sesion sesion, {
    required String estudianteUid,
    required List<Inscripcion> inscripcionesDelEstudiante,
    required DateTime ahora,
  }) {
    if (sesion.estado != EstadoSesion.publicada) {
      throw const ReglaNegocioException(
        'Solo puedes inscribirte en sesiones publicadas',
      );
    }
    if (sesion.haIniciado(ahora)) {
      throw const ReglaNegocioException('La sesión ya inició');
    }
    final duplicada = inscripcionesDelEstudiante.any(
      (i) =>
          i.sesionId == sesion.id &&
          i.estudianteUid == estudianteUid &&
          i.estado.esActiva,
    );
    if (duplicada) {
      throw const ReglaNegocioException(
        'Ya tienes una inscripción activa en esta sesión',
      );
    }
  }

  /// Regla 2: no se confirma en una sesión no publicada, ya iniciada o llena.
  /// Debe evaluarse sobre el estado remoto leído dentro de la transacción.
  static Sesion confirmarCupo(Sesion sesion, {required DateTime ahora}) {
    if (sesion.estado != EstadoSesion.publicada) {
      throw const ReglaNegocioException('La sesión no está publicada');
    }
    if (sesion.haIniciado(ahora)) {
      throw const ReglaNegocioException('La sesión ya inició');
    }
    if (sesion.cuposDisponibles <= 0) {
      throw const ReglaNegocioException('No quedan cupos en esta sesión');
    }
    return sesion.copyWith(cuposOcupados: sesion.cuposOcupados + 1);
  }

  /// Regla 3: cancelar antes del inicio; si estaba confirmada libera la plaza.
  static ({Inscripcion inscripcion, Sesion sesion}) cancelar(
    Inscripcion inscripcion,
    Sesion sesion, {
    required DateTime ahora,
  }) {
    if (!inscripcion.estado.esActiva) {
      throw const ReglaNegocioException(
        'Solo se cancela una inscripción solicitada o confirmada',
      );
    }
    if (sesion.haIniciado(ahora)) {
      throw const ReglaNegocioException(
        'No se puede cancelar después del inicio de la sesión',
      );
    }
    final liberaCupo = inscripcion.estado == EstadoInscripcion.confirmada;
    return (
      inscripcion: inscripcion.copyWith(
        estado: EstadoInscripcion.cancelada,
        updatedAt: ahora,
        pendingSync: true,
      ),
      sesion: liberaCupo
          ? sesion.copyWith(cuposOcupados: sesion.cuposOcupados - 1)
          : sesion,
    );
  }

  /// Regla 4: solo el tutor de la sesión registra asistencia, después del
  /// inicio y únicamente sobre inscripciones confirmadas.
  static Inscripcion registrarAsistencia(
    Inscripcion inscripcion,
    Sesion sesion, {
    required String actorUid,
    required bool asistio,
    required DateTime ahora,
  }) {
    if (actorUid != sesion.tutorUid) {
      throw const ReglaNegocioException(
        'Solo el tutor de la sesión registra asistencia',
      );
    }
    if (!sesion.haIniciado(ahora)) {
      throw const ReglaNegocioException(
        'La asistencia se registra después del inicio',
      );
    }
    if (sesion.estado == EstadoSesion.cerrada) {
      throw const ReglaNegocioException('La sesión ya está cerrada');
    }
    if (inscripcion.estado != EstadoInscripcion.confirmada &&
        !inscripcion.estado.tieneAsistencia) {
      throw const ReglaNegocioException(
        'Solo se registra asistencia de inscripciones confirmadas',
      );
    }
    return inscripcion.copyWith(
      estado: asistio ? EstadoInscripcion.asistio : EstadoInscripcion.noAsistio,
      updatedAt: ahora,
      pendingSync: true,
    );
  }

  /// Regla 4: la coordinación cierra cuando la sesión terminó y todos los
  /// inscritos confirmados tienen resultado de asistencia.
  static Sesion cerrar(
    Sesion sesion, {
    required List<Inscripcion> inscripciones,
    required DateTime ahora,
  }) {
    _transicion(sesion.estado, EstadoSesion.cerrada);
    if (!sesion.haTerminado(ahora)) {
      throw const ReglaNegocioException(
        'La sesión se cierra cuando haya terminado',
      );
    }
    final sinResultado = inscripciones
        .where(
          (i) =>
              i.sesionId == sesion.id &&
              i.estado == EstadoInscripcion.confirmada,
        )
        .length;
    if (sinResultado > 0) {
      throw ReglaNegocioException(
        'Faltan $sinResultado inscrito(s) por registrar asistencia',
      );
    }
    return sesion.copyWith(estado: EstadoSesion.cerrada);
  }
}
