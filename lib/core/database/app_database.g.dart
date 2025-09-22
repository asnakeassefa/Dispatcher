// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TripTableTable extends TripTable
    with TableInfo<$TripTableTable, TripTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assignedVehicleIdMeta = const VerificationMeta(
    'assignedVehicleId',
  );
  @override
  late final GeneratedColumn<String> assignedVehicleId =
      GeneratedColumn<String>(
        'assigned_vehicle_id',
        aliasedName,
        true,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 1,
          maxTextLength: 50,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  assignedOrderIds = GeneratedColumn<String>(
    'assigned_order_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<List<String>>($TripTableTable.$converterassignedOrderIds);
  static const VerificationMeta _statusIndexMeta = const VerificationMeta(
    'statusIndex',
  );
  @override
  late final GeneratedColumn<int> statusIndex = GeneratedColumn<int>(
    'status_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    date,
    assignedVehicleId,
    assignedOrderIds,
    statusIndex,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trip_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('assigned_vehicle_id')) {
      context.handle(
        _assignedVehicleIdMeta,
        assignedVehicleId.isAcceptableOrUnknown(
          data['assigned_vehicle_id']!,
          _assignedVehicleIdMeta,
        ),
      );
    }
    if (data.containsKey('status_index')) {
      context.handle(
        _statusIndexMeta,
        statusIndex.isAcceptableOrUnknown(
          data['status_index']!,
          _statusIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_statusIndexMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TripTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      assignedVehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assigned_vehicle_id'],
      ),
      assignedOrderIds: $TripTableTable.$converterassignedOrderIds.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}assigned_order_ids'],
        )!,
      ),
      statusIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status_index'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TripTableTable createAlias(String alias) {
    return $TripTableTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterassignedOrderIds =
      const OrderIdsConverter();
}

