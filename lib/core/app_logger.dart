import 'package:flutter/foundation.dart';

/// Destino de los errores inesperados (Crashlytics en la app, nada en pruebas).
typedef ReportadorErrores =
    void Function(Object error, StackTrace? stackTrace, String motivo);

/// Logs solo en modo debug. Nunca registrar contraseñas, tokens ni datos
/// personales sensibles.
class AppLogger {
  AppLogger._();

  /// Se configura en `main` con Crashlytics.
  static ReportadorErrores? reportador;

  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('[DEBUG] $message');
    }
  }

  /// Fallos esperados (red, reglas): se registran pero no se reportan.
  static void warning(String message) {
    if (kDebugMode) {
      debugPrint('[WARNING] $message');
    }
  }

  /// Excepciones inesperadas: se reportan a Crashlytics como no fatales.
  static void error(String message, Object? error, StackTrace? stackTrace) {
    if (error != null) reportador?.call(error, stackTrace, message);
    if (!kDebugMode) return;
    debugPrint('[ERROR] $message');
    if (error != null) {
      debugPrint('Error: $error');
    }
    if (stackTrace != null) {
      debugPrint('stackTrace: $stackTrace');
    }
  }
}
