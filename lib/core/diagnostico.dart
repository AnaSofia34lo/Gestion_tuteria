import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:gestion_tutorias/core/app_logger.dart';

/// Configuración de Crashlytics.
///
/// - Errores de Flutter y de la plataforma no capturados: fatales.
/// - `AppLogger.error`: no fatales.
/// - Validaciones de negocio y fallos de red esperados no se reportan.
/// - Solo se envía el uid como identificador; nunca correo ni contraseña.
class Diagnostico {
  Diagnostico._();

  static FirebaseCrashlytics get _c => FirebaseCrashlytics.instance;

  static Future<void> configurar() async {
    FlutterError.onError = _c.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      _c.recordError(error, stack, fatal: true);
      return true;
    };
    AppLogger.reportador = (error, stack, motivo) =>
        _c.recordError(error, stack, reason: motivo);
  }

  static Future<void> usuario(String? uid, {String? rol}) async {
    await _c.setUserIdentifier(uid ?? '');
    await _c.setCustomKey('rol', rol ?? 'sin_sesion');
  }

  /// Evento de prueba controlado para la evidencia en la consola. Solo
  /// existe en debug: el botón que lo llama no se compila en release.
  static Future<void> enviarEventoDePrueba() async {
    if (!kDebugMode) return;
    await _c.log('Evento de prueba G61-5');
    await _c.recordError(
      StateError('Prueba controlada de Crashlytics G61-5'),
      StackTrace.current,
      reason: 'Evento de prueba solicitado desde Perfil',
    );
    await _c.sendUnsentReports();
  }
}
