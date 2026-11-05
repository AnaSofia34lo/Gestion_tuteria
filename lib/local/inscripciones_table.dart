import 'package:drift/drift.dart';

@DataClassName('InscripcionRow')
class Inscripciones extends Table {
  // Id estable generado en el dispositivo; se reutiliza al reintentar.
  TextColumn get id => text()();
  TextColumn get sesionId => text()();
  // Dueño del registro: filtra datos al cambiar de cuenta.
  TextColumn get estudianteUid => text()();
  TextColumn get estado => text()();
  DateTimeColumn get updatedAt => dateTime()();
  // true = aun no confirmada por Firestore
  BoolColumn get pendingSync => boolean().withDefault(const Constant(true))();
  // Motivo del último rechazo o fallo, para mostrarlo al usuario.
  TextColumn get ultimoError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
