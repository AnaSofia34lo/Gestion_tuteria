// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $InscripcionesTable extends Inscripciones
    with TableInfo<$InscripcionesTable, InscripcionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InscripcionesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sesionIdMeta = const VerificationMeta(
    'sesionId',
  );
  @override
  late final GeneratedColumn<String> sesionId = GeneratedColumn<String>(
    'sesion_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estudianteUidMeta = const VerificationMeta(
    'estudianteUid',
  );
  @override
  late final GeneratedColumn<String> estudianteUid = GeneratedColumn<String>(
    'estudiante_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pendingSyncMeta = const VerificationMeta(
    'pendingSync',
  );
  @override
  late final GeneratedColumn<bool> pendingSync = GeneratedColumn<bool>(
    'pending_sync',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending_sync" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _ultimoErrorMeta = const VerificationMeta(
    'ultimoError',
  );
  @override
  late final GeneratedColumn<String> ultimoError = GeneratedColumn<String>(
    'ultimo_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sesionId,
    estudianteUid,
    estado,
    updatedAt,
    pendingSync,
    ultimoError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inscripciones';
  @override
  VerificationContext validateIntegrity(
    Insertable<InscripcionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sesion_id')) {
      context.handle(
        _sesionIdMeta,
        sesionId.isAcceptableOrUnknown(data['sesion_id']!, _sesionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sesionIdMeta);
    }
    if (data.containsKey('estudiante_uid')) {
      context.handle(
        _estudianteUidMeta,
        estudianteUid.isAcceptableOrUnknown(
          data['estudiante_uid']!,
          _estudianteUidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_estudianteUidMeta);
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    } else if (isInserting) {
      context.missing(_estadoMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('pending_sync')) {
      context.handle(
        _pendingSyncMeta,
        pendingSync.isAcceptableOrUnknown(
          data['pending_sync']!,
          _pendingSyncMeta,
        ),
      );
    }
    if (data.containsKey('ultimo_error')) {
      context.handle(
        _ultimoErrorMeta,
        ultimoError.isAcceptableOrUnknown(
          data['ultimo_error']!,
          _ultimoErrorMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InscripcionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InscripcionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sesionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sesion_id'],
      )!,
      estudianteUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estudiante_uid'],
      )!,
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      pendingSync: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending_sync'],
      )!,
      ultimoError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ultimo_error'],
      ),
    );
  }

  @override
  $InscripcionesTable createAlias(String alias) {
    return $InscripcionesTable(attachedDatabase, alias);
  }
}

