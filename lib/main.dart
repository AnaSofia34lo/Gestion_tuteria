import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gestion_tutorias/app_scope.dart';
import 'package:gestion_tutorias/core/api_config.dart';
import 'package:gestion_tutorias/core/app_logger.dart';
import 'package:gestion_tutorias/core/diagnostico.dart';
import 'package:gestion_tutorias/firebase_options.dart';
import 'package:gestion_tutorias/local/app_database.dart';
import 'package:gestion_tutorias/local/inscripcion_local_data_source.dart';
import 'package:gestion_tutorias/models/perfil.dart';
import 'package:gestion_tutorias/remote/firestore_inscripcion_remote_data_source.dart';
import 'package:gestion_tutorias/remote/sesion_remote_data_source.dart';
import 'package:gestion_tutorias/repositories/asignatura_repository.dart';
import 'package:gestion_tutorias/repositories/auth_repository.dart';
import 'package:gestion_tutorias/repositories/inscripcion_repository.dart';
import 'package:gestion_tutorias/repositories/sesion_repository.dart';
import 'package:gestion_tutorias/screens/home_screen.dart';
import 'package:gestion_tutorias/screens/login_screen.dart';
import 'package:gestion_tutorias/services/asignatura_service.dart';
import 'package:gestion_tutorias/widgets/loading_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Diagnostico.configurar();

  final firestore = FirebaseFirestore.instance;
  final database = AppDatabase();
  final inscripciones = InscripcionRepository(
    local: InscripcionLocalDataSource(database),
    remote: FirestoreInscripcionRemoteDataSource(firestore),
  );

  runApp(
    AppScope(
      auth: AuthRepository(auth: FirebaseAuth.instance, firestore: firestore),
      asignaturas: AsignaturaRepository(
        AsignaturaService(ApiConfig.catalogoUrl),
      ),
      sesiones: SesionRepository(
        remote: SesionRemoteDataSource(firestore),
        inscripciones: inscripciones,
      ),
      inscripciones: inscripciones,
      child: const TutoriasApp(),
    ),
  );
}

class TutoriasApp extends StatelessWidget {
  const TutoriasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tutorías G61-5',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E5AA8)),
      ),
      home: const AuthGate(),
    );
  }
}

/// Decide entre login y la app según la sesión de Firebase Authentication.
/// También restaura una sesión existente al abrir la app.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Stream<Perfil?>? _perfil;
  String? _uidActual;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _perfil ??= AppScope.of(context).auth.observarPerfil();
  }

  /// Al entrar una cuenta: identifica el usuario en Crashlytics (solo uid)
  /// y envía sus solicitudes pendientes. Las de otra cuenta no se tocan.
  void _alCambiarUsuario(Perfil? perfil) {
    if (perfil?.uid == _uidActual) return;
    _uidActual = perfil?.uid;
    unawaited(Diagnostico.usuario(perfil?.uid, rol: perfil?.rol.name));
    if (perfil != null && perfil.rol == Rol.estudiante) {
      unawaited(
        AppScope.of(context).inscripciones
            .sincronizarPendientes(perfil.uid)
            .catchError((Object e) {
              AppLogger.warning('Sync al iniciar sesión: $e');
              return const ResultadoSync();
            }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Perfil?>(
      stream: _perfil,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('No se pudo cargar tu perfil.'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => AppScope.of(context).auth.cerrarSesion(),
                      child: const Text('Volver al inicio de sesión'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: LoadingView());
        }
        final perfil = snapshot.data;
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => mounted ? _alCambiarUsuario(perfil) : null,
        );
        if (perfil == null) return const LoginScreen();
        // La clave por uid descarta el estado de la cuenta anterior.
        return HomeScreen(key: ValueKey(perfil.uid), perfil: perfil);
      },
    );
  }
}
