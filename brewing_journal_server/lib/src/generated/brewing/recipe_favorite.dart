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
import '../brewing/recipe.dart' as _iuy009ee;

abstract class RecipeFavorite
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  RecipeFavorite._({
    this.id,
    required this.userId,
    this.user,
    required this.recipeId,
    this.recipe,
    required this.titleKey,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory RecipeFavorite({
    _is.UuidValue? id,
    required _is.UuidValue userId,
    _iacs.AuthUser? user,
    required _is.UuidValue recipeId,
    _iuy009ee.Recipe? recipe,
    required String titleKey,
    DateTime? createdAt,
  }) = _RecipeFavoriteImpl;

  factory RecipeFavorite.fromJson(Map<String, dynamic> jsonSerialization) {
    return RecipeFavorite(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      userId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      user: jsonSerialization['user'] == null
          ? null
          : _i8dlmk64.Protocol().deserialize<_iacs.AuthUser>(
              jsonSerialization['user'],
            ),
      recipeId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['recipeId'],
      ),
      recipe: jsonSerialization['recipe'] == null
          ? null
          : _i8dlmk64.Protocol().deserialize<_iuy009ee.Recipe>(
              jsonSerialization['recipe'],
            ),
      titleKey: jsonSerialization['titleKey'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = RecipeFavoriteTable();

  static const db = RecipeFavoriteRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue userId;

  _iacs.AuthUser? user;

  _is.UuidValue recipeId;

  _iuy009ee.Recipe? recipe;

  /// Trimmed, lower-case title. One favorite per user per title.
  String titleKey;

  DateTime createdAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [RecipeFavorite]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RecipeFavorite copyWith({
    _is.UuidValue? id,
    _is.UuidValue? userId,
    _iacs.AuthUser? user,
    _is.UuidValue? recipeId,
    _iuy009ee.Recipe? recipe,
    String? titleKey,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RecipeFavorite',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      if (user != null) 'user': user?.toJson(),
      'recipeId': recipeId.toJson(),
      if (recipe != null) 'recipe': recipe?.toJson(),
      'titleKey': titleKey,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static RecipeFavoriteInclude include({
    _iacs.AuthUserInclude? user,
    _iuy009ee.RecipeInclude? recipe,
  }) {
    return RecipeFavoriteInclude._(
      user: user,
      recipe: recipe,
    );
  }

  static RecipeFavoriteIncludeList includeList({
    _is.WhereExpressionBuilder<RecipeFavoriteTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RecipeFavoriteTable>? orderBy,
    _is.OrderByListBuilder<RecipeFavoriteTable>? orderByList,
    RecipeFavoriteInclude? include,
  }) {
    return RecipeFavoriteIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RecipeFavorite.t),
      orderByList: orderByList?.call(RecipeFavorite.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RecipeFavoriteImpl extends RecipeFavorite {
  _RecipeFavoriteImpl({
    _is.UuidValue? id,
    required _is.UuidValue userId,
    _iacs.AuthUser? user,
    required _is.UuidValue recipeId,
    _iuy009ee.Recipe? recipe,
    required String titleKey,
    DateTime? createdAt,
  }) : super._(
         id: id,
         userId: userId,
         user: user,
         recipeId: recipeId,
         recipe: recipe,
         titleKey: titleKey,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [RecipeFavorite]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RecipeFavorite copyWith({
    Object? id = _Undefined,
    _is.UuidValue? userId,
    Object? user = _Undefined,
    _is.UuidValue? recipeId,
    Object? recipe = _Undefined,
    String? titleKey,
    DateTime? createdAt,
  }) {
    return RecipeFavorite(
      id: id is _is.UuidValue? ? id : this.id,
      userId: userId ?? this.userId,
      user: user is _iacs.AuthUser? ? user : this.user?.copyWith(),
      recipeId: recipeId ?? this.recipeId,
      recipe: recipe is _iuy009ee.Recipe? ? recipe : this.recipe?.copyWith(),
      titleKey: titleKey ?? this.titleKey,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class RecipeFavoriteUpdateTable extends _is.UpdateTable<RecipeFavoriteTable> {
  RecipeFavoriteUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> userId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.userId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> recipeId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.recipeId,
        value,
      );

  _is.ColumnValue<String, String> titleKey(String value) => _is.ColumnValue(
    table.titleKey,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class RecipeFavoriteTable extends _is.Table<_is.UuidValue?> {
  RecipeFavoriteTable({super.tableRelation})
    : super(tableName: 'recipe_favorite') {
    updateTable = RecipeFavoriteUpdateTable(this);
    userId = _is.ColumnUuid(
      'userId',
      this,
    );
    recipeId = _is.ColumnUuid(
      'recipeId',
      this,
    );
    titleKey = _is.ColumnString(
      'titleKey',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final RecipeFavoriteUpdateTable updateTable;

  late final _is.ColumnUuid userId;

  _iacs.AuthUserTable? _user;

  late final _is.ColumnUuid recipeId;

  _iuy009ee.RecipeTable? _recipe;

  /// Trimmed, lower-case title. One favorite per user per title.
  late final _is.ColumnString titleKey;

  late final _is.ColumnDateTime createdAt;

  _iacs.AuthUserTable get user {
    if (_user != null) return _user!;
    _user = _is.createRelationTable(
      relationFieldName: 'user',
      field: RecipeFavorite.t.userId,
      foreignField: _iacs.AuthUser.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _iacs.AuthUserTable(tableRelation: foreignTableRelation),
    );
    return _user!;
  }

  _iuy009ee.RecipeTable get recipe {
    if (_recipe != null) return _recipe!;
    _recipe = _is.createRelationTable(
      relationFieldName: 'recipe',
      field: RecipeFavorite.t.recipeId,
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
    userId,
    recipeId,
    titleKey,
    createdAt,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'user') {
      return user;
    }
    if (relationField == 'recipe') {
      return recipe;
    }
    return null;
  }
}

class RecipeFavoriteInclude extends _is.IncludeObject {
  RecipeFavoriteInclude._({
    _iacs.AuthUserInclude? user,
    _iuy009ee.RecipeInclude? recipe,
  }) {
    _user = user;
    _recipe = recipe;
  }

  _iacs.AuthUserInclude? _user;

  _iuy009ee.RecipeInclude? _recipe;

  @override
  Map<String, _is.Include?> get includes => {
    'user': _user,
    'recipe': _recipe,
  };

  @override
  _is.Table<_is.UuidValue?> get table => RecipeFavorite.t;
}

class RecipeFavoriteIncludeList extends _is.IncludeList {
  RecipeFavoriteIncludeList._({
    _is.WhereExpressionBuilder<RecipeFavoriteTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(RecipeFavorite.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => RecipeFavorite.t;
}

class RecipeFavoriteRepository {
  const RecipeFavoriteRepository._();

  final attachRow = const RecipeFavoriteAttachRowRepository._();

  /// Returns a list of [RecipeFavorite]s matching the given query parameters.
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
  Future<List<RecipeFavorite>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RecipeFavoriteTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RecipeFavoriteTable>? orderBy,
    _is.OrderByListBuilder<RecipeFavoriteTable>? orderByList,
    _is.Transaction? transaction,
    RecipeFavoriteInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<RecipeFavorite>(
      where: where?.call(RecipeFavorite.t),
      orderBy: orderBy?.call(RecipeFavorite.t),
      orderByList: orderByList?.call(RecipeFavorite.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [RecipeFavorite] matching the given query parameters.
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
  Future<RecipeFavorite?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RecipeFavoriteTable>? where,
    int? offset,
    _is.OrderByBuilder<RecipeFavoriteTable>? orderBy,
    _is.OrderByListBuilder<RecipeFavoriteTable>? orderByList,
    _is.Transaction? transaction,
    RecipeFavoriteInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<RecipeFavorite>(
      where: where?.call(RecipeFavorite.t),
      orderBy: orderBy?.call(RecipeFavorite.t),
      orderByList: orderByList?.call(RecipeFavorite.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [RecipeFavorite] by its [id] or null if no such row exists.
  Future<RecipeFavorite?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    RecipeFavoriteInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<RecipeFavorite>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [RecipeFavorite]s in the list and returns the inserted rows.
  ///
  /// The returned [RecipeFavorite]s will have their `id` fields set.
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
  Future<List<RecipeFavorite>> insert(
    _is.DatabaseSession session,
    List<RecipeFavorite> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<RecipeFavorite>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [RecipeFavorite] and returns the inserted row.
  ///
  /// The returned [RecipeFavorite] will have its `id` field set.
  Future<RecipeFavorite> insertRow(
    _is.DatabaseSession session,
    RecipeFavorite row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<RecipeFavorite>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [RecipeFavorite]s in the list and returns the resulting rows.
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
  /// The returned [RecipeFavorite]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RecipeFavorite>> upsert(
    _is.DatabaseSession session,
    List<RecipeFavorite> rows, {
    required _is.ColumnSelections<RecipeFavoriteTable> conflictColumns,
    _is.ColumnSelections<RecipeFavoriteTable>? updateColumns,
    _is.WhereExpressionBuilder<RecipeFavoriteTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<RecipeFavorite>(
      rows,
      conflictColumns: conflictColumns(RecipeFavorite.t),
      updateColumns: updateColumns?.call(RecipeFavorite.t),
      updateWhere: updateWhere?.call(RecipeFavorite.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [RecipeFavorite] and returns the resulting row.
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
  /// The returned [RecipeFavorite] will have its `id` field set.
  Future<RecipeFavorite?> upsertRow(
    _is.DatabaseSession session,
    RecipeFavorite row, {
    required _is.ColumnSelections<RecipeFavoriteTable> conflictColumns,
    _is.ColumnSelections<RecipeFavoriteTable>? updateColumns,
    _is.WhereExpressionBuilder<RecipeFavoriteTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<RecipeFavorite>(
      row,
      conflictColumns: conflictColumns(RecipeFavorite.t),
      updateColumns: updateColumns?.call(RecipeFavorite.t),
      updateWhere: updateWhere?.call(RecipeFavorite.t),
      transaction: transaction,
    );
  }

  /// Updates all [RecipeFavorite]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RecipeFavorite>> update(
    _is.DatabaseSession session,
    List<RecipeFavorite> rows, {
    _is.ColumnSelections<RecipeFavoriteTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<RecipeFavorite>(
      rows,
      columns: columns?.call(RecipeFavorite.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [RecipeFavorite]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<RecipeFavorite> updateRow(
    _is.DatabaseSession session,
    RecipeFavorite row, {
    _is.ColumnSelections<RecipeFavoriteTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<RecipeFavorite>(
      row,
      columns: columns?.call(RecipeFavorite.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RecipeFavorite] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<RecipeFavorite?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<RecipeFavoriteUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<RecipeFavorite>(
      id,
      columnValues: columnValues(RecipeFavorite.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [RecipeFavorite]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RecipeFavorite>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<RecipeFavoriteUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<RecipeFavoriteTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RecipeFavoriteTable>? orderBy,
    _is.OrderByListBuilder<RecipeFavoriteTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<RecipeFavorite>(
      columnValues: columnValues(RecipeFavorite.t.updateTable),
      where: where(RecipeFavorite.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RecipeFavorite.t),
      orderByList: orderByList?.call(RecipeFavorite.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [RecipeFavorite]s in the list and returns the deleted rows.
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
  Future<List<RecipeFavorite>> delete(
    _is.DatabaseSession session,
    List<RecipeFavorite> rows, {
    _is.OrderByBuilder<RecipeFavoriteTable>? orderBy,
    _is.OrderByListBuilder<RecipeFavoriteTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<RecipeFavorite>(
      rows,
      orderBy: orderBy?.call(RecipeFavorite.t),
      orderByList: orderByList?.call(RecipeFavorite.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [RecipeFavorite].
  Future<RecipeFavorite> deleteRow(
    _is.DatabaseSession session,
    RecipeFavorite row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<RecipeFavorite>(
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
  Future<List<RecipeFavorite>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RecipeFavoriteTable> where,
    _is.OrderByBuilder<RecipeFavoriteTable>? orderBy,
    _is.OrderByListBuilder<RecipeFavoriteTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<RecipeFavorite>(
      where: where(RecipeFavorite.t),
      orderBy: orderBy?.call(RecipeFavorite.t),
      orderByList: orderByList?.call(RecipeFavorite.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RecipeFavoriteTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<RecipeFavorite>(
      where: where?.call(RecipeFavorite.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [RecipeFavorite] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RecipeFavoriteTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<RecipeFavorite>(
      where: where(RecipeFavorite.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class RecipeFavoriteAttachRowRepository {
  const RecipeFavoriteAttachRowRepository._();

  /// Creates a relation between the given [RecipeFavorite] and [AuthUser]
  /// by setting the [RecipeFavorite]'s foreign key `userId` to refer to the [AuthUser].
  Future<void> user(
    _is.DatabaseSession session,
    RecipeFavorite recipeFavorite,
    _iacs.AuthUser user, {
    _is.Transaction? transaction,
  }) async {
    if (recipeFavorite.id == null) {
      throw ArgumentError.notNull('recipeFavorite.id');
    }
    if (user.id == null) {
      throw ArgumentError.notNull('user.id');
    }

    var $recipeFavorite = recipeFavorite.copyWith(userId: user.id);
    await session.db.updateRow<RecipeFavorite>(
      $recipeFavorite,
      columns: [RecipeFavorite.t.userId],
      transaction: transaction,
    );
  }

  /// Creates a relation between the given [RecipeFavorite] and [Recipe]
  /// by setting the [RecipeFavorite]'s foreign key `recipeId` to refer to the [Recipe].
  Future<void> recipe(
    _is.DatabaseSession session,
    RecipeFavorite recipeFavorite,
    _iuy009ee.Recipe recipe, {
    _is.Transaction? transaction,
  }) async {
    if (recipeFavorite.id == null) {
      throw ArgumentError.notNull('recipeFavorite.id');
    }
    if (recipe.id == null) {
      throw ArgumentError.notNull('recipe.id');
    }

    var $recipeFavorite = recipeFavorite.copyWith(recipeId: recipe.id);
    await session.db.updateRow<RecipeFavorite>(
      $recipeFavorite,
      columns: [RecipeFavorite.t.recipeId],
      transaction: transaction,
    );
  }
}
