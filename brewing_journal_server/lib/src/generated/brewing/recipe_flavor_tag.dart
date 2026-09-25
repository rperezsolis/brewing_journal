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

abstract class RecipeFlavorTag
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  RecipeFlavorTag._({
    this.id,
    required this.recipeId,
    this.recipe,
    required this.tag,
    required this.tagKey,
  });

  factory RecipeFlavorTag({
    _is.UuidValue? id,
    required _is.UuidValue recipeId,
    _iuy009ee.Recipe? recipe,
    required String tag,
    required String tagKey,
  }) = _RecipeFlavorTagImpl;

  factory RecipeFlavorTag.fromJson(Map<String, dynamic> jsonSerialization) {
    return RecipeFlavorTag(
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
      tag: jsonSerialization['tag'] as String,
      tagKey: jsonSerialization['tagKey'] as String,
    );
  }

  static final t = RecipeFlavorTagTable();

  static const db = RecipeFlavorTagRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue recipeId;

  _iuy009ee.Recipe? recipe;

  String tag;

  String tagKey;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [RecipeFlavorTag]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RecipeFlavorTag copyWith({
    _is.UuidValue? id,
    _is.UuidValue? recipeId,
    _iuy009ee.Recipe? recipe,
    String? tag,
    String? tagKey,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RecipeFlavorTag',
      if (id != null) 'id': id?.toJson(),
      'recipeId': recipeId.toJson(),
      if (recipe != null) 'recipe': recipe?.toJson(),
      'tag': tag,
      'tagKey': tagKey,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RecipeFlavorTag',
      if (id != null) 'id': id?.toJson(),
      'recipeId': recipeId.toJson(),
      if (recipe != null) 'recipe': recipe?.toJsonForProtocol(),
      'tag': tag,
      'tagKey': tagKey,
    };
  }

  static RecipeFlavorTagInclude include({_iuy009ee.RecipeInclude? recipe}) {
    return RecipeFlavorTagInclude._(recipe: recipe);
  }

  static RecipeFlavorTagIncludeList includeList({
    _is.WhereExpressionBuilder<RecipeFlavorTagTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RecipeFlavorTagTable>? orderBy,
    _is.OrderByListBuilder<RecipeFlavorTagTable>? orderByList,
    RecipeFlavorTagInclude? include,
  }) {
    return RecipeFlavorTagIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RecipeFlavorTag.t),
      orderByList: orderByList?.call(RecipeFlavorTag.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RecipeFlavorTagImpl extends RecipeFlavorTag {
  _RecipeFlavorTagImpl({
    _is.UuidValue? id,
    required _is.UuidValue recipeId,
    _iuy009ee.Recipe? recipe,
    required String tag,
    required String tagKey,
  }) : super._(
         id: id,
         recipeId: recipeId,
         recipe: recipe,
         tag: tag,
         tagKey: tagKey,
       );

  /// Returns a shallow copy of this [RecipeFlavorTag]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RecipeFlavorTag copyWith({
    Object? id = _Undefined,
    _is.UuidValue? recipeId,
    Object? recipe = _Undefined,
    String? tag,
    String? tagKey,
  }) {
    return RecipeFlavorTag(
      id: id is _is.UuidValue? ? id : this.id,
      recipeId: recipeId ?? this.recipeId,
      recipe: recipe is _iuy009ee.Recipe? ? recipe : this.recipe?.copyWith(),
      tag: tag ?? this.tag,
      tagKey: tagKey ?? this.tagKey,
    );
  }
}

class RecipeFlavorTagUpdateTable extends _is.UpdateTable<RecipeFlavorTagTable> {
  RecipeFlavorTagUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> recipeId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.recipeId,
        value,
      );

  _is.ColumnValue<String, String> tag(String value) => _is.ColumnValue(
    table.tag,
    value,
  );

  _is.ColumnValue<String, String> tagKey(String value) => _is.ColumnValue(
    table.tagKey,
    value,
  );
}

class RecipeFlavorTagTable extends _is.Table<_is.UuidValue?> {
  RecipeFlavorTagTable({super.tableRelation})
    : super(tableName: 'recipe_flavor_tag') {
    updateTable = RecipeFlavorTagUpdateTable(this);
    recipeId = _is.ColumnUuid(
      'recipeId',
      this,
    );
    tag = _is.ColumnString(
      'tag',
      this,
    );
    tagKey = _is.ColumnString(
      'tagKey',
      this,
    );
  }

