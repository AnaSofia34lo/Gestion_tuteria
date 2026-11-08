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

  String get etiqueta => switch (this) {
    EstadoInscripcion.solicitada => 'Solicitada',
    EstadoInscripcion.confirmada => 'Confirmada',
    EstadoInscripcion.cancelada => 'Cancelada',
    EstadoInscripcion.rechazada => 'Rechazada',
    EstadoInscripcion.asistio => 'Asistió',
    EstadoInscripcion.noAsistio => 'No asistió',
  };
}

class Inscripcion {
  /// Identidad estable `sesionId_estudianteUid`: se crea antes del primer
  /// envío y se reutiliza en los reintentos, así Firestore nunca guarda dos
  /// inscripciones del mismo estudiante en la misma sesión.
  final String id;
  final String sesionId;
  final String estudianteUid;
  final String estudianteNombre;
  final String tutorUid;
  final EstadoInscripcion estado;
  final DateTime updatedAt;

  /// Copia de datos de la sesión para mostrar "Mis inscripciones" sin red.
  final String asignaturaNombre;
  final DateTime? inicioSesion;

  /// Estado de sincronización, separado del estado del negocio: una solicitud
  /// pendiente NO es una plaza garantizada.
  final bool pendingSync;
  final String? ultimoError;

  const Inscripcion({
    required this.id,
    required this.sesionId,
    required this.estudianteUid,
    this.estudianteNombre = '',
    this.tutorUid = '',
    required this.estado,
    required this.updatedAt,
    this.asignaturaNombre = '',
    this.inicioSesion,
    this.pendingSync = true,
    this.ultimoError,
  });

  static String idPara(String sesionId, String estudianteUid) =>
      '${sesionId}_$estudianteUid';

  Inscripcion copyWith({
    EstadoInscripcion? estado,
    DateTime? updatedAt,
    bool? pendingSync,
    String? ultimoError,
    bool limpiarError = false,
  }) => Inscripcion(
    id: id,
    sesionId: sesionId,
    estudianteUid: estudianteUid,
    estudianteNombre: estudianteNombre,
    tutorUid: tutorUid,
    estado: estado ?? this.estado,
    updatedAt: updatedAt ?? this.updatedAt,
    asignaturaNombre: asignaturaNombre,
    inicioSesion: inicioSesion,
    pendingSync: pendingSync ?? this.pendingSync,
    ultimoError: limpiarError ? null : (ultimoError ?? this.ultimoError),
  );
}
