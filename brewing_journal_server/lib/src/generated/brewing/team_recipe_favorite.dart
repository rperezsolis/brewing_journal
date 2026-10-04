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
import '../teams/team.dart' as _izqfkhlk;

abstract class TeamRecipeFavorite
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  TeamRecipeFavorite._({
    this.id,
    required this.teamId,
    this.team,
    required this.recipeId,
    this.recipe,
    required this.titleKey,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory TeamRecipeFavorite({
    _is.UuidValue? id,
    required _is.UuidValue teamId,
    _izqfkhlk.Team? team,
    required _is.UuidValue recipeId,
    _iuy009ee.Recipe? recipe,
    required String titleKey,
    DateTime? createdAt,
  }) = _TeamRecipeFavoriteImpl;

  factory TeamRecipeFavorite.fromJson(Map<String, dynamic> jsonSerialization) {
    return TeamRecipeFavorite(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      teamId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['teamId']),
      team: jsonSerialization['team'] == null
          ? null
          : _i8dlmk64.Protocol().deserialize<_izqfkhlk.Team>(
              jsonSerialization['team'],
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

  static final t = TeamRecipeFavoriteTable();

  static const db = TeamRecipeFavoriteRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue teamId;

  _izqfkhlk.Team? team;

  _is.UuidValue recipeId;

  _iuy009ee.Recipe? recipe;

  /// Trimmed, lower-case title. One favorite per team per title.
  String titleKey;

  DateTime createdAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [TeamRecipeFavorite]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TeamRecipeFavorite copyWith({
    _is.UuidValue? id,
    _is.UuidValue? teamId,
    _izqfkhlk.Team? team,
    _is.UuidValue? recipeId,
    _iuy009ee.Recipe? recipe,
    String? titleKey,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TeamRecipeFavorite',
      if (id != null) 'id': id?.toJson(),
      'teamId': teamId.toJson(),
      if (team != null) 'team': team?.toJson(),
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

  static TeamRecipeFavoriteInclude include({
    _izqfkhlk.TeamInclude? team,
    _iuy009ee.RecipeInclude? recipe,
  }) {
    return TeamRecipeFavoriteInclude._(
      team: team,
      recipe: recipe,
    );
  }

  static TeamRecipeFavoriteIncludeList includeList({
    _is.WhereExpressionBuilder<TeamRecipeFavoriteTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TeamRecipeFavoriteTable>? orderBy,
    _is.OrderByListBuilder<TeamRecipeFavoriteTable>? orderByList,
    TeamRecipeFavoriteInclude? include,
  }) {
    return TeamRecipeFavoriteIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TeamRecipeFavorite.t),
      orderByList: orderByList?.call(TeamRecipeFavorite.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TeamRecipeFavoriteImpl extends TeamRecipeFavorite {
  _TeamRecipeFavoriteImpl({
    _is.UuidValue? id,
    required _is.UuidValue teamId,
    _izqfkhlk.Team? team,
    required _is.UuidValue recipeId,
    _iuy009ee.Recipe? recipe,
    required String titleKey,
    DateTime? createdAt,
  }) : super._(
         id: id,
         teamId: teamId,
         team: team,
         recipeId: recipeId,
         recipe: recipe,
         titleKey: titleKey,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [TeamRecipeFavorite]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TeamRecipeFavorite copyWith({
    Object? id = _Undefined,
    _is.UuidValue? teamId,
    Object? team = _Undefined,
    _is.UuidValue? recipeId,
    Object? recipe = _Undefined,
    String? titleKey,
    DateTime? createdAt,
  }) {
    return TeamRecipeFavorite(
      id: id is _is.UuidValue? ? id : this.id,
      teamId: teamId ?? this.teamId,
      team: team is _izqfkhlk.Team? ? team : this.team?.copyWith(),
      recipeId: recipeId ?? this.recipeId,
      recipe: recipe is _iuy009ee.Recipe? ? recipe : this.recipe?.copyWith(),
      titleKey: titleKey ?? this.titleKey,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class TeamRecipeFavoriteUpdateTable
    extends _is.UpdateTable<TeamRecipeFavoriteTable> {
  TeamRecipeFavoriteUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> teamId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.teamId,
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

class TeamRecipeFavoriteTable extends _is.Table<_is.UuidValue?> {
  TeamRecipeFavoriteTable({super.tableRelation})
    : super(tableName: 'team_recipe_favorite') {
    updateTable = TeamRecipeFavoriteUpdateTable(this);
    teamId = _is.ColumnUuid(
      'teamId',
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

  late final TeamRecipeFavoriteUpdateTable updateTable;

  late final _is.ColumnUuid teamId;

  _izqfkhlk.TeamTable? _team;

  late final _is.ColumnUuid recipeId;

  _iuy009ee.RecipeTable? _recipe;

  /// Trimmed, lower-case title. One favorite per team per title.
  late final _is.ColumnString titleKey;

  late final _is.ColumnDateTime createdAt;

  _izqfkhlk.TeamTable get team {
    if (_team != null) return _team!;
    _team = _is.createRelationTable(
      relationFieldName: 'team',
      field: TeamRecipeFavorite.t.teamId,
      foreignField: _izqfkhlk.Team.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _izqfkhlk.TeamTable(tableRelation: foreignTableRelation),
    );
    return _team!;
  }

  _iuy009ee.RecipeTable get recipe {
    if (_recipe != null) return _recipe!;
    _recipe = _is.createRelationTable(
      relationFieldName: 'recipe',
      field: TeamRecipeFavorite.t.recipeId,
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
    teamId,
    recipeId,
    titleKey,
    createdAt,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'team') {
      return team;
    }
    if (relationField == 'recipe') {
      return recipe;
    }
    return null;
  }
}

class TeamRecipeFavoriteInclude extends _is.IncludeObject {
  TeamRecipeFavoriteInclude._({
    _izqfkhlk.TeamInclude? team,
    _iuy009ee.RecipeInclude? recipe,
  }) {
    _team = team;
    _recipe = recipe;
  }

  _izqfkhlk.TeamInclude? _team;

  _iuy009ee.RecipeInclude? _recipe;

  @override
  Map<String, _is.Include?> get includes => {
    'team': _team,
    'recipe': _recipe,
  };

  @override
  _is.Table<_is.UuidValue?> get table => TeamRecipeFavorite.t;
}

class TeamRecipeFavoriteIncludeList extends _is.IncludeList {
  TeamRecipeFavoriteIncludeList._({
    _is.WhereExpressionBuilder<TeamRecipeFavoriteTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(TeamRecipeFavorite.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => TeamRecipeFavorite.t;
}

class TeamRecipeFavoriteRepository {
  const TeamRecipeFavoriteRepository._();

  final attachRow = const TeamRecipeFavoriteAttachRowRepository._();

  /// Returns a list of [TeamRecipeFavorite]s matching the given query parameters.
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
  Future<List<TeamRecipeFavorite>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TeamRecipeFavoriteTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TeamRecipeFavoriteTable>? orderBy,
    _is.OrderByListBuilder<TeamRecipeFavoriteTable>? orderByList,
    _is.Transaction? transaction,
    TeamRecipeFavoriteInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<TeamRecipeFavorite>(
      where: where?.call(TeamRecipeFavorite.t),
      orderBy: orderBy?.call(TeamRecipeFavorite.t),
      orderByList: orderByList?.call(TeamRecipeFavorite.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [TeamRecipeFavorite] matching the given query parameters.
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
  Future<TeamRecipeFavorite?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TeamRecipeFavoriteTable>? where,
    int? offset,
    _is.OrderByBuilder<TeamRecipeFavoriteTable>? orderBy,
    _is.OrderByListBuilder<TeamRecipeFavoriteTable>? orderByList,
    _is.Transaction? transaction,
    TeamRecipeFavoriteInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<TeamRecipeFavorite>(
      where: where?.call(TeamRecipeFavorite.t),
      orderBy: orderBy?.call(TeamRecipeFavorite.t),
      orderByList: orderByList?.call(TeamRecipeFavorite.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [TeamRecipeFavorite] by its [id] or null if no such row exists.
  Future<TeamRecipeFavorite?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    TeamRecipeFavoriteInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<TeamRecipeFavorite>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [TeamRecipeFavorite]s in the list and returns the inserted rows.
  ///
  /// The returned [TeamRecipeFavorite]s will have their `id` fields set.
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
  Future<List<TeamRecipeFavorite>> insert(
    _is.DatabaseSession session,
    List<TeamRecipeFavorite> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<TeamRecipeFavorite>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [TeamRecipeFavorite] and returns the inserted row.
  ///
  /// The returned [TeamRecipeFavorite] will have its `id` field set.
  Future<TeamRecipeFavorite> insertRow(
    _is.DatabaseSession session,
    TeamRecipeFavorite row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<TeamRecipeFavorite>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [TeamRecipeFavorite]s in the list and returns the resulting rows.
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
  /// The returned [TeamRecipeFavorite]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TeamRecipeFavorite>> upsert(
    _is.DatabaseSession session,
    List<TeamRecipeFavorite> rows, {
    required _is.ColumnSelections<TeamRecipeFavoriteTable> conflictColumns,
    _is.ColumnSelections<TeamRecipeFavoriteTable>? updateColumns,
    _is.WhereExpressionBuilder<TeamRecipeFavoriteTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<TeamRecipeFavorite>(
      rows,
      conflictColumns: conflictColumns(TeamRecipeFavorite.t),
      updateColumns: updateColumns?.call(TeamRecipeFavorite.t),
      updateWhere: updateWhere?.call(TeamRecipeFavorite.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [TeamRecipeFavorite] and returns the resulting row.
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
  /// The returned [TeamRecipeFavorite] will have its `id` field set.
  Future<TeamRecipeFavorite?> upsertRow(
    _is.DatabaseSession session,
    TeamRecipeFavorite row, {
    required _is.ColumnSelections<TeamRecipeFavoriteTable> conflictColumns,
    _is.ColumnSelections<TeamRecipeFavoriteTable>? updateColumns,
    _is.WhereExpressionBuilder<TeamRecipeFavoriteTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<TeamRecipeFavorite>(
      row,
      conflictColumns: conflictColumns(TeamRecipeFavorite.t),
      updateColumns: updateColumns?.call(TeamRecipeFavorite.t),
      updateWhere: updateWhere?.call(TeamRecipeFavorite.t),
      transaction: transaction,
    );
  }

  /// Updates all [TeamRecipeFavorite]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TeamRecipeFavorite>> update(
    _is.DatabaseSession session,
    List<TeamRecipeFavorite> rows, {
    _is.ColumnSelections<TeamRecipeFavoriteTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<TeamRecipeFavorite>(
      rows,
      columns: columns?.call(TeamRecipeFavorite.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [TeamRecipeFavorite]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<TeamRecipeFavorite> updateRow(
    _is.DatabaseSession session,
    TeamRecipeFavorite row, {
    _is.ColumnSelections<TeamRecipeFavoriteTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<TeamRecipeFavorite>(
      row,
      columns: columns?.call(TeamRecipeFavorite.t),
      transaction: transaction,
    );
  }

  /// Updates a single [TeamRecipeFavorite] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<TeamRecipeFavorite?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<TeamRecipeFavoriteUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<TeamRecipeFavorite>(
      id,
      columnValues: columnValues(TeamRecipeFavorite.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [TeamRecipeFavorite]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TeamRecipeFavorite>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<TeamRecipeFavoriteUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<TeamRecipeFavoriteTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TeamRecipeFavoriteTable>? orderBy,
    _is.OrderByListBuilder<TeamRecipeFavoriteTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<TeamRecipeFavorite>(
      columnValues: columnValues(TeamRecipeFavorite.t.updateTable),
      where: where(TeamRecipeFavorite.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TeamRecipeFavorite.t),
      orderByList: orderByList?.call(TeamRecipeFavorite.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [TeamRecipeFavorite]s in the list and returns the deleted rows.
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
  Future<List<TeamRecipeFavorite>> delete(
    _is.DatabaseSession session,
    List<TeamRecipeFavorite> rows, {
    _is.OrderByBuilder<TeamRecipeFavoriteTable>? orderBy,
    _is.OrderByListBuilder<TeamRecipeFavoriteTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<TeamRecipeFavorite>(
      rows,
      orderBy: orderBy?.call(TeamRecipeFavorite.t),
      orderByList: orderByList?.call(TeamRecipeFavorite.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [TeamRecipeFavorite].
  Future<TeamRecipeFavorite> deleteRow(
    _is.DatabaseSession session,
    TeamRecipeFavorite row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<TeamRecipeFavorite>(
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
  Future<List<TeamRecipeFavorite>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TeamRecipeFavoriteTable> where,
    _is.OrderByBuilder<TeamRecipeFavoriteTable>? orderBy,
    _is.OrderByListBuilder<TeamRecipeFavoriteTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<TeamRecipeFavorite>(
      where: where(TeamRecipeFavorite.t),
      orderBy: orderBy?.call(TeamRecipeFavorite.t),
      orderByList: orderByList?.call(TeamRecipeFavorite.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TeamRecipeFavoriteTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<TeamRecipeFavorite>(
      where: where?.call(TeamRecipeFavorite.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [TeamRecipeFavorite] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TeamRecipeFavoriteTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<TeamRecipeFavorite>(
      where: where(TeamRecipeFavorite.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class TeamRecipeFavoriteAttachRowRepository {
  const TeamRecipeFavoriteAttachRowRepository._();

  /// Creates a relation between the given [TeamRecipeFavorite] and [Team]
  /// by setting the [TeamRecipeFavorite]'s foreign key `teamId` to refer to the [Team].
  Future<void> team(
    _is.DatabaseSession session,
    TeamRecipeFavorite teamRecipeFavorite,
    _izqfkhlk.Team team, {
    _is.Transaction? transaction,
  }) async {
    if (teamRecipeFavorite.id == null) {
      throw ArgumentError.notNull('teamRecipeFavorite.id');
    }
    if (team.id == null) {
      throw ArgumentError.notNull('team.id');
    }

    var $teamRecipeFavorite = teamRecipeFavorite.copyWith(teamId: team.id);
    await session.db.updateRow<TeamRecipeFavorite>(
      $teamRecipeFavorite,
      columns: [TeamRecipeFavorite.t.teamId],
      transaction: transaction,
    );
  }

  /// Creates a relation between the given [TeamRecipeFavorite] and [Recipe]
  /// by setting the [TeamRecipeFavorite]'s foreign key `recipeId` to refer to the [Recipe].
  Future<void> recipe(
    _is.DatabaseSession session,
    TeamRecipeFavorite teamRecipeFavorite,
    _iuy009ee.Recipe recipe, {
    _is.Transaction? transaction,
  }) async {
    if (teamRecipeFavorite.id == null) {
      throw ArgumentError.notNull('teamRecipeFavorite.id');
    }
    if (recipe.id == null) {
      throw ArgumentError.notNull('recipe.id');
    }

    var $teamRecipeFavorite = teamRecipeFavorite.copyWith(recipeId: recipe.id);
    await session.db.updateRow<TeamRecipeFavorite>(
      $teamRecipeFavorite,
      columns: [TeamRecipeFavorite.t.recipeId],
      transaction: transaction,
    );
  }
}
