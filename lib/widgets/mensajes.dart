import 'package:flutter/material.dart';
import 'package:gestion_tutorias/core/app_logger.dart';
import 'package:gestion_tutorias/core/reglas_tutoria.dart';
import 'package:gestion_tutorias/repositories/auth_repository.dart';
import 'package:gestion_tutorias/services/asignatura_service.dart';

/// Mensaje legible para cualquier error: nunca muestra trazas técnicas.
String mensajeDeError(Object error) {
  if (error is ReglaNegocioException) return error.message;
  if (error is AuthException) return error.message;
  if (error is ApiException) return error.message;
  AppLogger.error('Error inesperado en la interfaz', error, StackTrace.current);
  return 'Ocurrió un error inesperado. Intenta de nuevo';
}

void mostrarMensaje(BuildContext context, String texto) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(texto)));
}

Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  String accion = 'Confirmar',
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(accion),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// Ejecuta una acción crítica mostrando el resultado. Devuelve true si salió
/// bien. Protege el `context` si la pantalla se cerró mientras esperaba.
Future<bool> ejecutarAccion(
  BuildContext context,
  Future<void> Function() accion, {
  required String exito,
}) async {
  try {
    await accion();
    if (context.mounted) mostrarMensaje(context, exito);
    return true;
  } catch (e) {
    if (context.mounted) mostrarMensaje(context, mensajeDeError(e));
    return false;
  }
}