class TripTableData extends DataClass implements Insertable<TripTableData> {
  final int id;
  final String tripId;
  final DateTime date;
  final String? assignedVehicleId;
  final List<String> assignedOrderIds;
  final int statusIndex;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TripTableData({
    required this.id,
    required this.tripId,
    required this.date,
    this.assignedVehicleId,
    required this.assignedOrderIds,
    required this.statusIndex,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || assignedVehicleId != null) {
      map['assigned_vehicle_id'] = Variable<String>(assignedVehicleId);
    }
    {
      map['assigned_order_ids'] = Variable<String>(
        $TripTableTable.$converterassignedOrderIds.toSql(assignedOrderIds),
      );
    }
    map['status_index'] = Variable<int>(statusIndex);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TripTableCompanion toCompanion(bool nullToAbsent) {
    return TripTableCompanion(
      id: Value(id),
      tripId: Value(tripId),
      date: Value(date),
      assignedVehicleId: assignedVehicleId == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedVehicleId),
      assignedOrderIds: Value(assignedOrderIds),
      statusIndex: Value(statusIndex),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TripTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripTableData(
      id: serializer.fromJson<int>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      date: serializer.fromJson<DateTime>(json['date']),
      assignedVehicleId: serializer.fromJson<String?>(
        json['assignedVehicleId'],
      ),
      assignedOrderIds: serializer.fromJson<List<String>>(
        json['assignedOrderIds'],
      ),
      statusIndex: serializer.fromJson<int>(json['statusIndex']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tripId': serializer.toJson<String>(tripId),
      'date': serializer.toJson<DateTime>(date),
      'assignedVehicleId': serializer.toJson<String?>(assignedVehicleId),
      'assignedOrderIds': serializer.toJson<List<String>>(assignedOrderIds),
      'statusIndex': serializer.toJson<int>(statusIndex),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TripTableData copyWith({
    int? id,
    String? tripId,
    DateTime? date,
    Value<String?> assignedVehicleId = const Value.absent(),
    List<String>? assignedOrderIds,
    int? statusIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TripTableData(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    date: date ?? this.date,
    assignedVehicleId: assignedVehicleId.present
        ? assignedVehicleId.value
        : this.assignedVehicleId,
    assignedOrderIds: assignedOrderIds ?? this.assignedOrderIds,
    statusIndex: statusIndex ?? this.statusIndex,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TripTableData copyWithCompanion(TripTableCompanion data) {
    return TripTableData(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      date: data.date.present ? data.date.value : this.date,
      assignedVehicleId: data.assignedVehicleId.present
          ? data.assignedVehicleId.value
          : this.assignedVehicleId,
      assignedOrderIds: data.assignedOrderIds.present
          ? data.assignedOrderIds.value
          : this.assignedOrderIds,
      statusIndex: data.statusIndex.present
          ? data.statusIndex.value
          : this.statusIndex,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripTableData(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('date: $date, ')
          ..write('assignedVehicleId: $assignedVehicleId, ')
          ..write('assignedOrderIds: $assignedOrderIds, ')
          ..write('statusIndex: $statusIndex, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    date,
    assignedVehicleId,
    assignedOrderIds,
    statusIndex,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripTableData &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.date == this.date &&
          other.assignedVehicleId == this.assignedVehicleId &&
          other.assignedOrderIds == this.assignedOrderIds &&
          other.statusIndex == this.statusIndex &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TripTableCompanion extends UpdateCompanion<TripTableData> {
  final Value<int> id;
  final Value<String> tripId;
  final Value<DateTime> date;
  final Value<String?> assignedVehicleId;
  final Value<List<String>> assignedOrderIds;
  final Value<int> statusIndex;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const TripTableCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.date = const Value.absent(),
    this.assignedVehicleId = const Value.absent(),
    this.assignedOrderIds = const Value.absent(),
    this.statusIndex = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TripTableCompanion.insert({
    this.id = const Value.absent(),
    required String tripId,
    required DateTime date,
    this.assignedVehicleId = const Value.absent(),
    required List<String> assignedOrderIds,
    required int statusIndex,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : tripId = Value(tripId),
       date = Value(date),
       assignedOrderIds = Value(assignedOrderIds),
       statusIndex = Value(statusIndex);
  static Insertable<TripTableData> custom({
    Expression<int>? id,
    Expression<String>? tripId,
    Expression<DateTime>? date,
    Expression<String>? assignedVehicleId,
    Expression<String>? assignedOrderIds,
    Expression<int>? statusIndex,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (date != null) 'date': date,
      if (assignedVehicleId != null) 'assigned_vehicle_id': assignedVehicleId,
      if (assignedOrderIds != null) 'assigned_order_ids': assignedOrderIds,
      if (statusIndex != null) 'status_index': statusIndex,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TripTableCompanion copyWith({
    Value<int>? id,
    Value<String>? tripId,
    Value<DateTime>? date,
    Value<String?>? assignedVehicleId,
    Value<List<String>>? assignedOrderIds,
    Value<int>? statusIndex,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return TripTableCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      date: date ?? this.date,
      assignedVehicleId: assignedVehicleId ?? this.assignedVehicleId,
      assignedOrderIds: assignedOrderIds ?? this.assignedOrderIds,
      statusIndex: statusIndex ?? this.statusIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (assignedVehicleId.present) {
      map['assigned_vehicle_id'] = Variable<String>(assignedVehicleId.value);
    }
    if (assignedOrderIds.present) {
      map['assigned_order_ids'] = Variable<String>(
        $TripTableTable.$converterassignedOrderIds.toSql(
          assignedOrderIds.value,
        ),
      );
    }
    if (statusIndex.present) {
      map['status_index'] = Variable<int>(statusIndex.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripTableCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('date: $date, ')
          ..write('assignedVehicleId: $assignedVehicleId, ')
          ..write('assignedOrderIds: $assignedOrderIds, ')
          ..write('statusIndex: $statusIndex, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TripTableTable tripTable = $TripTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [tripTable];
}

typedef $$TripTableTableCreateCompanionBuilder =
    TripTableCompanion Function({
      Value<int> id,
      required String tripId,
      required DateTime date,
      Value<String?> assignedVehicleId,
      required List<String> assignedOrderIds,
      required int statusIndex,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$TripTableTableUpdateCompanionBuilder =
    TripTableCompanion Function({
      Value<int> id,
      Value<String> tripId,
      Value<DateTime> date,
      Value<String?> assignedVehicleId,
      Value<List<String>> assignedOrderIds,
      Value<int> statusIndex,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$TripTableTableFilterComposer
    extends Composer<_$AppDatabase, $TripTableTable> {
  $$TripTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assignedVehicleId => $composableBuilder(
    column: $table.assignedVehicleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get assignedOrderIds => $composableBuilder(
    column: $table.assignedOrderIds,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get statusIndex => $composableBuilder(
    column: $table.statusIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TripTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TripTableTable> {
  $$TripTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assignedVehicleId => $composableBuilder(
    column: $table.assignedVehicleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assignedOrderIds => $composableBuilder(
    column: $table.assignedOrderIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get statusIndex => $composableBuilder(
    column: $table.statusIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TripTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripTableTable> {
  $$TripTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get assignedVehicleId => $composableBuilder(
    column: $table.assignedVehicleId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>, String> get assignedOrderIds =>
      $composableBuilder(
        column: $table.assignedOrderIds,
        builder: (column) => column,
      );

  GeneratedColumn<int> get statusIndex => $composableBuilder(
    column: $table.statusIndex,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TripTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripTableTable,
          TripTableData,
          $$TripTableTableFilterComposer,
          $$TripTableTableOrderingComposer,
          $$TripTableTableAnnotationComposer,
          $$TripTableTableCreateCompanionBuilder,
          $$TripTableTableUpdateCompanionBuilder,
          (
            TripTableData,
            BaseReferences<_$AppDatabase, $TripTableTable, TripTableData>,
          ),
          TripTableData,
          PrefetchHooks Function()
        > {
  $$TripTableTableTableManager(_$AppDatabase db, $TripTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> assignedVehicleId = const Value.absent(),
                Value<List<String>> assignedOrderIds = const Value.absent(),
                Value<int> statusIndex = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TripTableCompanion(
                id: id,
                tripId: tripId,
                date: date,
                assignedVehicleId: assignedVehicleId,
                assignedOrderIds: assignedOrderIds,
                statusIndex: statusIndex,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String tripId,
                required DateTime date,
                Value<String?> assignedVehicleId = const Value.absent(),
                required List<String> assignedOrderIds,
                required int statusIndex,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TripTableCompanion.insert(
                id: id,
                tripId: tripId,
                date: date,
                assignedVehicleId: assignedVehicleId,
                assignedOrderIds: assignedOrderIds,
                statusIndex: statusIndex,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TripTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripTableTable,
      TripTableData,
      $$TripTableTableFilterComposer,
      $$TripTableTableOrderingComposer,
      $$TripTableTableAnnotationComposer,
      $$TripTableTableCreateCompanionBuilder,
      $$TripTableTableUpdateCompanionBuilder,
      (
        TripTableData,
        BaseReferences<_$AppDatabase, $TripTableTable, TripTableData>,
      ),
      TripTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TripTableTableTableManager get tripTable =>
      $$TripTableTableTableManager(_db, _db.tripTable);
}
