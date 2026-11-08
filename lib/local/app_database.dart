import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'inscripciones_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Inscripciones])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      // v2 agrega los datos de la sesión y del tutor a cada inscripción.
      if (from < 2) {
        await m.addColumn(inscripciones, inscripciones.estudianteNombre);
        await m.addColumn(inscripciones, inscripciones.tutorUid);
        await m.addColumn(inscripciones, inscripciones.asignaturaNombre);
        await m.addColumn(inscripciones, inscripciones.inicioSesion);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'tutorias.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
