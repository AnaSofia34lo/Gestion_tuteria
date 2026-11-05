import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_tutorias/catalogo_screen.dart';
import 'package:gestion_tutorias/repositories/asignatura_repository.dart';
import 'package:gestion_tutorias/services/asignatura_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _catalogo = '''
[
  {"id": 1, "nombre": "Cálculo I", "area": "Matemáticas", "descripcion": "Límites"},
  {"id": 2, "nombre": "Física I", "area": "Ciencias", "descripcion": "Cinemática"},
  {"id": 3, "nombre": "Álgebra lineal", "area": "Matemáticas", "descripcion": "Matrices"}
]
''';

Widget _app(http.Client client) => MaterialApp(
  home: CatalogoScreen(
    repository: AsignaturaRepository(
      AsignaturaService('https://catalogo.test', client: client),
    ),
  ),
);

void main() {
  testWidgets('filtra por área y guarda la preferencia', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      _app(MockClient((_) async => _json(_catalogo, 200))),
    );
    await tester.pumpAndSettle();

    expect(find.text('3 de 3 asignaturas'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Ciencias'));
    await tester.pumpAndSettle();

    expect(find.text('1 de 3 asignaturas'), findsOneWidget);
    expect(find.text('Cálculo I'), findsNothing);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(CatalogoScreen.prefAreaKey), 'Ciencias');
  });

  testWidgets('restaura el área guardada al abrir', (tester) async {
    SharedPreferences.setMockInitialValues({
      CatalogoScreen.prefAreaKey: 'Matemáticas',
    });
    await tester.pumpWidget(
      _app(MockClient((_) async => _json(_catalogo, 200))),
    );
    await tester.pumpAndSettle();

    expect(find.text('2 de 3 asignaturas'), findsOneWidget);
  });

  testWidgets('error HTTP muestra mensaje y reintento recupera', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    var llamadas = 0;
    final client = MockClient((_) async {
      llamadas++;
      return llamadas == 1 ? _json('falla', 500) : _json(_catalogo, 200);
    });
    await tester.pumpWidget(_app(client));
    await tester.pumpAndSettle();

    expect(find.text('No pudimos cargar el catálogo'), findsOneWidget);
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('3 de 3 asignaturas'), findsOneWidget);
    expect(llamadas, 2);
  });

  testWidgets('catálogo vacío muestra estado vacío', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(_app(MockClient((_) async => _json('[]', 200))));
    await tester.pumpAndSettle();

    expect(
      find.text('Todavía no hay asignaturas en el catálogo'),
      findsOneWidget,
    );
  });
}

/// Respuesta en UTF-8, como la envía una API real (el catálogo trae tildes).
http.Response _json(String body, int status) => http.Response.bytes(
  utf8.encode(body),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);
