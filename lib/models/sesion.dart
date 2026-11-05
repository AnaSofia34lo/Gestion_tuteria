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
    EstadoSesion.publicada => {EstadoSesion.realizada, EstadoSesion.cerrada},
    EstadoSesion.realizada => {EstadoSesion.cerrada},
    EstadoSesion.rechazada || EstadoSesion.cerrada => const {},
  };

  bool puedePasarA(EstadoSesion destino) => siguientes.contains(destino);
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
  final String tutorUid;
  final DateTime inicio;
  final int capacidad;
  final int cuposOcupados;
  final EstadoSesion estado;

  const Sesion({
    required this.id,
    required this.asignaturaId,
    required this.tutorUid,
    required this.inicio,
    required this.capacidad,
    this.cuposOcupados = 0,
    this.estado = EstadoSesion.propuesta,
  });

  DateTime get fin => inicio.add(duracion);
  int get cuposDisponibles => capacidad - cuposOcupados;
  bool haIniciado(DateTime ahora) => !ahora.isBefore(inicio);
  bool haTerminado(DateTime ahora) => !ahora.isBefore(fin);

  /// Franja fija: empieza en punto (minuto, segundo y ms en cero).
  bool get esFranjaFija =>
      inicio.minute == 0 && inicio.second == 0 && inicio.millisecond == 0;

  Sesion copyWith({EstadoSesion? estado, int? cuposOcupados}) => Sesion(
    id: id,
    asignaturaId: asignaturaId,
    tutorUid: tutorUid,
    inicio: inicio,
    capacidad: capacidad,
    cuposOcupados: cuposOcupados ?? this.cuposOcupados,
    estado: estado ?? this.estado,
  );

  factory Sesion.fromJson(Map<String, dynamic> json) => Sesion(
    id: json['id'] as String,
    asignaturaId: json['asignaturaId'] as String,
    tutorUid: json['tutorUid'] as String,
    inicio: DateTime.parse(json['inicio'] as String),
    capacidad: json['capacidad'] as int,
    cuposOcupados: (json['cuposOcupados'] as int?) ?? 0,
    estado: EstadoSesion.fromName(json['estado'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'asignaturaId': asignaturaId,
    'tutorUid': tutorUid,
    'inicio': inicio.toUtc().toIso8601String(),
    'capacidad': capacidad,
    'cuposOcupados': cuposOcupados,
    'estado': estado.name,
  };
}
