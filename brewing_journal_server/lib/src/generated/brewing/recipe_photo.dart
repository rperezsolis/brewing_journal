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
import '../brewing/recipe.dart' as _iuy009ee;

abstract class RecipePhoto
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  RecipePhoto._({
    this.id,
    required this.recipeId,
    this.recipe,
    required this.storagePath,
    required this.sortOrder,
    DateTime? createdAt,
    this.publicUrl,
  }) : createdAt = createdAt ?? DateTime.now();

  factory RecipePhoto({
    _is.UuidValue? id,
    required _is.UuidValue recipeId,
    _iuy009ee.Recipe? recipe,
    required String storagePath,
    required int sortOrder,
    DateTime? createdAt,
    Uri? publicUrl,
  }) = _RecipePhotoImpl;

  factory RecipePhoto.fromJson(Map<String, dynamic> jsonSerialization) {
    return RecipePhoto(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      recipeId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['recipeId'],
      ),
      recipe: jsonSerialization['recipe'] == null
          ? null
          : _i8dlmk64.Protocol().deserialize<_iuy009ee.Recipe>(
              jsonSerialization['recipe'],
            ),
      storagePath: jsonSerialization['storagePath'] as String,
      sortOrder: jsonSerialization['sortOrder'] as int,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      publicUrl: jsonSerialization['publicUrl'] == null
          ? null
          : _is.UriJsonExtension.fromJson(jsonSerialization['publicUrl']),
    );
  }

  static final t = RecipePhotoTable();

  static const db = RecipePhotoRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue recipeId;

  _iuy009ee.Recipe? recipe;

  String storagePath;

  int sortOrder;

  DateTime createdAt;

  Uri? publicUrl;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [RecipePhoto]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RecipePhoto copyWith({
    _is.UuidValue? id,
    _is.UuidValue? recipeId,
    _iuy009ee.Recipe? recipe,
    String? storagePath,
    int? sortOrder,
    DateTime? createdAt,
    Uri? publicUrl,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RecipePhoto',
      if (id != null) 'id': id?.toJson(),
      'recipeId': recipeId.toJson(),
      if (recipe != null) 'recipe': recipe?.toJson(),
      'storagePath': storagePath,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toJson(),
      if (publicUrl != null) 'publicUrl': publicUrl?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RecipePhoto',
      if (id != null) 'id': id?.toJson(),
      'recipeId': recipeId.toJson(),
      if (recipe != null) 'recipe': recipe?.toJsonForProtocol(),
      'storagePath': storagePath,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toJson(),
      if (publicUrl != null) 'publicUrl': publicUrl?.toJson(),
    };
  }

  static RecipePhotoInclude include({_iuy009ee.RecipeInclude? recipe}) {
    return RecipePhotoInclude._(recipe: recipe);
  }

  static RecipePhotoIncludeList includeList({
    _is.WhereExpressionBuilder<RecipePhotoTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RecipePhotoTable>? orderBy,
    _is.OrderByListBuilder<RecipePhotoTable>? orderByList,
    RecipePhotoInclude? include,
  }) {
    return RecipePhotoIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RecipePhoto.t),
      orderByList: orderByList?.call(RecipePhoto.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RecipePhotoImpl extends RecipePhoto {
  _RecipePhotoImpl({
    _is.UuidValue? id,
    required _is.UuidValue recipeId,
    _iuy009ee.Recipe? recipe,
    required String storagePath,
    required int sortOrder,
    DateTime? createdAt,
    Uri? publicUrl,
  }) : super._(
         id: id,
         recipeId: recipeId,
         recipe: recipe,
         storagePath: storagePath,
         sortOrder: sortOrder,
         createdAt: createdAt,
         publicUrl: publicUrl,
       );

  /// Returns a shallow copy of this [RecipePhoto]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RecipePhoto copyWith({
    Object? id = _Undefined,
    _is.UuidValue? recipeId,
    Object? recipe = _Undefined,
    String? storagePath,
    int? sortOrder,
    DateTime? createdAt,
    Object? publicUrl = _Undefined,
  }) {
    return RecipePhoto(
      id: id is _is.UuidValue? ? id : this.id,
      recipeId: recipeId ?? this.recipeId,
      recipe: recipe is _iuy009ee.Recipe? ? recipe : this.recipe?.copyWith(),
      storagePath: storagePath ?? this.storagePath,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      publicUrl: publicUrl is Uri? ? publicUrl : this.publicUrl,
    );
  }
}

