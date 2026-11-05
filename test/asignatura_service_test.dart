import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_tutorias/repositories/asignatura_repository.dart';
import 'package:gestion_tutorias/services/asignatura_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

AsignaturaService _service(
  MockClientHandler handler, {
  Duration timeout = const Duration(seconds: 2),
}) => AsignaturaService(
  'https://catalogo.test',
  client: MockClient(handler),
  timeout: timeout,
);

Matcher _apiError(String message) =>
    throwsA(isA<ApiException>().having((e) => e.message, 'message', message));

void main() {
  group('AsignaturaService', () {
    test('mapea la lista JSON a modelos Dart', () async {
      final service = _service(
        (_) async => _json(
          '[{"id": 1, "nombre": " Cálculo I ", "area": "Matemáticas", '
          '"descripcion": "Límites"}]',
          200,
        ),
      );
      final items = await service.getAsignaturas();
      expect(items, hasLength(1));
      expect(items.first.id, '1');
      expect(items.first.nombre, 'Cálculo I');
      expect(items.first.area, 'Matemáticas');
    });

    test('acepta el formato { "asignaturas": [...] }', () async {
      final service = _service(
        (_) async => _json(
          '{"asignaturas": [{"id": "a1", "nombre": "Física", '
          '"area": "Ciencias"}]}',
          200,
        ),
      );
      final items = await service.getAsignaturas();
      expect(items.single.descripcion, '');
    });

    test('lista vacía es un resultado válido, no un error', () async {
      final service = _service((_) async => _json('[]', 200));
      expect(await service.getAsignaturas(), isEmpty);
    });

    test('404 y 500 se traducen a mensajes para el usuario', () async {
      expect(
        _service((_) async => _json('', 404)).getAsignaturas(),
        _apiError('No se encontró el catálogo de asignaturas'),
      );
      expect(
        _service((_) async => _json('', 503)).getAsignaturas(),
        _apiError(
          'El servidor del catálogo no está disponible. Intenta más tarde.',
        ),
      );
    });

    test('JSON mal formado o con campos faltantes no rompe la app', () async {
      expect(
        _service((_) async => _json('{no es json', 200)).getAsignaturas(),
        _apiError('La respuesta del servidor no es válida'),
      );
      expect(
        _service(
          (_) async => _json('[{"id": 1, "area": "Ciencias"}]', 200),
        ).getAsignaturas(),
        _apiError('La respuesta del servidor no es válida'),
      );
    });

    test('sin conexión y timeout tienen mensajes propios', () async {
      expect(
        _service(
          (_) async => throw const SocketException('offline'),
        ).getAsignaturas(),
        _apiError('Sin conexión a Internet'),
      );
      expect(
        _service(
          (_) => Completer<http.Response>().future,
          timeout: const Duration(milliseconds: 20),
        ).getAsignaturas(),
        _apiError('El servidor tardó demasiado en responder'),
      );
    });
  });

  group('AsignaturaRepository', () {
    test('no repite la petición si ya hay datos en memoria', () async {
      var llamadas = 0;
      final repo = AsignaturaRepository(
        _service((_) async {
          llamadas++;
          return _json(
            '[{"id": 1, "nombre": "Cálculo", "area": "Matemáticas"}]',
            200,
          );
        }),
      );
      await Future.wait([repo.getAsignaturas(), repo.getAsignaturas()]);
      await repo.getAsignaturas();
      expect(llamadas, 1);

      await repo.refrescar();
      expect(llamadas, 2);
    });

    test('filtra por área y lista áreas sin repetir', () async {
      final repo = AsignaturaRepository(
        _service(
          (_) async => _json(
            '[{"id": 1, "nombre": "Cálculo", "area": "Matemáticas"},'
            '{"id": 2, "nombre": "Física", "area": "Ciencias"},'
            '{"id": 3, "nombre": "Álgebra", "area": "Matemáticas"}]',
            200,
          ),
        ),
      );
      final items = await repo.getAsignaturas();
      expect(repo.areas(items), ['Ciencias', 'Matemáticas']);
      expect(repo.filtrarPorArea(items, 'Matemáticas'), hasLength(2));
      expect(repo.filtrarPorArea(items, null), hasLength(3));
    });
  });
}

/// Respuesta en UTF-8, como la envía una API real (el catálogo trae tildes).
http.Response _json(String body, int status) => http.Response.bytes(
  utf8.encode(body),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);
