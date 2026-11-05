import 'package:drift/drift.dart';
import 'package:gestion_tutorias/local/app_database.dart';
import 'package:gestion_tutorias/models/inscripcion.dart';

class InscripcionLocalDataSource {
  final AppDatabase db;
  InscripcionLocalDataSource(this.db);

  Inscripcion _toDomain(InscripcionRow row) => Inscripcion(
    id: row.id,
    sesionId: row.sesionId,
    estudianteUid: row.estudianteUid,
    estado: EstadoInscripcion.fromName(row.estado),
    updatedAt: row.updatedAt,
    pendingSync: row.pendingSync,
    ultimoError: row.ultimoError,
  );

  InscripcionesCompanion _toRow(Inscripcion i) => InscripcionesCompanion(
    id: Value(i.id),
    sesionId: Value(i.sesionId),
    estudianteUid: Value(i.estudianteUid),
    estado: Value(i.estado.name),
    updatedAt: Value(i.updatedAt),
    pendingSync: Value(i.pendingSync),
    ultimoError: Value(i.ultimoError),
  );

  Future<void> guardar(Inscripcion inscripcion) =>
      db.into(db.inscripciones).insertOnConflictUpdate(_toRow(inscripcion));

  Future<Inscripcion?> porId(String id) async {
    final row = await (db.select(
      db.inscripciones,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  /// "Mis inscripciones": siempre filtradas por el uid de la sesión actual.
  Future<List<Inscripcion>> delEstudiante(String uid) async {
    final rows =
        await (db.select(db.inscripciones)
              ..where((t) => t.estudianteUid.equals(uid))
              ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
            .get();
    return rows.map(_toDomain).toList();
  }

  /// Pendientes solo del usuario autenticado: no se envían los de otra cuenta.
  Future<List<Inscripcion>> pendientes(String uid) async {
    final rows =
        await (db.select(db.inscripciones)..where(
              (t) => t.estudianteUid.equals(uid) & t.pendingSync.equals(true),
            ))
            .get();
    return rows.map(_toDomain).toList();
  }

  /// Aplica la respuesta del servidor solo si el registro no cambió mientras
  /// se enviaba: una edición más reciente debe seguir pendiente.
  Future<bool> aplicarConfirmacion(
    Inscripcion enviada,
    EstadoInscripcion estadoRemoto,
  ) async {
    final filas =
        await (db.update(db.inscripciones)..where(
              (t) =>
                  t.id.equals(enviada.id) &
                  t.updatedAt.equals(enviada.updatedAt) &
                  t.estado.equals(enviada.estado.name),
            ))
            .write(
              InscripcionesCompanion(
                estado: Value(estadoRemoto.name),
                pendingSync: const Value(false),
                ultimoError: const Value(null),
              ),
            );
    return filas > 0;
  }

  /// Rechazo definitivo (regla de negocio): se conserva la evidencia local con
  /// el motivo y se deja de reenviar.
  Future<void> marcarRechazada(Inscripcion enviada, String motivo) =>
      (db.update(db.inscripciones)..where(
            (t) =>
                t.id.equals(enviada.id) & t.updatedAt.equals(enviada.updatedAt),
          ))
          .write(
            InscripcionesCompanion(
              estado: Value(EstadoInscripcion.rechazada.name),
              pendingSync: const Value(false),
              ultimoError: Value(motivo),
            ),
          );

  /// Fallo temporal: sigue pendiente y guarda el motivo para el reintento.
  Future<void> registrarFalloTemporal(String id, String motivo) =>
      (db.update(db.inscripciones)..where((t) => t.id.equals(id))).write(
        InscripcionesCompanion(ultimoError: Value(motivo)),
      );
}
