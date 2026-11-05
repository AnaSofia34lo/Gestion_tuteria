/// Elemento del catálogo HTTP (asignatura o tema).
///
/// Es solo referencia: las sesiones, capacidades y cupos viven en Firestore,
/// por eso este modelo no tiene disponibilidad.
class Asignatura {
  final String id;
  final String nombre;
  final String area;
  final String descripcion;

  const Asignatura({
    required this.id,
    required this.nombre,
    required this.area,
    required this.descripcion,
  });

  /// Lanza [FormatException] si falta un campo o viene con otro tipo, para que
  /// el servicio lo reporte como "respuesta no válida" y no como un crash.
  factory Asignatura.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final nombre = json['nombre'];
    final area = json['area'];
    final descripcion = json['descripcion'];

    if (id == null || (id is! String && id is! int)) {
      throw const FormatException('Asignatura sin id válido');
    }
    if (nombre is! String || nombre.trim().isEmpty) {
      throw const FormatException('Asignatura sin nombre');
    }
    if (area is! String || area.trim().isEmpty) {
      throw const FormatException('Asignatura sin área');
    }

    return Asignatura(
      id: id.toString(),
      nombre: nombre.trim(),
      area: area.trim(),
      descripcion: descripcion is String ? descripcion.trim() : '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'area': area,
    'descripcion': descripcion,
  };
}
