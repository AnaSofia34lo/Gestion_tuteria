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
  static const VerificationMeta _estudianteNombreMeta = const VerificationMeta(
    'estudianteNombre',
  );
  @override
  late final GeneratedColumn<String> estudianteNombre = GeneratedColumn<String>(
    'estudiante_nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _tutorUidMeta = const VerificationMeta(
    'tutorUid',
  );
  @override
  late final GeneratedColumn<String> tutorUid = GeneratedColumn<String>(
    'tutor_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
  static const VerificationMeta _asignaturaNombreMeta = const VerificationMeta(
    'asignaturaNombre',
  );
  @override
  late final GeneratedColumn<String> asignaturaNombre = GeneratedColumn<String>(
    'asignatura_nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _inicioSesionMeta = const VerificationMeta(
    'inicioSesion',
  );
  @override
  late final GeneratedColumn<DateTime> inicioSesion = GeneratedColumn<DateTime>(
    'inicio_sesion',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
    estudianteNombre,
    tutorUid,
    estado,
    updatedAt,
    asignaturaNombre,
    inicioSesion,
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
    if (data.containsKey('estudiante_nombre')) {
      context.handle(
        _estudianteNombreMeta,
        estudianteNombre.isAcceptableOrUnknown(
          data['estudiante_nombre']!,
          _estudianteNombreMeta,
        ),
      );
    }
    if (data.containsKey('tutor_uid')) {
      context.handle(
        _tutorUidMeta,
        tutorUid.isAcceptableOrUnknown(data['tutor_uid']!, _tutorUidMeta),
      );
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
    if (data.containsKey('asignatura_nombre')) {
      context.handle(
        _asignaturaNombreMeta,
        asignaturaNombre.isAcceptableOrUnknown(
          data['asignatura_nombre']!,
          _asignaturaNombreMeta,
        ),
      );
    }
    if (data.containsKey('inicio_sesion')) {
      context.handle(
        _inicioSesionMeta,
        inicioSesion.isAcceptableOrUnknown(
          data['inicio_sesion']!,
          _inicioSesionMeta,
        ),
      );
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
      estudianteNombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estudiante_nombre'],
      )!,
      tutorUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tutor_uid'],
      )!,
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      asignaturaNombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asignatura_nombre'],
      )!,
      inicioSesion: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}inicio_sesion'],
      ),
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
  final String estudianteNombre;
  final String tutorUid;
  final String estado;
  final DateTime updatedAt;
  final String asignaturaNombre;
  final DateTime? inicioSesion;
  final bool pendingSync;
  final String? ultimoError;
  const InscripcionRow({
    required this.id,
    required this.sesionId,
    required this.estudianteUid,
    required this.estudianteNombre,
    required this.tutorUid,
    required this.estado,
    required this.updatedAt,
    required this.asignaturaNombre,
    this.inicioSesion,
    required this.pendingSync,
    this.ultimoError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sesion_id'] = Variable<String>(sesionId);
    map['estudiante_uid'] = Variable<String>(estudianteUid);
    map['estudiante_nombre'] = Variable<String>(estudianteNombre);
    map['tutor_uid'] = Variable<String>(tutorUid);
    map['estado'] = Variable<String>(estado);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['asignatura_nombre'] = Variable<String>(asignaturaNombre);
    if (!nullToAbsent || inicioSesion != null) {
      map['inicio_sesion'] = Variable<DateTime>(inicioSesion);
    }
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
      estudianteNombre: Value(estudianteNombre),
      tutorUid: Value(tutorUid),
      estado: Value(estado),
      updatedAt: Value(updatedAt),
      asignaturaNombre: Value(asignaturaNombre),
      inicioSesion: inicioSesion == null && nullToAbsent
          ? const Value.absent()
          : Value(inicioSesion),
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
      estudianteNombre: serializer.fromJson<String>(json['estudianteNombre']),
      tutorUid: serializer.fromJson<String>(json['tutorUid']),
      estado: serializer.fromJson<String>(json['estado']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      asignaturaNombre: serializer.fromJson<String>(json['asignaturaNombre']),
      inicioSesion: serializer.fromJson<DateTime?>(json['inicioSesion']),
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
      'estudianteNombre': serializer.toJson<String>(estudianteNombre),
      'tutorUid': serializer.toJson<String>(tutorUid),
      'estado': serializer.toJson<String>(estado),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'asignaturaNombre': serializer.toJson<String>(asignaturaNombre),
      'inicioSesion': serializer.toJson<DateTime?>(inicioSesion),
      'pendingSync': serializer.toJson<bool>(pendingSync),
      'ultimoError': serializer.toJson<String?>(ultimoError),
    };
  }

  InscripcionRow copyWith({
    String? id,
    String? sesionId,
    String? estudianteUid,
    String? estudianteNombre,
    String? tutorUid,
    String? estado,
    DateTime? updatedAt,
    String? asignaturaNombre,
    Value<DateTime?> inicioSesion = const Value.absent(),
    bool? pendingSync,
    Value<String?> ultimoError = const Value.absent(),
  }) => InscripcionRow(
    id: id ?? this.id,
    sesionId: sesionId ?? this.sesionId,
    estudianteUid: estudianteUid ?? this.estudianteUid,
    estudianteNombre: estudianteNombre ?? this.estudianteNombre,
    tutorUid: tutorUid ?? this.tutorUid,
    estado: estado ?? this.estado,
    updatedAt: updatedAt ?? this.updatedAt,
    asignaturaNombre: asignaturaNombre ?? this.asignaturaNombre,
    inicioSesion: inicioSesion.present ? inicioSesion.value : this.inicioSesion,
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
      estudianteNombre: data.estudianteNombre.present
          ? data.estudianteNombre.value
          : this.estudianteNombre,
      tutorUid: data.tutorUid.present ? data.tutorUid.value : this.tutorUid,
      estado: data.estado.present ? data.estado.value : this.estado,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      asignaturaNombre: data.asignaturaNombre.present
          ? data.asignaturaNombre.value
          : this.asignaturaNombre,
      inicioSesion: data.inicioSesion.present
          ? data.inicioSesion.value
          : this.inicioSesion,
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
          ..write('estudianteNombre: $estudianteNombre, ')
          ..write('tutorUid: $tutorUid, ')
          ..write('estado: $estado, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('asignaturaNombre: $asignaturaNombre, ')
          ..write('inicioSesion: $inicioSesion, ')
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
    estudianteNombre,
    tutorUid,
    estado,
    updatedAt,
    asignaturaNombre,
    inicioSesion,
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
          other.estudianteNombre == this.estudianteNombre &&
          other.tutorUid == this.tutorUid &&
          other.estado == this.estado &&
          other.updatedAt == this.updatedAt &&
          other.asignaturaNombre == this.asignaturaNombre &&
          other.inicioSesion == this.inicioSesion &&
          other.pendingSync == this.pendingSync &&
          other.ultimoError == this.ultimoError);
}

class InscripcionesCompanion extends UpdateCompanion<InscripcionRow> {
  final Value<String> id;
  final Value<String> sesionId;
  final Value<String> estudianteUid;
  final Value<String> estudianteNombre;
  final Value<String> tutorUid;
  final Value<String> estado;
  final Value<DateTime> updatedAt;
  final Value<String> asignaturaNombre;
  final Value<DateTime?> inicioSesion;
  final Value<bool> pendingSync;
  final Value<String?> ultimoError;
  final Value<int> rowid;
  const InscripcionesCompanion({
    this.id = const Value.absent(),
    this.sesionId = const Value.absent(),
    this.estudianteUid = const Value.absent(),
    this.estudianteNombre = const Value.absent(),
    this.tutorUid = const Value.absent(),
    this.estado = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.asignaturaNombre = const Value.absent(),
    this.inicioSesion = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.ultimoError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InscripcionesCompanion.insert({
    required String id,
    required String sesionId,
    required String estudianteUid,
    this.estudianteNombre = const Value.absent(),
    this.tutorUid = const Value.absent(),
    required String estado,
    required DateTime updatedAt,
    this.asignaturaNombre = const Value.absent(),
    this.inicioSesion = const Value.absent(),
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
    Expression<String>? estudianteNombre,
    Expression<String>? tutorUid,
    Expression<String>? estado,
    Expression<DateTime>? updatedAt,
    Expression<String>? asignaturaNombre,
    Expression<DateTime>? inicioSesion,
    Expression<bool>? pendingSync,
    Expression<String>? ultimoError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sesionId != null) 'sesion_id': sesionId,
      if (estudianteUid != null) 'estudiante_uid': estudianteUid,
      if (estudianteNombre != null) 'estudiante_nombre': estudianteNombre,
      if (tutorUid != null) 'tutor_uid': tutorUid,
      if (estado != null) 'estado': estado,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (asignaturaNombre != null) 'asignatura_nombre': asignaturaNombre,
      if (inicioSesion != null) 'inicio_sesion': inicioSesion,
      if (pendingSync != null) 'pending_sync': pendingSync,
      if (ultimoError != null) 'ultimo_error': ultimoError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InscripcionesCompanion copyWith({
    Value<String>? id,
    Value<String>? sesionId,
    Value<String>? estudianteUid,
    Value<String>? estudianteNombre,
    Value<String>? tutorUid,
    Value<String>? estado,
    Value<DateTime>? updatedAt,
    Value<String>? asignaturaNombre,
    Value<DateTime?>? inicioSesion,
    Value<bool>? pendingSync,
    Value<String?>? ultimoError,
    Value<int>? rowid,
  }) {
    return InscripcionesCompanion(
      id: id ?? this.id,
      sesionId: sesionId ?? this.sesionId,
      estudianteUid: estudianteUid ?? this.estudianteUid,
      estudianteNombre: estudianteNombre ?? this.estudianteNombre,
      tutorUid: tutorUid ?? this.tutorUid,
      estado: estado ?? this.estado,
      updatedAt: updatedAt ?? this.updatedAt,
      asignaturaNombre: asignaturaNombre ?? this.asignaturaNombre,
      inicioSesion: inicioSesion ?? this.inicioSesion,
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
    if (estudianteNombre.present) {
      map['estudiante_nombre'] = Variable<String>(estudianteNombre.value);
    }
    if (tutorUid.present) {
      map['tutor_uid'] = Variable<String>(tutorUid.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (asignaturaNombre.present) {
      map['asignatura_nombre'] = Variable<String>(asignaturaNombre.value);
    }
    if (inicioSesion.present) {
      map['inicio_sesion'] = Variable<DateTime>(inicioSesion.value);
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
          ..write('estudianteNombre: $estudianteNombre, ')
          ..write('tutorUid: $tutorUid, ')
          ..write('estado: $estado, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('asignaturaNombre: $asignaturaNombre, ')
          ..write('inicioSesion: $inicioSesion, ')
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
      Value<String> estudianteNombre,
      Value<String> tutorUid,
      required String estado,
      required DateTime updatedAt,
      Value<String> asignaturaNombre,
      Value<DateTime?> inicioSesion,
      Value<bool> pendingSync,
      Value<String?> ultimoError,
      Value<int> rowid,
    });
typedef $$InscripcionesTableUpdateCompanionBuilder =
    InscripcionesCompanion Function({
      Value<String> id,
      Value<String> sesionId,
      Value<String> estudianteUid,
      Value<String> estudianteNombre,
      Value<String> tutorUid,
      Value<String> estado,
      Value<DateTime> updatedAt,
      Value<String> asignaturaNombre,
      Value<DateTime?> inicioSesion,
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

  ColumnFilters<String> get estudianteNombre => $composableBuilder(
    column: $table.estudianteNombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tutorUid => $composableBuilder(
    column: $table.tutorUid,
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

  ColumnFilters<String> get asignaturaNombre => $composableBuilder(
    column: $table.asignaturaNombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get inicioSesion => $composableBuilder(
    column: $table.inicioSesion,
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

  ColumnOrderings<String> get estudianteNombre => $composableBuilder(
    column: $table.estudianteNombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tutorUid => $composableBuilder(
    column: $table.tutorUid,
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

  ColumnOrderings<String> get asignaturaNombre => $composableBuilder(
    column: $table.asignaturaNombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get inicioSesion => $composableBuilder(
    column: $table.inicioSesion,
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

  GeneratedColumn<String> get estudianteNombre => $composableBuilder(
    column: $table.estudianteNombre,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tutorUid =>
      $composableBuilder(column: $table.tutorUid, builder: (column) => column);

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get asignaturaNombre => $composableBuilder(
    column: $table.asignaturaNombre,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get inicioSesion => $composableBuilder(
    column: $table.inicioSesion,
    builder: (column) => column,
  );

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
                Value<String> estudianteNombre = const Value.absent(),
                Value<String> tutorUid = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> asignaturaNombre = const Value.absent(),
                Value<DateTime?> inicioSesion = const Value.absent(),
                Value<bool> pendingSync = const Value.absent(),
                Value<String?> ultimoError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InscripcionesCompanion(
                id: id,
                sesionId: sesionId,
                estudianteUid: estudianteUid,
                estudianteNombre: estudianteNombre,
                tutorUid: tutorUid,
                estado: estado,
                updatedAt: updatedAt,
                asignaturaNombre: asignaturaNombre,
                inicioSesion: inicioSesion,
                pendingSync: pendingSync,
                ultimoError: ultimoError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sesionId,
                required String estudianteUid,
                Value<String> estudianteNombre = const Value.absent(),
                Value<String> tutorUid = const Value.absent(),
                required String estado,
                required DateTime updatedAt,
                Value<String> asignaturaNombre = const Value.absent(),
                Value<DateTime?> inicioSesion = const Value.absent(),
                Value<bool> pendingSync = const Value.absent(),
                Value<String?> ultimoError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InscripcionesCompanion.insert(
                id: id,
                sesionId: sesionId,
                estudianteUid: estudianteUid,
                estudianteNombre: estudianteNombre,
                tutorUid: tutorUid,
                estado: estado,
                updatedAt: updatedAt,
                asignaturaNombre: asignaturaNombre,
                inicioSesion: inicioSesion,
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