  late final RecipeFlavorTagUpdateTable updateTable;

  late final _is.ColumnUuid recipeId;

  _iuy009ee.RecipeTable? _recipe;

  late final _is.ColumnString tag;

  late final _is.ColumnString tagKey;

  _iuy009ee.RecipeTable get recipe {
    if (_recipe != null) return _recipe!;
    _recipe = _is.createRelationTable(
      relationFieldName: 'recipe',
      field: RecipeFlavorTag.t.recipeId,
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
    tag,
    tagKey,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'recipe') {
      return recipe;
    }
    return null;
  }
}

class RecipeFlavorTagInclude extends _is.IncludeObject {
  RecipeFlavorTagInclude._({_iuy009ee.RecipeInclude? recipe}) {
    _recipe = recipe;
  }

  _iuy009ee.RecipeInclude? _recipe;

  @override
  Map<String, _is.Include?> get includes => {'recipe': _recipe};

  @override
  _is.Table<_is.UuidValue?> get table => RecipeFlavorTag.t;
}

class RecipeFlavorTagIncludeList extends _is.IncludeList {
  RecipeFlavorTagIncludeList._({
    _is.WhereExpressionBuilder<RecipeFlavorTagTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(RecipeFlavorTag.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => RecipeFlavorTag.t;
}

class RecipeFlavorTagRepository {
  const RecipeFlavorTagRepository._();

  final attachRow = const RecipeFlavorTagAttachRowRepository._();

  /// Returns a list of [RecipeFlavorTag]s matching the given query parameters.
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
  Future<List<RecipeFlavorTag>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RecipeFlavorTagTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RecipeFlavorTagTable>? orderBy,
    _is.OrderByListBuilder<RecipeFlavorTagTable>? orderByList,
    _is.Transaction? transaction,
    RecipeFlavorTagInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<RecipeFlavorTag>(
      where: where?.call(RecipeFlavorTag.t),
      orderBy: orderBy?.call(RecipeFlavorTag.t),
      orderByList: orderByList?.call(RecipeFlavorTag.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [RecipeFlavorTag] matching the given query parameters.
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
  Future<RecipeFlavorTag?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RecipeFlavorTagTable>? where,
    int? offset,
    _is.OrderByBuilder<RecipeFlavorTagTable>? orderBy,
    _is.OrderByListBuilder<RecipeFlavorTagTable>? orderByList,
    _is.Transaction? transaction,
    RecipeFlavorTagInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<RecipeFlavorTag>(
      where: where?.call(RecipeFlavorTag.t),
      orderBy: orderBy?.call(RecipeFlavorTag.t),
      orderByList: orderByList?.call(RecipeFlavorTag.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [RecipeFlavorTag] by its [id] or null if no such row exists.
  Future<RecipeFlavorTag?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    RecipeFlavorTagInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<RecipeFlavorTag>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [RecipeFlavorTag]s in the list and returns the inserted rows.
  ///
  /// The returned [RecipeFlavorTag]s will have their `id` fields set.
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
  Future<List<RecipeFlavorTag>> insert(
    _is.DatabaseSession session,
    List<RecipeFlavorTag> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<RecipeFlavorTag>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [RecipeFlavorTag] and returns the inserted row.
  ///
  /// The returned [RecipeFlavorTag] will have its `id` field set.
  Future<RecipeFlavorTag> insertRow(
    _is.DatabaseSession session,
    RecipeFlavorTag row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<RecipeFlavorTag>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [RecipeFlavorTag]s in the list and returns the resulting rows.
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
  /// The returned [RecipeFlavorTag]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RecipeFlavorTag>> upsert(
    _is.DatabaseSession session,
    List<RecipeFlavorTag> rows, {
    required _is.ColumnSelections<RecipeFlavorTagTable> conflictColumns,
    _is.ColumnSelections<RecipeFlavorTagTable>? updateColumns,
    _is.WhereExpressionBuilder<RecipeFlavorTagTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<RecipeFlavorTag>(
      rows,
      conflictColumns: conflictColumns(RecipeFlavorTag.t),
      updateColumns: updateColumns?.call(RecipeFlavorTag.t),
      updateWhere: updateWhere?.call(RecipeFlavorTag.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [RecipeFlavorTag] and returns the resulting row.
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
  /// The returned [RecipeFlavorTag] will have its `id` field set.
  Future<RecipeFlavorTag?> upsertRow(
    _is.DatabaseSession session,
    RecipeFlavorTag row, {
    required _is.ColumnSelections<RecipeFlavorTagTable> conflictColumns,
    _is.ColumnSelections<RecipeFlavorTagTable>? updateColumns,
    _is.WhereExpressionBuilder<RecipeFlavorTagTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<RecipeFlavorTag>(
      row,
      conflictColumns: conflictColumns(RecipeFlavorTag.t),
      updateColumns: updateColumns?.call(RecipeFlavorTag.t),
      updateWhere: updateWhere?.call(RecipeFlavorTag.t),
      transaction: transaction,
    );
  }

  /// Updates all [RecipeFlavorTag]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RecipeFlavorTag>> update(
    _is.DatabaseSession session,
    List<RecipeFlavorTag> rows, {
    _is.ColumnSelections<RecipeFlavorTagTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<RecipeFlavorTag>(
      rows,
      columns: columns?.call(RecipeFlavorTag.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [RecipeFlavorTag]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<RecipeFlavorTag> updateRow(
    _is.DatabaseSession session,
    RecipeFlavorTag row, {
    _is.ColumnSelections<RecipeFlavorTagTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<RecipeFlavorTag>(
      row,
      columns: columns?.call(RecipeFlavorTag.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RecipeFlavorTag] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<RecipeFlavorTag?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<RecipeFlavorTagUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<RecipeFlavorTag>(
      id,
      columnValues: columnValues(RecipeFlavorTag.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [RecipeFlavorTag]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RecipeFlavorTag>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<RecipeFlavorTagUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<RecipeFlavorTagTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RecipeFlavorTagTable>? orderBy,
    _is.OrderByListBuilder<RecipeFlavorTagTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<RecipeFlavorTag>(
      columnValues: columnValues(RecipeFlavorTag.t.updateTable),
      where: where(RecipeFlavorTag.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RecipeFlavorTag.t),
      orderByList: orderByList?.call(RecipeFlavorTag.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [RecipeFlavorTag]s in the list and returns the deleted rows.
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
  Future<List<RecipeFlavorTag>> delete(
    _is.DatabaseSession session,
    List<RecipeFlavorTag> rows, {
    _is.OrderByBuilder<RecipeFlavorTagTable>? orderBy,
    _is.OrderByListBuilder<RecipeFlavorTagTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<RecipeFlavorTag>(
      rows,
      orderBy: orderBy?.call(RecipeFlavorTag.t),
      orderByList: orderByList?.call(RecipeFlavorTag.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [RecipeFlavorTag].
  Future<RecipeFlavorTag> deleteRow(
    _is.DatabaseSession session,
    RecipeFlavorTag row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<RecipeFlavorTag>(
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
  Future<List<RecipeFlavorTag>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RecipeFlavorTagTable> where,
    _is.OrderByBuilder<RecipeFlavorTagTable>? orderBy,
    _is.OrderByListBuilder<RecipeFlavorTagTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<RecipeFlavorTag>(
      where: where(RecipeFlavorTag.t),
      orderBy: orderBy?.call(RecipeFlavorTag.t),
      orderByList: orderByList?.call(RecipeFlavorTag.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RecipeFlavorTagTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<RecipeFlavorTag>(
      where: where?.call(RecipeFlavorTag.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [RecipeFlavorTag] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RecipeFlavorTagTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<RecipeFlavorTag>(
      where: where(RecipeFlavorTag.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class RecipeFlavorTagAttachRowRepository {
  const RecipeFlavorTagAttachRowRepository._();

  /// Creates a relation between the given [RecipeFlavorTag] and [Recipe]
  /// by setting the [RecipeFlavorTag]'s foreign key `recipeId` to refer to the [Recipe].
  Future<void> recipe(
    _is.DatabaseSession session,
    RecipeFlavorTag recipeFlavorTag,
    _iuy009ee.Recipe recipe, {
    _is.Transaction? transaction,
  }) async {
    if (recipeFlavorTag.id == null) {
      throw ArgumentError.notNull('recipeFlavorTag.id');
    }
    if (recipe.id == null) {
      throw ArgumentError.notNull('recipe.id');
    }

    var $recipeFlavorTag = recipeFlavorTag.copyWith(recipeId: recipe.id);
    await session.db.updateRow<RecipeFlavorTag>(
      $recipeFlavorTag,
      columns: [RecipeFlavorTag.t.recipeId],
      transaction: transaction,
    );
  }
}
