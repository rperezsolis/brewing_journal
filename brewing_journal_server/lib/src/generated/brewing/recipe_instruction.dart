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

abstract class RecipeInstruction
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  RecipeInstruction._({
    this.id,
    required this.recipeId,
    this.recipe,
    required this.sortOrder,
    required this.text,
  });

  factory RecipeInstruction({
    _is.UuidValue? id,
    required _is.UuidValue recipeId,
    _iuy009ee.Recipe? recipe,
    required int sortOrder,
    required String text,
  }) = _RecipeInstructionImpl;

  factory RecipeInstruction.fromJson(Map<String, dynamic> jsonSerialization) {
    return RecipeInstruction(
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
      sortOrder: jsonSerialization['sortOrder'] as int,
      text: jsonSerialization['text'] as String,
    );
  }

  static final t = RecipeInstructionTable();

  static const db = RecipeInstructionRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue recipeId;

  _iuy009ee.Recipe? recipe;

  int sortOrder;

  String text;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [RecipeInstruction]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RecipeInstruction copyWith({
    _is.UuidValue? id,
    _is.UuidValue? recipeId,
    _iuy009ee.Recipe? recipe,
    int? sortOrder,
    String? text,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RecipeInstruction',
      if (id != null) 'id': id?.toJson(),
      'recipeId': recipeId.toJson(),
      if (recipe != null) 'recipe': recipe?.toJson(),
      'sortOrder': sortOrder,
      'text': text,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RecipeInstruction',
      if (id != null) 'id': id?.toJson(),
      'recipeId': recipeId.toJson(),
      if (recipe != null) 'recipe': recipe?.toJsonForProtocol(),
      'sortOrder': sortOrder,
      'text': text,
    };
  }

  static RecipeInstructionInclude include({_iuy009ee.RecipeInclude? recipe}) {
    return RecipeInstructionInclude._(recipe: recipe);
  }

  static RecipeInstructionIncludeList includeList({
    _is.WhereExpressionBuilder<RecipeInstructionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RecipeInstructionTable>? orderBy,
    _is.OrderByListBuilder<RecipeInstructionTable>? orderByList,
    RecipeInstructionInclude? include,
  }) {
    return RecipeInstructionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RecipeInstruction.t),
      orderByList: orderByList?.call(RecipeInstruction.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RecipeInstructionImpl extends RecipeInstruction {
  _RecipeInstructionImpl({
    _is.UuidValue? id,
    required _is.UuidValue recipeId,
    _iuy009ee.Recipe? recipe,
    required int sortOrder,
    required String text,
  }) : super._(
         id: id,
         recipeId: recipeId,
         recipe: recipe,
         sortOrder: sortOrder,
         text: text,
       );

  /// Returns a shallow copy of this [RecipeInstruction]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RecipeInstruction copyWith({
    Object? id = _Undefined,
    _is.UuidValue? recipeId,
    Object? recipe = _Undefined,
    int? sortOrder,
    String? text,
  }) {
    return RecipeInstruction(
      id: id is _is.UuidValue? ? id : this.id,
      recipeId: recipeId ?? this.recipeId,
      recipe: recipe is _iuy009ee.Recipe? ? recipe : this.recipe?.copyWith(),
      sortOrder: sortOrder ?? this.sortOrder,
      text: text ?? this.text,
    );
  }
}

class RecipeInstructionUpdateTable
    extends _is.UpdateTable<RecipeInstructionTable> {
  RecipeInstructionUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> recipeId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.recipeId,
        value,
      );

  _is.ColumnValue<int, int> sortOrder(int value) => _is.ColumnValue(
    table.sortOrder,
    value,
  );

  _is.ColumnValue<String, String> text(String value) => _is.ColumnValue(
    table.text,
    value,
  );
}

class RecipeInstructionTable extends _is.Table<_is.UuidValue?> {
  RecipeInstructionTable({super.tableRelation})
    : super(tableName: 'recipe_instruction') {
    updateTable = RecipeInstructionUpdateTable(this);
    recipeId = _is.ColumnUuid(
      'recipeId',
      this,
    );
    sortOrder = _is.ColumnInt(
      'sortOrder',
      this,
    );
    text = _is.ColumnString(
      'text',
      this,
    );
  }