class RecipePhotoUpdateTable extends _is.UpdateTable<RecipePhotoTable> {
  RecipePhotoUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> recipeId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.recipeId,
        value,
      );

  _is.ColumnValue<String, String> storagePath(String value) => _is.ColumnValue(
    table.storagePath,
    value,
  );

  _is.ColumnValue<int, int> sortOrder(int value) => _is.ColumnValue(
    table.sortOrder,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class RecipePhotoTable extends _is.Table<_is.UuidValue?> {
  RecipePhotoTable({super.tableRelation}) : super(tableName: 'recipe_photo') {
    updateTable = RecipePhotoUpdateTable(this);
    recipeId = _is.ColumnUuid(
      'recipeId',
      this,
    );
    storagePath = _is.ColumnString(
      'storagePath',
      this,
    );
    sortOrder = _is.ColumnInt(
      'sortOrder',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final RecipePhotoUpdateTable updateTable;

  late final _is.ColumnUuid recipeId;

  _iuy009ee.RecipeTable? _recipe;

  late final _is.ColumnString storagePath;

  late final _is.ColumnInt sortOrder;

  late final _is.ColumnDateTime createdAt;

  _iuy009ee.RecipeTable get recipe {
    if (_recipe != null) return _recipe!;
    _recipe = _is.createRelationTable(
      relationFieldName: 'recipe',
      field: RecipePhoto.t.recipeId,
      foreignField: _iuy009ee.Recipe.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _iuy009ee.RecipeTable(tableRelation: foreignTableRelation),
    );
    return _recipe!;
  }

  @override
  List<_is.Column> get columns => [
    id,
    recipeId,
    storagePath,
    sortOrder,
    createdAt,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'recipe') {
      return recipe;
    }
    return null;
  }
}

class RecipePhotoInclude extends _is.IncludeObject {
  RecipePhotoInclude._({_iuy009ee.RecipeInclude? recipe}) {
    _recipe = recipe;
  }

  _iuy009ee.RecipeInclude? _recipe;

  @override
  Map<String, _is.Include?> get includes => {'recipe': _recipe};

  @override
  _is.Table<_is.UuidValue?> get table => RecipePhoto.t;
}

class RecipePhotoIncludeList extends _is.IncludeList {
  RecipePhotoIncludeList._({
    _is.WhereExpressionBuilder<RecipePhotoTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(RecipePhoto.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => RecipePhoto.t;
}

class RecipePhotoRepository {
  const RecipePhotoRepository._();

  final attachRow = const RecipePhotoAttachRowRepository._();

  /// Returns a list of [RecipePhoto]s matching the given query parameters.
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
  Future<List<RecipePhoto>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RecipePhotoTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RecipePhotoTable>? orderBy,
    _is.OrderByListBuilder<RecipePhotoTable>? orderByList,
    _is.Transaction? transaction,
    RecipePhotoInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<RecipePhoto>(
      where: where?.call(RecipePhoto.t),
      orderBy: orderBy?.call(RecipePhoto.t),
      orderByList: orderByList?.call(RecipePhoto.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [RecipePhoto] matching the given query parameters.
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
  Future<RecipePhoto?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RecipePhotoTable>? where,
    int? offset,
    _is.OrderByBuilder<RecipePhotoTable>? orderBy,
    _is.OrderByListBuilder<RecipePhotoTable>? orderByList,
    _is.Transaction? transaction,
    RecipePhotoInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<RecipePhoto>(
      where: where?.call(RecipePhoto.t),
      orderBy: orderBy?.call(RecipePhoto.t),
      orderByList: orderByList?.call(RecipePhoto.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [RecipePhoto] by its [id] or null if no such row exists.
  Future<RecipePhoto?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    RecipePhotoInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<RecipePhoto>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [RecipePhoto]s in the list and returns the inserted rows.
  ///
  /// The returned [RecipePhoto]s will have their `id` fields set.
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
  Future<List<RecipePhoto>> insert(
    _is.DatabaseSession session,
    List<RecipePhoto> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<RecipePhoto>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [RecipePhoto] and returns the inserted row.
  ///
  /// The returned [RecipePhoto] will have its `id` field set.
  Future<RecipePhoto> insertRow(
    _is.DatabaseSession session,
    RecipePhoto row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<RecipePhoto>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [RecipePhoto]s in the list and returns the resulting rows.
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
  /// The returned [RecipePhoto]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RecipePhoto>> upsert(
    _is.DatabaseSession session,
    List<RecipePhoto> rows, {
    required _is.ColumnSelections<RecipePhotoTable> conflictColumns,
    _is.ColumnSelections<RecipePhotoTable>? updateColumns,
    _is.WhereExpressionBuilder<RecipePhotoTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<RecipePhoto>(
      rows,
      conflictColumns: conflictColumns(RecipePhoto.t),
      updateColumns: updateColumns?.call(RecipePhoto.t),
      updateWhere: updateWhere?.call(RecipePhoto.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [RecipePhoto] and returns the resulting row.
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
  /// The returned [RecipePhoto] will have its `id` field set.
  Future<RecipePhoto?> upsertRow(
    _is.DatabaseSession session,
    RecipePhoto row, {
    required _is.ColumnSelections<RecipePhotoTable> conflictColumns,
    _is.ColumnSelections<RecipePhotoTable>? updateColumns,
    _is.WhereExpressionBuilder<RecipePhotoTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<RecipePhoto>(
      row,
      conflictColumns: conflictColumns(RecipePhoto.t),
      updateColumns: updateColumns?.call(RecipePhoto.t),
      updateWhere: updateWhere?.call(RecipePhoto.t),
      transaction: transaction,
    );
  }

  /// Updates all [RecipePhoto]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RecipePhoto>> update(
    _is.DatabaseSession session,
    List<RecipePhoto> rows, {
    _is.ColumnSelections<RecipePhotoTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<RecipePhoto>(
      rows,
      columns: columns?.call(RecipePhoto.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [RecipePhoto]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<RecipePhoto> updateRow(
    _is.DatabaseSession session,
    RecipePhoto row, {
    _is.ColumnSelections<RecipePhotoTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<RecipePhoto>(
      row,
      columns: columns?.call(RecipePhoto.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RecipePhoto] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<RecipePhoto?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<RecipePhotoUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<RecipePhoto>(
      id,
      columnValues: columnValues(RecipePhoto.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [RecipePhoto]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RecipePhoto>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<RecipePhotoUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<RecipePhotoTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RecipePhotoTable>? orderBy,
    _is.OrderByListBuilder<RecipePhotoTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<RecipePhoto>(
      columnValues: columnValues(RecipePhoto.t.updateTable),
      where: where(RecipePhoto.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RecipePhoto.t),
      orderByList: orderByList?.call(RecipePhoto.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [RecipePhoto]s in the list and returns the deleted rows.
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
  Future<List<RecipePhoto>> delete(
    _is.DatabaseSession session,
    List<RecipePhoto> rows, {
    _is.OrderByBuilder<RecipePhotoTable>? orderBy,
    _is.OrderByListBuilder<RecipePhotoTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<RecipePhoto>(
      rows,
      orderBy: orderBy?.call(RecipePhoto.t),
      orderByList: orderByList?.call(RecipePhoto.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [RecipePhoto].
  Future<RecipePhoto> deleteRow(
    _is.DatabaseSession session,
    RecipePhoto row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<RecipePhoto>(
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
  Future<List<RecipePhoto>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RecipePhotoTable> where,
    _is.OrderByBuilder<RecipePhotoTable>? orderBy,
    _is.OrderByListBuilder<RecipePhotoTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<RecipePhoto>(
      where: where(RecipePhoto.t),
      orderBy: orderBy?.call(RecipePhoto.t),
      orderByList: orderByList?.call(RecipePhoto.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RecipePhotoTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<RecipePhoto>(
      where: where?.call(RecipePhoto.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [RecipePhoto] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RecipePhotoTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<RecipePhoto>(
      where: where(RecipePhoto.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class RecipePhotoAttachRowRepository {
  const RecipePhotoAttachRowRepository._();

  /// Creates a relation between the given [RecipePhoto] and [Recipe]
  /// by setting the [RecipePhoto]'s foreign key `recipeId` to refer to the [Recipe].
  Future<void> recipe(
    _is.DatabaseSession session,
    RecipePhoto recipePhoto,
    _iuy009ee.Recipe recipe, {
    _is.Transaction? transaction,
  }) async {
    if (recipePhoto.id == null) {
      throw ArgumentError.notNull('recipePhoto.id');
    }
    if (recipe.id == null) {
      throw ArgumentError.notNull('recipe.id');
    }

    var $recipePhoto = recipePhoto.copyWith(recipeId: recipe.id);
    await session.db.updateRow<RecipePhoto>(
      $recipePhoto,
      columns: [RecipePhoto.t.recipeId],
      transaction: transaction,
    );
  }
}
