/// Estados de una sesión: PROPUESTA → PUBLICADA → REALIZADA → CERRADA.
/// La coordinación puede pasar una PROPUESTA a RECHAZADA (terminal).
enum EstadoSesion {
  propuesta,
  publicada,
  rechazada,
  realizada,
  cerrada;

  static EstadoSesion fromName(String name) => EstadoSesion.values.firstWhere(
    (e) => e.name == name,
    orElse: () => throw FormatException('Estado de sesión desconocido: $name'),
  );

  /// Transiciones permitidas. Rechazada y cerrada son terminales.
  Set<EstadoSesion> get siguientes => switch (this) {
    EstadoSesion.propuesta => {EstadoSesion.publicada, EstadoSesion.rechazada},
    EstadoSesion.publicada => {EstadoSesion.realizada},
    EstadoSesion.realizada => {EstadoSesion.cerrada},
    EstadoSesion.rechazada || EstadoSesion.cerrada => const {},
  };

  bool puedePasarA(EstadoSesion destino) => siguientes.contains(destino);

  String get etiqueta => switch (this) {
    EstadoSesion.propuesta => 'Propuesta',
    EstadoSesion.publicada => 'Publicada',
    EstadoSesion.rechazada => 'Rechazada',
    EstadoSesion.realizada => 'Realizada',
    EstadoSesion.cerrada => 'Cerrada',
  };
}

/// Sesión de tutoría en una franja fija de una hora.
///
/// `cuposOcupados` es el contador operativo que vive en Firestore; el catálogo
/// HTTP nunca autoriza una inscripción.
class Sesion {
  static const duracion = Duration(hours: 1);
  static const capacidadMinima = 1;
  static const capacidadMaxima = 10;

  final String id;
  final String asignaturaId;
  final String asignaturaNombre;
  final String tutorUid;
  final String tutorNombre;
  final DateTime inicio;
  final int capacidad;
  final int cuposOcupados;
  final EstadoSesion estado;
  final String? motivoRechazo;

  const Sesion({
    required this.id,
    required this.asignaturaId,
    this.asignaturaNombre = '',
    required this.tutorUid,
    this.tutorNombre = '',
    required this.inicio,
    required this.capacidad,
    this.cuposOcupados = 0,
    this.estado = EstadoSesion.propuesta,
    this.motivoRechazo,
  });

  DateTime get fin => inicio.add(duracion);
  int get cuposDisponibles => capacidad - cuposOcupados;
  bool haIniciado(DateTime ahora) => !ahora.isBefore(inicio);
  bool haTerminado(DateTime ahora) => !ahora.isBefore(fin);

  /// Franja fija: empieza en punto (minuto, segundo y ms en cero).
  bool get esFranjaFija =>
      inicio.minute == 0 && inicio.second == 0 && inicio.millisecond == 0;

  /// Clave única de la franja de un tutor. Firestore la usa como id del
  /// documento `franjas/{clave}` para impedir dos sesiones publicadas del
  /// mismo tutor en la misma hora.
  String get claveFranja => '${tutorUid}_${inicio.millisecondsSinceEpoch}';

  Sesion copyWith({
    EstadoSesion? estado,
    int? cuposOcupados,
    String? motivoRechazo,
  }) => Sesion(
    id: id,
    asignaturaId: asignaturaId,
    asignaturaNombre: asignaturaNombre,
    tutorUid: tutorUid,
    tutorNombre: tutorNombre,
    inicio: inicio,
    capacidad: capacidad,
    cuposOcupados: cuposOcupados ?? this.cuposOcupados,
    estado: estado ?? this.estado,
    motivoRechazo: motivoRechazo ?? this.motivoRechazo,
  );
}
