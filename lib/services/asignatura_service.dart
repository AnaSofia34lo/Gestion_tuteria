import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:gestion_tutorias/core/api_config.dart';
import 'package:gestion_tutorias/core/app_logger.dart';
import 'package:gestion_tutorias/models/asignatura.dart';
import 'package:http/http.dart' as http;

/// Error controlado de la capa HTTP. El mensaje se muestra al usuario, por eso
/// nunca incluye trazas técnicas.
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

/// Única clase que conoce la petición HTTP del catálogo.
class AsignaturaService {
  final String baseUrl;
  final http.Client _client;
  final Duration timeout;

  AsignaturaService(
    this.baseUrl, {
    http.Client? client,
    this.timeout = ApiConfig.timeout,
  }) : _client = client ?? http.Client();

  Future<List<Asignatura>> getAsignaturas() async {
    try {
      final response = await _client.get(Uri.parse(baseUrl)).timeout(timeout);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        final items = _extraerLista(decoded);
        final asignaturas = items.map((item) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException('Elemento del catálogo inválido');
          }
          return Asignatura.fromJson(item);
        }).toList();
        AppLogger.debug('Catálogo cargado: ${asignaturas.length} asignaturas');
        return asignaturas;
      }

      AppLogger.warning('Catálogo respondió HTTP ${response.statusCode}');
      if (response.statusCode == 404) {
        throw const ApiException('No se encontró el catálogo de asignaturas');
      }
      if (response.statusCode >= 500) {
        throw const ApiException(
          'El servidor del catálogo no está disponible. Intenta más tarde.',
        );
      }
      throw ApiException(
        'No se pudo cargar el catálogo (código ${response.statusCode})',
      );
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException('El servidor tardó demasiado en responder');
    } on SocketException {
      throw const ApiException('Sin conexión a Internet');
    } on http.ClientException {
      throw const ApiException('No se pudo conectar con el servidor');
    } on FormatException catch (error) {
      AppLogger.warning('JSON inválido en catálogo: ${error.message}');
      throw const ApiException('La respuesta del servidor no es válida');
    } catch (error, stackTrace) {
      AppLogger.error('Error inesperado cargando catálogo', error, stackTrace);
      throw const ApiException('Ocurrió un error inesperado');
    }
  }

  /// Acepta una lista en la raíz o `{ "asignaturas": [...] }`.
  List<dynamic> _extraerLista(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic> && decoded['asignaturas'] is List) {
      return decoded['asignaturas'] as List<dynamic>;
    }
    throw const FormatException('Se esperaba una lista de asignaturas');
  }

  void dispose() => _client.close();
}
