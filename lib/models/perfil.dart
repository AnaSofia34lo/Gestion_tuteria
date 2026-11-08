/// Roles del caso G61-5. Un usuario nuevo siempre es estudiante; los roles
/// privilegiados se asignan en Firebase Console (ver README).
enum Rol {
  estudiante,
  tutor,
  coordinador;

  static Rol fromName(String? name) => Rol.values.firstWhere(
    (r) => r.name == name,
    orElse: () => Rol.estudiante,
  );

  String get etiqueta => switch (this) {
    Rol.estudiante => 'Estudiante',
    Rol.tutor => 'Tutor',
    Rol.coordinador => 'Coordinador académico',
  };
}

/// Perfil guardado en `usuarios/{uid}`, enlazado al uid de Authentication.
class Perfil {
  final String uid;
  final String nombre;
  final String email;
  final Rol rol;

  const Perfil({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.rol,
  });

  factory Perfil.fromMap(String uid, Map<String, dynamic> data) => Perfil(
    uid: uid,
    nombre: (data['nombre'] as String?)?.trim() ?? '',
    email: (data['email'] as String?) ?? '',
    rol: Rol.fromName(data['rol'] as String?),
  );
}
