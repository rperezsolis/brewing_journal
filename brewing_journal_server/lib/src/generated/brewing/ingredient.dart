/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_null_comparison

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:brewing_journal_server/src/generated/protocol.dart'
    as _i8dlmk64;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import '../brewing/beverage_kind.dart' as _ingr617k;
import '../brewing/roast_level.dart' as _ibx1prgb;

abstract class Ingredient
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  Ingredient._({
    this.id,
    required this.ownerId,
    this.owner,
    required this.kind,
    required this.name,
    required this.nameKey,
    this.origin,
    this.roaster,
    this.roastLevel,
    this.processing,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Ingredient({
    _is.UuidValue? id,
    required _is.UuidValue ownerId,
    _iacs.AuthUser? owner,
    required _ingr617k.BeverageKind kind,
    required String name,
    required String nameKey,
    String? origin,
    String? roaster,
    _ibx1prgb.RoastLevel? roastLevel,
    String? processing,
    DateTime? createdAt,
  }) = _IngredientImpl;

  factory Ingredient.fromJson(Map<String, dynamic> jsonSerialization) {
    return Ingredient(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      ownerId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['ownerId'],
      ),
      owner: jsonSerialization['owner'] == null
          ? null
          : _i8dlmk64.Protocol().deserialize<_iacs.AuthUser>(
              jsonSerialization['owner'],
            ),
      kind: _ingr617k.BeverageKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      name: jsonSerialization['name'] as String,
      nameKey: jsonSerialization['nameKey'] as String,
      origin: jsonSerialization['origin'] as String?,
      roaster: jsonSerialization['roaster'] as String?,
      roastLevel: jsonSerialization['roastLevel'] == null
          ? null
          : _ibx1prgb.RoastLevel.fromJson(
              (jsonSerialization['roastLevel'] as String),
            ),
      processing: jsonSerialization['processing'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = IngredientTable();

  static const db = IngredientRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue ownerId;

  _iacs.AuthUser? owner;

  _ingr617k.BeverageKind kind;

  String name;

  String nameKey;

  String? origin;

  String? roaster;

  _ibx1prgb.RoastLevel? roastLevel;

  String? processing;

  DateTime createdAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Ingredient]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Ingredient copyWith({
    _is.UuidValue? id,
    _is.UuidValue? ownerId,
    _iacs.AuthUser? owner,
    _ingr617k.BeverageKind? kind,
    String? name,
    String? nameKey,
    String? origin,
    String? roaster,
    _ibx1prgb.RoastLevel? roastLevel,
    String? processing,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Ingredient',
      if (id != null) 'id': id?.toJson(),
      'ownerId': ownerId.toJson(),
      if (owner != null) 'owner': owner?.toJson(),
      'kind': kind.toJson(),
      'name': name,
      'nameKey': nameKey,
      if (origin != null) 'origin': origin,
      if (roaster != null) 'roaster': roaster,
      if (roastLevel != null) 'roastLevel': roastLevel?.toJson(),
      if (processing != null) 'processing': processing,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Ingredient',
      if (id != null) 'id': id?.toJson(),
      'ownerId': ownerId.toJson(),
      if (owner != null) 'owner': owner?.toJson(),
      'kind': kind.toJson(),
      'name': name,
      'nameKey': nameKey,
      if (origin != null) 'origin': origin,
      if (roaster != null) 'roaster': roaster,
      if (roastLevel != null) 'roastLevel': roastLevel?.toJson(),
      if (processing != null) 'processing': processing,
      'createdAt': createdAt.toJson(),
    };
  }

  static IngredientInclude include({_iacs.AuthUserInclude? owner}) {
    return IngredientInclude._(owner: owner);
  }

  static IngredientIncludeList includeList({
    _is.WhereExpressionBuilder<IngredientTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<IngredientTable>? orderBy,
    _is.OrderByListBuilder<IngredientTable>? orderByList,
    IngredientInclude? include,
  }) {
    return IngredientIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Ingredient.t),
      orderByList: orderByList?.call(Ingredient.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IngredientImpl extends Ingredient {
  _IngredientImpl({
    _is.UuidValue? id,
    required _is.UuidValue ownerId,
    _iacs.AuthUser? owner,
    required _ingr617k.BeverageKind kind,
    required String name,
    required String nameKey,
    String? origin,
    String? roaster,
    _ibx1prgb.RoastLevel? roastLevel,
    String? processing,
    DateTime? createdAt,
  }) : super._(
         id: id,
         ownerId: ownerId,
         owner: owner,
         kind: kind,
         name: name,
         nameKey: nameKey,
         origin: origin,
         roaster: roaster,
         roastLevel: roastLevel,
         processing: processing,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Ingredient]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Ingredient copyWith({
    Object? id = _Undefined,
    _is.UuidValue? ownerId,
    Object? owner = _Undefined,
    _ingr617k.BeverageKind? kind,
    String? name,
    String? nameKey,
    Object? origin = _Undefined,
    Object? roaster = _Undefined,
    Object? roastLevel = _Undefined,
    Object? processing = _Undefined,
    DateTime? createdAt,
  }) {
    return Ingredient(
      id: id is _is.UuidValue? ? id : this.id,
      ownerId: ownerId ?? this.ownerId,
      owner: owner is _iacs.AuthUser? ? owner : this.owner?.copyWith(),
      kind: kind ?? this.kind,
      name: name ?? this.name,
      nameKey: nameKey ?? this.nameKey,
      origin: origin is String? ? origin : this.origin,
      roaster: roaster is String? ? roaster : this.roaster,
      roastLevel: roastLevel is _ibx1prgb.RoastLevel?
          ? roastLevel
          : this.roastLevel,
      processing: processing is String? ? processing : this.processing,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class IngredientUpdateTable extends _is.UpdateTable<IngredientTable> {
  IngredientUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> ownerId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.ownerId,
        value,
      );

  _is.ColumnValue<_ingr617k.BeverageKind, _ingr617k.BeverageKind> kind(
    _ingr617k.BeverageKind value,
  ) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<String, String> nameKey(String value) => _is.ColumnValue(
    table.nameKey,
    value,
  );

  _is.ColumnValue<String, String> origin(String? value) => _is.ColumnValue(
    table.origin,
    value,
  );

  _is.ColumnValue<String, String> roaster(String? value) => _is.ColumnValue(
    table.roaster,
    value,
  );

  _is.ColumnValue<_ibx1prgb.RoastLevel, _ibx1prgb.RoastLevel> roastLevel(
    _ibx1prgb.RoastLevel? value,
  ) => _is.ColumnValue(
    table.roastLevel,
    value,
  );

  _is.ColumnValue<String, String> processing(String? value) => _is.ColumnValue(
    table.processing,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class IngredientTable extends _is.Table<_is.UuidValue?> {
  IngredientTable({super.tableRelation}) : super(tableName: 'ingredient') {
    updateTable = IngredientUpdateTable(this);
    ownerId = _is.ColumnUuid(
      'ownerId',
      this,
    );
    kind = _is.ColumnEnum(
      'kind',
      this,
      _is.EnumSerialization.byName,
    );
    name = _is.ColumnString(
      'name',
      this,
    );
    nameKey = _is.ColumnString(
      'nameKey',
      this,
    );
    origin = _is.ColumnString(
      'origin',
      this,
    );
    roaster = _is.ColumnString(
      'roaster',
      this,
    );
    roastLevel = _is.ColumnEnum(
      'roastLevel',
      this,
      _is.EnumSerialization.byName,
    );
    processing = _is.ColumnString(
      'processing',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final IngredientUpdateTable updateTable;

  late final _is.ColumnUuid ownerId;

  _iacs.AuthUserTable? _owner;

  late final _is.ColumnEnum<_ingr617k.BeverageKind> kind;

  late final _is.ColumnString name;

  late final _is.ColumnString nameKey;

  late final _is.ColumnString origin;

  late final _is.ColumnString roaster;

  late final _is.ColumnEnum<_ibx1prgb.RoastLevel> roastLevel;

  late final _is.ColumnString processing;

  late final _is.ColumnDateTime createdAt;

  _iacs.AuthUserTable get owner {
    if (_owner != null) return _owner!;
    _owner = _is.createRelationTable(
      relationFieldName: 'owner',
      field: Ingredient.t.ownerId,
      foreignField: _iacs.AuthUser.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _iacs.AuthUserTable(tableRelation: foreignTableRelation),
    );
    return _owner!;
  }

  @override
  List<_is.Column> get columns => [
    id,
    ownerId,
    kind,
    name,
    nameKey,
    origin,
    roaster,
    roastLevel,
    processing,
    createdAt,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'owner') {
      return owner;
    }
    return null;
  }
}

class IngredientInclude extends _is.IncludeObject {
  IngredientInclude._({_iacs.AuthUserInclude? owner}) {
    _owner = owner;
  }

  _iacs.AuthUserInclude? _owner;

  @override
  Map<String, _is.Include?> get includes => {'owner': _owner};

  @override
  _is.Table<_is.UuidValue?> get table => Ingredient.t;
}

class IngredientIncludeList extends _is.IncludeList {
  IngredientIncludeList._({
    _is.WhereExpressionBuilder<IngredientTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Ingredient.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => Ingredient.t;
}

class IngredientRepository {
  const IngredientRepository._();

  final attachRow = const IngredientAttachRowRepository._();

  /// Returns a list of [Ingredient]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<Ingredient>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<IngredientTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<IngredientTable>? orderBy,
    _is.OrderByListBuilder<IngredientTable>? orderByList,
    _is.Transaction? transaction,
    IngredientInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Ingredient>(
      where: where?.call(Ingredient.t),
      orderBy: orderBy?.call(Ingredient.t),
      orderByList: orderByList?.call(Ingredient.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Ingredient] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<Ingredient?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<IngredientTable>? where,
    int? offset,
    _is.OrderByBuilder<IngredientTable>? orderBy,
    _is.OrderByListBuilder<IngredientTable>? orderByList,
    _is.Transaction? transaction,
    IngredientInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Ingredient>(
      where: where?.call(Ingredient.t),
      orderBy: orderBy?.call(Ingredient.t),
      orderByList: orderByList?.call(Ingredient.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Ingredient] by its [id] or null if no such row exists.
  Future<Ingredient?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    IngredientInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Ingredient>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Ingredient]s in the list and returns the inserted rows.
  ///
  /// The returned [Ingredient]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Ingredient>> insert(
    _is.DatabaseSession session,
    List<Ingredient> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Ingredient>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Ingredient] and returns the inserted row.
  ///
  /// The returned [Ingredient] will have its `id` field set.
  Future<Ingredient> insertRow(
    _is.DatabaseSession session,
    Ingredient row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Ingredient>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Ingredient]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [Ingredient]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Ingredient>> upsert(
    _is.DatabaseSession session,
    List<Ingredient> rows, {
    required _is.ColumnSelections<IngredientTable> conflictColumns,
    _is.ColumnSelections<IngredientTable>? updateColumns,
    _is.WhereExpressionBuilder<IngredientTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Ingredient>(
      rows,
      conflictColumns: conflictColumns(Ingredient.t),
      updateColumns: updateColumns?.call(Ingredient.t),
      updateWhere: updateWhere?.call(Ingredient.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Ingredient] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [Ingredient] will have its `id` field set.
  Future<Ingredient?> upsertRow(
    _is.DatabaseSession session,
    Ingredient row, {
    required _is.ColumnSelections<IngredientTable> conflictColumns,
    _is.ColumnSelections<IngredientTable>? updateColumns,
    _is.WhereExpressionBuilder<IngredientTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Ingredient>(
      row,
      conflictColumns: conflictColumns(Ingredient.t),
      updateColumns: updateColumns?.call(Ingredient.t),
      updateWhere: updateWhere?.call(Ingredient.t),
      transaction: transaction,
    );
  }

  /// Updates all [Ingredient]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Ingredient>> update(
    _is.DatabaseSession session,
    List<Ingredient> rows, {
    _is.ColumnSelections<IngredientTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Ingredient>(
      rows,
      columns: columns?.call(Ingredient.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Ingredient]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Ingredient> updateRow(
    _is.DatabaseSession session,
    Ingredient row, {
    _is.ColumnSelections<IngredientTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Ingredient>(
      row,
      columns: columns?.call(Ingredient.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Ingredient] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Ingredient?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<IngredientUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Ingredient>(
      id,
      columnValues: columnValues(Ingredient.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Ingredient]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Ingredient>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<IngredientUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<IngredientTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<IngredientTable>? orderBy,
    _is.OrderByListBuilder<IngredientTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Ingredient>(
      columnValues: columnValues(Ingredient.t.updateTable),
      where: where(Ingredient.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Ingredient.t),
      orderByList: orderByList?.call(Ingredient.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Ingredient]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Ingredient>> delete(
    _is.DatabaseSession session,
    List<Ingredient> rows, {
    _is.OrderByBuilder<IngredientTable>? orderBy,
    _is.OrderByListBuilder<IngredientTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Ingredient>(
      rows,
      orderBy: orderBy?.call(Ingredient.t),
      orderByList: orderByList?.call(Ingredient.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Ingredient].
  Future<Ingredient> deleteRow(
    _is.DatabaseSession session,
    Ingredient row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Ingredient>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Ingredient>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<IngredientTable> where,
    _is.OrderByBuilder<IngredientTable>? orderBy,
    _is.OrderByListBuilder<IngredientTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Ingredient>(
      where: where(Ingredient.t),
      orderBy: orderBy?.call(Ingredient.t),
      orderByList: orderByList?.call(Ingredient.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<IngredientTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Ingredient>(
      where: where?.call(Ingredient.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Ingredient] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<IngredientTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Ingredient>(
      where: where(Ingredient.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class IngredientAttachRowRepository {
  const IngredientAttachRowRepository._();

  /// Creates a relation between the given [Ingredient] and [AuthUser]
  /// by setting the [Ingredient]'s foreign key `ownerId` to refer to the [AuthUser].
  Future<void> owner(
    _is.DatabaseSession session,
    Ingredient ingredient,
    _iacs.AuthUser owner, {
    _is.Transaction? transaction,
  }) async {
    if (ingredient.id == null) {
      throw ArgumentError.notNull('ingredient.id');
    }
    if (owner.id == null) {
      throw ArgumentError.notNull('owner.id');
    }

    var $ingredient = ingredient.copyWith(ownerId: owner.id);
    await session.db.updateRow<Ingredient>(
      $ingredient,
      columns: [Ingredient.t.ownerId],
      transaction: transaction,
    );
  }
}