class InscripcionRow extends DataClass implements Insertable<InscripcionRow> {
  final String id;
  final String sesionId;
  final String estudianteUid;
  final String estado;
  final DateTime updatedAt;
  final bool pendingSync;
  final String? ultimoError;
  const InscripcionRow({
    required this.id,
    required this.sesionId,
    required this.estudianteUid,
    required this.estado,
    required this.updatedAt,
    required this.pendingSync,
    this.ultimoError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sesion_id'] = Variable<String>(sesionId);
    map['estudiante_uid'] = Variable<String>(estudianteUid);
    map['estado'] = Variable<String>(estado);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['pending_sync'] = Variable<bool>(pendingSync);
    if (!nullToAbsent || ultimoError != null) {
      map['ultimo_error'] = Variable<String>(ultimoError);
    }
    return map;
  }

  InscripcionesCompanion toCompanion(bool nullToAbsent) {
    return InscripcionesCompanion(
      id: Value(id),
      sesionId: Value(sesionId),
      estudianteUid: Value(estudianteUid),
      estado: Value(estado),
      updatedAt: Value(updatedAt),
      pendingSync: Value(pendingSync),
      ultimoError: ultimoError == null && nullToAbsent
          ? const Value.absent()
          : Value(ultimoError),
    );
  }

  factory InscripcionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InscripcionRow(
      id: serializer.fromJson<String>(json['id']),
      sesionId: serializer.fromJson<String>(json['sesionId']),
      estudianteUid: serializer.fromJson<String>(json['estudianteUid']),
      estado: serializer.fromJson<String>(json['estado']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      pendingSync: serializer.fromJson<bool>(json['pendingSync']),
      ultimoError: serializer.fromJson<String?>(json['ultimoError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sesionId': serializer.toJson<String>(sesionId),
      'estudianteUid': serializer.toJson<String>(estudianteUid),
      'estado': serializer.toJson<String>(estado),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'pendingSync': serializer.toJson<bool>(pendingSync),
      'ultimoError': serializer.toJson<String?>(ultimoError),
    };
  }

  InscripcionRow copyWith({
    String? id,
    String? sesionId,
    String? estudianteUid,
    String? estado,
    DateTime? updatedAt,
    bool? pendingSync,
    Value<String?> ultimoError = const Value.absent(),
  }) => InscripcionRow(
    id: id ?? this.id,
    sesionId: sesionId ?? this.sesionId,
    estudianteUid: estudianteUid ?? this.estudianteUid,
    estado: estado ?? this.estado,
    updatedAt: updatedAt ?? this.updatedAt,
    pendingSync: pendingSync ?? this.pendingSync,
    ultimoError: ultimoError.present ? ultimoError.value : this.ultimoError,
  );
  InscripcionRow copyWithCompanion(InscripcionesCompanion data) {
    return InscripcionRow(
      id: data.id.present ? data.id.value : this.id,
      sesionId: data.sesionId.present ? data.sesionId.value : this.sesionId,
      estudianteUid: data.estudianteUid.present
          ? data.estudianteUid.value
          : this.estudianteUid,
      estado: data.estado.present ? data.estado.value : this.estado,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      pendingSync: data.pendingSync.present
          ? data.pendingSync.value
          : this.pendingSync,
      ultimoError: data.ultimoError.present
          ? data.ultimoError.value
          : this.ultimoError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InscripcionRow(')
          ..write('id: $id, ')
          ..write('sesionId: $sesionId, ')
          ..write('estudianteUid: $estudianteUid, ')
          ..write('estado: $estado, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('pendingSync: $pendingSync, ')
          ..write('ultimoError: $ultimoError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sesionId,
    estudianteUid,
    estado,
    updatedAt,
    pendingSync,
    ultimoError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InscripcionRow &&
          other.id == this.id &&
          other.sesionId == this.sesionId &&
          other.estudianteUid == this.estudianteUid &&
          other.estado == this.estado &&
          other.updatedAt == this.updatedAt &&
          other.pendingSync == this.pendingSync &&
          other.ultimoError == this.ultimoError);
}

class InscripcionesCompanion extends UpdateCompanion<InscripcionRow> {
  final Value<String> id;
  final Value<String> sesionId;
  final Value<String> estudianteUid;
  final Value<String> estado;
  final Value<DateTime> updatedAt;
  final Value<bool> pendingSync;
  final Value<String?> ultimoError;
  final Value<int> rowid;
  const InscripcionesCompanion({
    this.id = const Value.absent(),
    this.sesionId = const Value.absent(),
    this.estudianteUid = const Value.absent(),
    this.estado = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.ultimoError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InscripcionesCompanion.insert({
    required String id,
    required String sesionId,
    required String estudianteUid,
    required String estado,
    required DateTime updatedAt,
    this.pendingSync = const Value.absent(),
    this.ultimoError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sesionId = Value(sesionId),
       estudianteUid = Value(estudianteUid),
       estado = Value(estado),
       updatedAt = Value(updatedAt);
  static Insertable<InscripcionRow> custom({
    Expression<String>? id,
    Expression<String>? sesionId,
    Expression<String>? estudianteUid,
    Expression<String>? estado,
    Expression<DateTime>? updatedAt,
    Expression<bool>? pendingSync,
    Expression<String>? ultimoError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sesionId != null) 'sesion_id': sesionId,
      if (estudianteUid != null) 'estudiante_uid': estudianteUid,
      if (estado != null) 'estado': estado,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (pendingSync != null) 'pending_sync': pendingSync,
      if (ultimoError != null) 'ultimo_error': ultimoError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InscripcionesCompanion copyWith({
    Value<String>? id,
    Value<String>? sesionId,
    Value<String>? estudianteUid,
    Value<String>? estado,
    Value<DateTime>? updatedAt,
    Value<bool>? pendingSync,
    Value<String?>? ultimoError,
    Value<int>? rowid,
  }) {
    return InscripcionesCompanion(
      id: id ?? this.id,
      sesionId: sesionId ?? this.sesionId,
      estudianteUid: estudianteUid ?? this.estudianteUid,
      estado: estado ?? this.estado,
      updatedAt: updatedAt ?? this.updatedAt,
      pendingSync: pendingSync ?? this.pendingSync,
      ultimoError: ultimoError ?? this.ultimoError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sesionId.present) {
      map['sesion_id'] = Variable<String>(sesionId.value);
    }
    if (estudianteUid.present) {
      map['estudiante_uid'] = Variable<String>(estudianteUid.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (pendingSync.present) {
      map['pending_sync'] = Variable<bool>(pendingSync.value);
    }
    if (ultimoError.present) {
      map['ultimo_error'] = Variable<String>(ultimoError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InscripcionesCompanion(')
          ..write('id: $id, ')
          ..write('sesionId: $sesionId, ')
          ..write('estudianteUid: $estudianteUid, ')
          ..write('estado: $estado, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('pendingSync: $pendingSync, ')
          ..write('ultimoError: $ultimoError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $InscripcionesTable inscripciones = $InscripcionesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [inscripciones];
}

typedef $$InscripcionesTableCreateCompanionBuilder =
    InscripcionesCompanion Function({
      required String id,
      required String sesionId,
      required String estudianteUid,
      required String estado,
      required DateTime updatedAt,
      Value<bool> pendingSync,
      Value<String?> ultimoError,
      Value<int> rowid,
    });
typedef $$InscripcionesTableUpdateCompanionBuilder =
    InscripcionesCompanion Function({
      Value<String> id,
      Value<String> sesionId,
      Value<String> estudianteUid,
      Value<String> estado,
      Value<DateTime> updatedAt,
      Value<bool> pendingSync,
      Value<String?> ultimoError,
      Value<int> rowid,
    });

class $$InscripcionesTableFilterComposer
    extends Composer<_$AppDatabase, $InscripcionesTable> {
  $$InscripcionesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sesionId => $composableBuilder(
    column: $table.sesionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estudianteUid => $composableBuilder(
    column: $table.estudianteUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ultimoError => $composableBuilder(
    column: $table.ultimoError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InscripcionesTableOrderingComposer
    extends Composer<_$AppDatabase, $InscripcionesTable> {
  $$InscripcionesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sesionId => $composableBuilder(
    column: $table.sesionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estudianteUid => $composableBuilder(
    column: $table.estudianteUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ultimoError => $composableBuilder(
    column: $table.ultimoError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InscripcionesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InscripcionesTable> {
  $$InscripcionesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sesionId =>
      $composableBuilder(column: $table.sesionId, builder: (column) => column);

  GeneratedColumn<String> get estudianteUid => $composableBuilder(
    column: $table.estudianteUid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ultimoError => $composableBuilder(
    column: $table.ultimoError,
    builder: (column) => column,
  );
}

class $$InscripcionesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InscripcionesTable,
          InscripcionRow,
          $$InscripcionesTableFilterComposer,
          $$InscripcionesTableOrderingComposer,
          $$InscripcionesTableAnnotationComposer,
          $$InscripcionesTableCreateCompanionBuilder,
          $$InscripcionesTableUpdateCompanionBuilder,
          (
            InscripcionRow,
            BaseReferences<_$AppDatabase, $InscripcionesTable, InscripcionRow>,
          ),
          InscripcionRow,
          PrefetchHooks Function()
        > {
  $$InscripcionesTableTableManager(_$AppDatabase db, $InscripcionesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InscripcionesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InscripcionesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InscripcionesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sesionId = const Value.absent(),
                Value<String> estudianteUid = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> pendingSync = const Value.absent(),
                Value<String?> ultimoError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InscripcionesCompanion(
                id: id,
                sesionId: sesionId,
                estudianteUid: estudianteUid,
                estado: estado,
                updatedAt: updatedAt,
                pendingSync: pendingSync,
                ultimoError: ultimoError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sesionId,
                required String estudianteUid,
                required String estado,
                required DateTime updatedAt,
                Value<bool> pendingSync = const Value.absent(),
                Value<String?> ultimoError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InscripcionesCompanion.insert(
                id: id,
                sesionId: sesionId,
                estudianteUid: estudianteUid,
                estado: estado,
                updatedAt: updatedAt,
                pendingSync: pendingSync,
                ultimoError: ultimoError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InscripcionesTable, InscripcionRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $InscripcionesTable,
                    InscripcionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InscripcionesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InscripcionesTable,
      InscripcionRow,
      $$InscripcionesTableFilterComposer,
      $$InscripcionesTableOrderingComposer,
      $$InscripcionesTableAnnotationComposer,
      $$InscripcionesTableCreateCompanionBuilder,
      $$InscripcionesTableUpdateCompanionBuilder,
      (
        InscripcionRow,
        BaseReferences<_$AppDatabase, $InscripcionesTable, InscripcionRow>,
      ),
      InscripcionRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$InscripcionesTableTableManager get inscripciones =>
      $$InscripcionesTableTableManager(_db, _db.inscripciones);
}