  late final RecipeInstructionUpdateTable updateTable;

  late final _is.ColumnUuid recipeId;

  _iuy009ee.RecipeTable? _recipe;

  late final _is.ColumnInt sortOrder;

  late final _is.ColumnString text;

  _iuy009ee.RecipeTable get recipe {
    if (_recipe != null) return _recipe!;
    _recipe = _is.createRelationTable(
      relationFieldName: 'recipe',
      field: RecipeInstruction.t.recipeId,
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
    sortOrder,
    text,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'recipe') {
      return recipe;
    }
    return null;
  }
}

class RecipeInstructionInclude extends _is.IncludeObject {
  RecipeInstructionInclude._({_iuy009ee.RecipeInclude? recipe}) {
    _recipe = recipe;
  }

  _iuy009ee.RecipeInclude? _recipe;

  @override
  Map<String, _is.Include?> get includes => {'recipe': _recipe};

  @override
  _is.Table<_is.UuidValue?> get table => RecipeInstruction.t;
}

class RecipeInstructionIncludeList extends _is.IncludeList {
  RecipeInstructionIncludeList._({
    _is.WhereExpressionBuilder<RecipeInstructionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(RecipeInstruction.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => RecipeInstruction.t;
}

class RecipeInstructionRepository {
  const RecipeInstructionRepository._();

  final attachRow = const RecipeInstructionAttachRowRepository._();

  /// Returns a list of [RecipeInstruction]s matching the given query parameters.
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
  Future<List<RecipeInstruction>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RecipeInstructionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RecipeInstructionTable>? orderBy,
    _is.OrderByListBuilder<RecipeInstructionTable>? orderByList,
    _is.Transaction? transaction,
    RecipeInstructionInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<RecipeInstruction>(
      where: where?.call(RecipeInstruction.t),
      orderBy: orderBy?.call(RecipeInstruction.t),
      orderByList: orderByList?.call(RecipeInstruction.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [RecipeInstruction] matching the given query parameters.
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
  Future<RecipeInstruction?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RecipeInstructionTable>? where,
    int? offset,
    _is.OrderByBuilder<RecipeInstructionTable>? orderBy,
    _is.OrderByListBuilder<RecipeInstructionTable>? orderByList,
    _is.Transaction? transaction,
    RecipeInstructionInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<RecipeInstruction>(
      where: where?.call(RecipeInstruction.t),
      orderBy: orderBy?.call(RecipeInstruction.t),
      orderByList: orderByList?.call(RecipeInstruction.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [RecipeInstruction] by its [id] or null if no such row exists.
  Future<RecipeInstruction?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    RecipeInstructionInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<RecipeInstruction>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [RecipeInstruction]s in the list and returns the inserted rows.
  ///
  /// The returned [RecipeInstruction]s will have their `id` fields set.
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
  Future<List<RecipeInstruction>> insert(
    _is.DatabaseSession session,
    List<RecipeInstruction> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<RecipeInstruction>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [RecipeInstruction] and returns the inserted row.
  ///
  /// The returned [RecipeInstruction] will have its `id` field set.
  Future<RecipeInstruction> insertRow(
    _is.DatabaseSession session,
    RecipeInstruction row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<RecipeInstruction>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [RecipeInstruction]s in the list and returns the resulting rows.
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
  /// The returned [RecipeInstruction]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RecipeInstruction>> upsert(
    _is.DatabaseSession session,
    List<RecipeInstruction> rows, {
    required _is.ColumnSelections<RecipeInstructionTable> conflictColumns,
    _is.ColumnSelections<RecipeInstructionTable>? updateColumns,
    _is.WhereExpressionBuilder<RecipeInstructionTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<RecipeInstruction>(
      rows,
      conflictColumns: conflictColumns(RecipeInstruction.t),
      updateColumns: updateColumns?.call(RecipeInstruction.t),
      updateWhere: updateWhere?.call(RecipeInstruction.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [RecipeInstruction] and returns the resulting row.
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
  /// The returned [RecipeInstruction] will have its `id` field set.
  Future<RecipeInstruction?> upsertRow(
    _is.DatabaseSession session,
    RecipeInstruction row, {
    required _is.ColumnSelections<RecipeInstructionTable> conflictColumns,
    _is.ColumnSelections<RecipeInstructionTable>? updateColumns,
    _is.WhereExpressionBuilder<RecipeInstructionTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<RecipeInstruction>(
      row,
      conflictColumns: conflictColumns(RecipeInstruction.t),
      updateColumns: updateColumns?.call(RecipeInstruction.t),
      updateWhere: updateWhere?.call(RecipeInstruction.t),
      transaction: transaction,
    );
  }

  /// Updates all [RecipeInstruction]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RecipeInstruction>> update(
    _is.DatabaseSession session,
    List<RecipeInstruction> rows, {
    _is.ColumnSelections<RecipeInstructionTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<RecipeInstruction>(
      rows,
      columns: columns?.call(RecipeInstruction.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [RecipeInstruction]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<RecipeInstruction> updateRow(
    _is.DatabaseSession session,
    RecipeInstruction row, {
    _is.ColumnSelections<RecipeInstructionTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<RecipeInstruction>(
      row,
      columns: columns?.call(RecipeInstruction.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RecipeInstruction] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<RecipeInstruction?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<RecipeInstructionUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<RecipeInstruction>(
      id,
      columnValues: columnValues(RecipeInstruction.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [RecipeInstruction]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RecipeInstruction>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<RecipeInstructionUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<RecipeInstructionTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RecipeInstructionTable>? orderBy,
    _is.OrderByListBuilder<RecipeInstructionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<RecipeInstruction>(
      columnValues: columnValues(RecipeInstruction.t.updateTable),
      where: where(RecipeInstruction.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RecipeInstruction.t),
      orderByList: orderByList?.call(RecipeInstruction.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [RecipeInstruction]s in the list and returns the deleted rows.
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
  Future<List<RecipeInstruction>> delete(
    _is.DatabaseSession session,
    List<RecipeInstruction> rows, {
    _is.OrderByBuilder<RecipeInstructionTable>? orderBy,
    _is.OrderByListBuilder<RecipeInstructionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<RecipeInstruction>(
      rows,
      orderBy: orderBy?.call(RecipeInstruction.t),
      orderByList: orderByList?.call(RecipeInstruction.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [RecipeInstruction].
  Future<RecipeInstruction> deleteRow(
    _is.DatabaseSession session,
    RecipeInstruction row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<RecipeInstruction>(
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
  Future<List<RecipeInstruction>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RecipeInstructionTable> where,
    _is.OrderByBuilder<RecipeInstructionTable>? orderBy,
    _is.OrderByListBuilder<RecipeInstructionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<RecipeInstruction>(
      where: where(RecipeInstruction.t),
      orderBy: orderBy?.call(RecipeInstruction.t),
      orderByList: orderByList?.call(RecipeInstruction.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RecipeInstructionTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<RecipeInstruction>(
      where: where?.call(RecipeInstruction.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [RecipeInstruction] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RecipeInstructionTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<RecipeInstruction>(
      where: where(RecipeInstruction.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class RecipeInstructionAttachRowRepository {
  const RecipeInstructionAttachRowRepository._();

  /// Creates a relation between the given [RecipeInstruction] and [Recipe]
  /// by setting the [RecipeInstruction]'s foreign key `recipeId` to refer to the [Recipe].
  Future<void> recipe(
    _is.DatabaseSession session,
    RecipeInstruction recipeInstruction,
    _iuy009ee.Recipe recipe, {
    _is.Transaction? transaction,
  }) async {
    if (recipeInstruction.id == null) {
      throw ArgumentError.notNull('recipeInstruction.id');
    }
    if (recipe.id == null) {
      throw ArgumentError.notNull('recipe.id');
    }

    var $recipeInstruction = recipeInstruction.copyWith(recipeId: recipe.id);
    await session.db.updateRow<RecipeInstruction>(
      $recipeInstruction,
      columns: [RecipeInstruction.t.recipeId],
      transaction: transaction,
    );
  }
}
