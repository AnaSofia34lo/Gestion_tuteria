import 'dart:math';

/// SOLICITADA → CONFIRMADA → ASISTIO | NO_ASISTIO.
/// El estudiante puede CANCELAR antes del inicio. RECHAZADA indica que el
/// servidor no confirmó (sin cupo, sesión iniciada...).
enum EstadoInscripcion {
  solicitada,
  confirmada,
  cancelada,
  rechazada,
  asistio,
  noAsistio;

  static EstadoInscripcion fromName(String name) =>
      EstadoInscripcion.values.firstWhere(
        (e) => e.name == name,
        orElse: () =>
            throw FormatException('Estado de inscripción desconocido: $name'),
      );

  /// Una inscripción activa ocupa (o pretende ocupar) un cupo.
  bool get esActiva =>
      this == EstadoInscripcion.solicitada ||
      this == EstadoInscripcion.confirmada;

  bool get tieneAsistencia =>
      this == EstadoInscripcion.asistio || this == EstadoInscripcion.noAsistio;
}

class Inscripcion {
  /// Identidad estable creada antes del primer envío y reutilizada en los
  /// reintentos para no duplicar la solicitud en Firestore.
  final String id;
  final String sesionId;
  final String estudianteUid;
  final EstadoInscripcion estado;
  final DateTime updatedAt;

  /// Estado de sincronización, separado del estado del negocio: una solicitud
  /// pendiente NO es una plaza garantizada.
  final bool pendingSync;
  final String? ultimoError;

  const Inscripcion({
    required this.id,
    required this.sesionId,
    required this.estudianteUid,
    required this.estado,
    required this.updatedAt,
    this.pendingSync = true,
    this.ultimoError,
  });

  static String nuevoId([Random? random]) {
    final r = random ?? Random.secure();
    final bytes = List<int>.generate(16, (_) => r.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  Inscripcion copyWith({
    EstadoInscripcion? estado,
    DateTime? updatedAt,
    bool? pendingSync,
    String? ultimoError,
  }) => Inscripcion(
    id: id,
    sesionId: sesionId,
    estudianteUid: estudianteUid,
    estado: estado ?? this.estado,
    updatedAt: updatedAt ?? this.updatedAt,
    pendingSync: pendingSync ?? this.pendingSync,
    ultimoError: ultimoError ?? this.ultimoError,
  );

  // pendingSync y ultimoError son estado local: no viajan a Firestore.
  Map<String, dynamic> toJson() => {
    'id': id,
    'sesionId': sesionId,
    'estudianteUid': estudianteUid,
    'estado': estado.name,
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };
}
