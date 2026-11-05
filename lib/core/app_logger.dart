import 'package:flutter/foundation.dart';

/// Logs solo en modo debug. Nunca registrar contraseñas, tokens ni datos
/// personales sensibles.
class AppLogger {
  AppLogger._();

  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('[DEBUG] $message');
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      debugPrint('[WARNING] $message');
    }
  }

  static void error(String message, Object? error, StackTrace? stackTrace) {
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
