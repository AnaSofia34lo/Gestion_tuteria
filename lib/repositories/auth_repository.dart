import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gestion_tutorias/core/app_logger.dart';
import 'package:gestion_tutorias/models/perfil.dart';

/// Error de autenticación con un mensaje apto para el usuario.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

/// Traduce los códigos de Firebase Authentication a mensajes comprensibles.
/// Es pública para poder probarla sin Firebase.
String mensajeAuth(String code) => switch (code) {
  'invalid-email' => 'El correo no tiene un formato válido',
  'user-disabled' => 'Esta cuenta fue deshabilitada',
  'user-not-found' ||
  'wrong-password' ||
  'invalid-credential' ||
  'INVALID_LOGIN_CREDENTIALS' => 'Correo o contraseña incorrectos',
  'email-already-in-use' => 'Ya existe una cuenta con ese correo',
  'weak-password' => 'La contraseña es muy débil (mínimo 6 caracteres)',
  'network-request-failed' =>
    'Sin conexión. Revisa tu Internet e intenta de nuevo',
  'too-many-requests' => 'Demasiados intentos. Espera un momento',
  'operation-not-allowed' =>
    'El inicio con correo no está habilitado en Firebase',
  _ => 'No se pudo completar la operación. Intenta de nuevo',
};

/// Coordina Firebase Authentication y el perfil `usuarios/{uid}`.
class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRepository({required this.auth, required this.firestore});

  DocumentReference<Map<String, dynamic>> _perfilRef(String uid) =>
      firestore.collection('usuarios').doc(uid);

  /// Perfil de la sesión actual; `null` cuando no hay usuario. Restaura la
  /// sesión existente al abrir la app (Firebase guarda el token, no nosotros).
  Stream<Perfil?> observarPerfil() {
    late final StreamController<Perfil?> controller;
    StreamSubscription<User?>? authSub;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? perfilSub;

    void escucharPerfil(User? user) {
      // Al cambiar de cuenta se cancela la escucha del perfil anterior.
      perfilSub?.cancel();
      perfilSub = null;
      if (user == null) {
        controller.add(null);
        return;
      }
      perfilSub = _perfilRef(user.uid).snapshots().listen((snap) async {
        if (!snap.exists) {
          // El registro pudo cortarse antes de crear el perfil: se completa.
          try {
            await _crearPerfil(user, user.displayName ?? '');
          } catch (e, s) {
            AppLogger.error('No se pudo completar el perfil', e, s);
          }
          return;
        }
        controller.add(Perfil.fromMap(user.uid, snap.data()!));
      }, onError: controller.addError);
    }

    controller = StreamController<Perfil?>(
      onListen: () {
        authSub = auth.authStateChanges().listen(
          escucharPerfil,
          onError: controller.addError,
        );
      },
      onCancel: () async {
        await perfilSub?.cancel();
        await authSub?.cancel();
      },
    );
    return controller.stream;
  }

  Future<void> iniciarSesion(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      AppLogger.warning('Login rechazado: ${e.code}');
      throw AuthException(mensajeAuth(e.code));
    }
  }

  /// Registra siempre con rol estudiante: el usuario no puede elegir rol.
  Future<void> registrar({
    required String nombre,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user!;
      await user.updateDisplayName(nombre.trim());
      await _crearPerfil(user, nombre.trim());
    } on FirebaseAuthException catch (e) {
      AppLogger.warning('Registro rechazado: ${e.code}');
      throw AuthException(mensajeAuth(e.code));
    } on FirebaseException catch (e) {
      AppLogger.warning('Perfil no creado: ${e.code}');
      throw const AuthException(
        'La cuenta se creó, pero no se guardó el perfil. Inicia sesión de nuevo',
      );
    }
  }

  Future<void> _crearPerfil(User user, String nombre) =>
      _perfilRef(user.uid).set({
        'nombre': nombre.isEmpty ? (user.email ?? 'Usuario') : nombre,
        'email': user.email ?? '',
        'rol': Rol.estudiante.name,
        'creadoEn': FieldValue.serverTimestamp(),
      });

  Future<void> cerrarSesion() => auth.signOut();
}
