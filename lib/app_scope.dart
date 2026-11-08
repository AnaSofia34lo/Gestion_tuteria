import 'package:flutter/widgets.dart';
import 'package:gestion_tutorias/repositories/asignatura_repository.dart';
import 'package:gestion_tutorias/repositories/auth_repository.dart';
import 'package:gestion_tutorias/repositories/inscripcion_repository.dart';
import 'package:gestion_tutorias/repositories/sesion_repository.dart';

/// Entrega los repositorios a las pantallas sin pasarlos por cada
/// constructor. Las pantallas nunca conocen Firebase ni Drift directamente.
class AppScope extends InheritedWidget {
  final AuthRepository auth;
  final AsignaturaRepository asignaturas;
  final SesionRepository sesiones;
  final InscripcionRepository inscripciones;

  const AppScope({
    super.key,
    required this.auth,
    required this.asignaturas,
    required this.sesiones,
    required this.inscripciones,
    required super.child,
  });

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope no encontrado');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => false;
}
