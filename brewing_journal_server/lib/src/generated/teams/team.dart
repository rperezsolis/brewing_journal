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
import '../teams/team_invite.dart' as _i710pi98;
import '../teams/team_membership.dart' as _iromunn4;

abstract class Team
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  Team._({
    this.id,
    required this.ownerId,
    this.owner,
    required this.name,
    DateTime? createdAt,
    this.memberships,
    this.invites,
    this.recipes,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Team({
    _is.UuidValue? id,
    required _is.UuidValue ownerId,
    _iacs.AuthUser? owner,
    required String name,
    DateTime? createdAt,
    List<_iromunn4.TeamMembership>? memberships,
    List<_i710pi98.TeamInvite>? invites,
    List<_iuy009ee.Recipe>? recipes,
  }) = _TeamImpl;

  factory Team.fromJson(Map<String, dynamic> jsonSerialization) {
    return Team(
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
      name: jsonSerialization['name'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      memberships: jsonSerialization['memberships'] == null
          ? null
          : _i8dlmk64.Protocol().deserialize<List<_iromunn4.TeamMembership>>(
              jsonSerialization['memberships'],
            ),
      invites: jsonSerialization['invites'] == null
          ? null
          : _i8dlmk64.Protocol().deserialize<List<_i710pi98.TeamInvite>>(
              jsonSerialization['invites'],
            ),
      recipes: jsonSerialization['recipes'] == null
          ? null
          : _i8dlmk64.Protocol().deserialize<List<_iuy009ee.Recipe>>(
              jsonSerialization['recipes'],
            ),
    );
  }

  static final t = TeamTable();

  static const db = TeamRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue ownerId;

  _iacs.AuthUser? owner;

  String name;

  DateTime createdAt;

  List<_iromunn4.TeamMembership>? memberships;

  List<_i710pi98.TeamInvite>? invites;

  List<_iuy009ee.Recipe>? recipes;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Team]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Team copyWith({
    _is.UuidValue? id,
    _is.UuidValue? ownerId,
    _iacs.AuthUser? owner,
    String? name,
    DateTime? createdAt,
    List<_iromunn4.TeamMembership>? memberships,
    List<_i710pi98.TeamInvite>? invites,
    List<_iuy009ee.Recipe>? recipes,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Team',
      if (id != null) 'id': id?.toJson(),
      'ownerId': ownerId.toJson(),
      if (owner != null) 'owner': owner?.toJson(),
      'name': name,
      'createdAt': createdAt.toJson(),
      if (memberships != null)
        'memberships': memberships?.toJson(valueToJson: (v) => v.toJson()),
      if (invites != null)
        'invites': invites?.toJson(valueToJson: (v) => v.toJson()),
      if (recipes != null)
        'recipes': recipes?.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Team',
      if (id != null) 'id': id?.toJson(),
      'ownerId': ownerId.toJson(),
      if (owner != null) 'owner': owner?.toJson(),
      'name': name,
      'createdAt': createdAt.toJson(),
      if (memberships != null)
        'memberships': memberships?.toJson(
          valueToJson: (v) => v.toJsonForProtocol(),
        ),
      if (invites != null)
        'invites': invites?.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (recipes != null)
        'recipes': recipes?.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  static TeamInclude include({
    _iacs.AuthUserInclude? owner,
    _iromunn4.TeamMembershipIncludeList? memberships,
    _i710pi98.TeamInviteIncludeList? invites,
    _iuy009ee.RecipeIncludeList? recipes,
  }) {
    return TeamInclude._(
      owner: owner,
      memberships: memberships,
      invites: invites,
      recipes: recipes,
    );
  }

  static TeamIncludeList includeList({
    _is.WhereExpressionBuilder<TeamTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TeamTable>? orderBy,
    _is.OrderByListBuilder<TeamTable>? orderByList,
    TeamInclude? include,
  }) {
    return TeamIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Team.t),
      orderByList: orderByList?.call(Team.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TeamImpl extends Team {
  _TeamImpl({
    _is.UuidValue? id,
    required _is.UuidValue ownerId,
    _iacs.AuthUser? owner,
    required String name,
    DateTime? createdAt,
    List<_iromunn4.TeamMembership>? memberships,
    List<_i710pi98.TeamInvite>? invites,
    List<_iuy009ee.Recipe>? recipes,
  }) : super._(
         id: id,
         ownerId: ownerId,
         owner: owner,
         name: name,
         createdAt: createdAt,
         memberships: memberships,
         invites: invites,
         recipes: recipes,
       );

  /// Returns a shallow copy of this [Team]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Team copyWith({
    Object? id = _Undefined,
    _is.UuidValue? ownerId,
    Object? owner = _Undefined,
    String? name,
    DateTime? createdAt,
    Object? memberships = _Undefined,
    Object? invites = _Undefined,
    Object? recipes = _Undefined,
  }) {
    return Team(
      id: id is _is.UuidValue? ? id : this.id,
      ownerId: ownerId ?? this.ownerId,
      owner: owner is _iacs.AuthUser? ? owner : this.owner?.copyWith(),
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      memberships: memberships is List<_iromunn4.TeamMembership>?
          ? memberships
          : this.memberships?.map((e0) => e0.copyWith()).toList(),
      invites: invites is List<_i710pi98.TeamInvite>?
          ? invites
          : this.invites?.map((e0) => e0.copyWith()).toList(),
      recipes: recipes is List<_iuy009ee.Recipe>?
          ? recipes
          : this.recipes?.map((e0) => e0.copyWith()).toList(),
    );
  }
}

class TeamUpdateTable extends _is.UpdateTable<TeamTable> {
  TeamUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> ownerId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.ownerId,
        value,
      );

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class TeamTable extends _is.Table<_is.UuidValue?> {
  TeamTable({super.tableRelation}) : super(tableName: 'team') {
    updateTable = TeamUpdateTable(this);
    ownerId = _is.ColumnUuid(
      'ownerId',
      this,
    );
    name = _is.ColumnString(
      'name',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final TeamUpdateTable updateTable;

  late final _is.ColumnUuid ownerId;

  _iacs.AuthUserTable? _owner;

  late final _is.ColumnString name;

  late final _is.ColumnDateTime createdAt;

  _iromunn4.TeamMembershipTable? ___memberships;

  _is.ManyRelation<_iromunn4.TeamMembershipTable>? _memberships;

  _i710pi98.TeamInviteTable? ___invites;

  _is.ManyRelation<_i710pi98.TeamInviteTable>? _invites;

  _iuy009ee.RecipeTable? ___recipes;

  _is.ManyRelation<_iuy009ee.RecipeTable>? _recipes;

  _iacs.AuthUserTable get owner {
    if (_owner != null) return _owner!;
    _owner = _is.createRelationTable(
      relationFieldName: 'owner',
      field: Team.t.ownerId,
      foreignField: _iacs.AuthUser.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _iacs.AuthUserTable(tableRelation: foreignTableRelation),
    );
    return _owner!;
  }

  _iromunn4.TeamMembershipTable get __memberships {
    if (___memberships != null) return ___memberships!;
    ___memberships = _is.createRelationTable(
      relationFieldName: '__memberships',
      field: Team.t.id,
      foreignField: _iromunn4.TeamMembership.t.teamId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _iromunn4.TeamMembershipTable(tableRelation: foreignTableRelation),
    );
    return ___memberships!;
  }

  _i710pi98.TeamInviteTable get __invites {
    if (___invites != null) return ___invites!;
    ___invites = _is.createRelationTable(
      relationFieldName: '__invites',
      field: Team.t.id,
      foreignField: _i710pi98.TeamInvite.t.teamId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i710pi98.TeamInviteTable(tableRelation: foreignTableRelation),
    );
    return ___invites!;
  }

  _iuy009ee.RecipeTable get __recipes {
    if (___recipes != null) return ___recipes!;
    ___recipes = _is.createRelationTable(
      relationFieldName: '__recipes',
      field: Team.t.id,
      foreignField: _iuy009ee.Recipe.t.teamId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _iuy009ee.RecipeTable(tableRelation: foreignTableRelation),
    );
    return ___recipes!;
  }

  _is.ManyRelation<_iromunn4.TeamMembershipTable> get memberships {
    if (_memberships != null) return _memberships!;
    var relationTable = _is.createRelationTable(
      relationFieldName: 'memberships',
      field: Team.t.id,
      foreignField: _iromunn4.TeamMembership.t.teamId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _iromunn4.TeamMembershipTable(tableRelation: foreignTableRelation),
    );
    _memberships = _is.ManyRelation<_iromunn4.TeamMembershipTable>(
      tableWithRelations: relationTable,
      table: _iromunn4.TeamMembershipTable(
        tableRelation: relationTable.tableRelation!.lastRelation,
      ),
    );
    return _memberships!;
  }

  _is.ManyRelation<_i710pi98.TeamInviteTable> get invites {
    if (_invites != null) return _invites!;
    var relationTable = _is.createRelationTable(
      relationFieldName: 'invites',
      field: Team.t.id,
      foreignField: _i710pi98.TeamInvite.t.teamId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i710pi98.TeamInviteTable(tableRelation: foreignTableRelation),
    );
    _invites = _is.ManyRelation<_i710pi98.TeamInviteTable>(
      tableWithRelations: relationTable,
      table: _i710pi98.TeamInviteTable(
        tableRelation: relationTable.tableRelation!.lastRelation,
      ),
    );
    return _invites!;
  }

  _is.ManyRelation<_iuy009ee.RecipeTable> get recipes {
    if (_recipes != null) return _recipes!;
    var relationTable = _is.createRelationTable(
      relationFieldName: 'recipes',
      field: Team.t.id,
      foreignField: _iuy009ee.Recipe.t.teamId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _iuy009ee.RecipeTable(tableRelation: foreignTableRelation),
    );
    _recipes = _is.ManyRelation<_iuy009ee.RecipeTable>(
      tableWithRelations: relationTable,
      table: _iuy009ee.RecipeTable(
        tableRelation: relationTable.tableRelation!.lastRelation,
      ),
    );
    return _recipes!;
  }

  @override
  List<_is.Column> get columns => [
    id,
    ownerId,
    name,
    createdAt,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'owner') {
      return owner;
    }
    if (relationField == 'memberships') {
      return __memberships;
    }
    if (relationField == 'invites') {
      return __invites;
    }
    if (relationField == 'recipes') {
      return __recipes;
    }
    return null;
  }
}

class TeamInclude extends _is.IncludeObject {
  TeamInclude._({
    _iacs.AuthUserInclude? owner,
    _iromunn4.TeamMembershipIncludeList? memberships,
    _i710pi98.TeamInviteIncludeList? invites,
    _iuy009ee.RecipeIncludeList? recipes,
  }) {
    _owner = owner;
    _memberships = memberships;
    _invites = invites;
    _recipes = recipes;
  }

  _iacs.AuthUserInclude? _owner;

  _iromunn4.TeamMembershipIncludeList? _memberships;

  _i710pi98.TeamInviteIncludeList? _invites;

  _iuy009ee.RecipeIncludeList? _recipes;

  @override
  Map<String, _is.Include?> get includes => {
    'owner': _owner,
    'memberships': _memberships,
    'invites': _invites,
    'recipes': _recipes,
  };

  @override
  _is.Table<_is.UuidValue?> get table => Team.t;
}

class TeamIncludeList extends _is.IncludeList {
  TeamIncludeList._({
    _is.WhereExpressionBuilder<TeamTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Team.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => Team.t;
}

class TeamRepository {
  const TeamRepository._();

  final attach = const TeamAttachRepository._();

  final attachRow = const TeamAttachRowRepository._();

  final detach = const TeamDetachRepository._();

  final detachRow = const TeamDetachRowRepository._();

  /// Returns a list of [Team]s matching the given query parameters.
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
  Future<List<Team>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TeamTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TeamTable>? orderBy,
    _is.OrderByListBuilder<TeamTable>? orderByList,
    _is.Transaction? transaction,
    TeamInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Team>(
      where: where?.call(Team.t),
      orderBy: orderBy?.call(Team.t),
      orderByList: orderByList?.call(Team.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Team] matching the given query parameters.
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
  Future<Team?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TeamTable>? where,
    int? offset,
    _is.OrderByBuilder<TeamTable>? orderBy,
    _is.OrderByListBuilder<TeamTable>? orderByList,
    _is.Transaction? transaction,
    TeamInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Team>(
      where: where?.call(Team.t),
      orderBy: orderBy?.call(Team.t),
      orderByList: orderByList?.call(Team.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Team] by its [id] or null if no such row exists.
  Future<Team?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    TeamInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Team>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Team]s in the list and returns the inserted rows.
  ///
  /// The returned [Team]s will have their `id` fields set.
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
  Future<List<Team>> insert(
    _is.DatabaseSession session,
    List<Team> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Team>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Team] and returns the inserted row.
  ///
  /// The returned [Team] will have its `id` field set.
  Future<Team> insertRow(
    _is.DatabaseSession session,
    Team row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Team>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Team]s in the list and returns the resulting rows.
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
  /// The returned [Team]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Team>> upsert(
    _is.DatabaseSession session,
    List<Team> rows, {
    required _is.ColumnSelections<TeamTable> conflictColumns,
    _is.ColumnSelections<TeamTable>? updateColumns,
    _is.WhereExpressionBuilder<TeamTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Team>(
      rows,
      conflictColumns: conflictColumns(Team.t),
      updateColumns: updateColumns?.call(Team.t),
      updateWhere: updateWhere?.call(Team.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Team] and returns the resulting row.
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
  /// The returned [Team] will have its `id` field set.
  Future<Team?> upsertRow(
    _is.DatabaseSession session,
    Team row, {
    required _is.ColumnSelections<TeamTable> conflictColumns,
    _is.ColumnSelections<TeamTable>? updateColumns,
    _is.WhereExpressionBuilder<TeamTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Team>(
      row,
      conflictColumns: conflictColumns(Team.t),
      updateColumns: updateColumns?.call(Team.t),
      updateWhere: updateWhere?.call(Team.t),
      transaction: transaction,
    );
  }

  /// Updates all [Team]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Team>> update(
    _is.DatabaseSession session,
    List<Team> rows, {
    _is.ColumnSelections<TeamTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Team>(
      rows,
      columns: columns?.call(Team.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Team]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Team> updateRow(
    _is.DatabaseSession session,
    Team row, {
    _is.ColumnSelections<TeamTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Team>(
      row,
      columns: columns?.call(Team.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Team] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Team?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<TeamUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Team>(
      id,
      columnValues: columnValues(Team.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Team]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Team>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<TeamUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<TeamTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TeamTable>? orderBy,
    _is.OrderByListBuilder<TeamTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Team>(
      columnValues: columnValues(Team.t.updateTable),
      where: where(Team.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Team.t),
      orderByList: orderByList?.call(Team.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Team]s in the list and returns the deleted rows.
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
  Future<List<Team>> delete(
    _is.DatabaseSession session,
    List<Team> rows, {
    _is.OrderByBuilder<TeamTable>? orderBy,
    _is.OrderByListBuilder<TeamTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Team>(
      rows,
      orderBy: orderBy?.call(Team.t),
      orderByList: orderByList?.call(Team.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Team].
  Future<Team> deleteRow(
    _is.DatabaseSession session,
    Team row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Team>(
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
  Future<List<Team>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TeamTable> where,
    _is.OrderByBuilder<TeamTable>? orderBy,
    _is.OrderByListBuilder<TeamTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Team>(
      where: where(Team.t),
      orderBy: orderBy?.call(Team.t),
      orderByList: orderByList?.call(Team.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TeamTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Team>(
      where: where?.call(Team.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Team] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TeamTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Team>(
      where: where(Team.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class TeamAttachRepository {
  const TeamAttachRepository._();

  /// Creates a relation between this [Team] and the given [TeamMembership]s
  /// by setting each [TeamMembership]'s foreign key `teamId` to refer to this [Team].
  Future<void> memberships(
    _is.DatabaseSession session,
    Team team,
    List<_iromunn4.TeamMembership> teamMembership, {
    _is.Transaction? transaction,
  }) async {
    if (teamMembership.any((e) => e.id == null)) {
      throw ArgumentError.notNull('teamMembership.id');
    }
    if (team.id == null) {
      throw ArgumentError.notNull('team.id');
    }

    var $teamMembership = teamMembership
        .map((e) => e.copyWith(teamId: team.id))
        .toList();
    await session.db.update<_iromunn4.TeamMembership>(
      $teamMembership,
      columns: [_iromunn4.TeamMembership.t.teamId],
      transaction: transaction,
    );
  }

  /// Creates a relation between this [Team] and the given [TeamInvite]s
  /// by setting each [TeamInvite]'s foreign key `teamId` to refer to this [Team].
  Future<void> invites(
    _is.DatabaseSession session,
    Team team,
    List<_i710pi98.TeamInvite> teamInvite, {
    _is.Transaction? transaction,
  }) async {
    if (teamInvite.any((e) => e.id == null)) {
      throw ArgumentError.notNull('teamInvite.id');
    }
    if (team.id == null) {
      throw ArgumentError.notNull('team.id');
    }

    var $teamInvite = teamInvite
        .map((e) => e.copyWith(teamId: team.id))
        .toList();
    await session.db.update<_i710pi98.TeamInvite>(
      $teamInvite,
      columns: [_i710pi98.TeamInvite.t.teamId],
      transaction: transaction,
    );
  }

  /// Creates a relation between this [Team] and the given [Recipe]s
  /// by setting each [Recipe]'s foreign key `teamId` to refer to this [Team].
  Future<void> recipes(
    _is.DatabaseSession session,
    Team team,
    List<_iuy009ee.Recipe> recipe, {
    _is.Transaction? transaction,
  }) async {
    if (recipe.any((e) => e.id == null)) {
      throw ArgumentError.notNull('recipe.id');
    }
    if (team.id == null) {
      throw ArgumentError.notNull('team.id');
    }

    var $recipe = recipe.map((e) => e.copyWith(teamId: team.id)).toList();
    await session.db.update<_iuy009ee.Recipe>(
      $recipe,
      columns: [_iuy009ee.Recipe.t.teamId],
      transaction: transaction,
    );
  }
}

class TeamAttachRowRepository {
  const TeamAttachRowRepository._();

  /// Creates a relation between the given [Team] and [AuthUser]
  /// by setting the [Team]'s foreign key `ownerId` to refer to the [AuthUser].
  Future<void> owner(
    _is.DatabaseSession session,
    Team team,
    _iacs.AuthUser owner, {
    _is.Transaction? transaction,
  }) async {
    if (team.id == null) {
      throw ArgumentError.notNull('team.id');
    }
    if (owner.id == null) {
      throw ArgumentError.notNull('owner.id');
    }

    var $team = team.copyWith(ownerId: owner.id);
    await session.db.updateRow<Team>(
      $team,
      columns: [Team.t.ownerId],
      transaction: transaction,
    );
  }

  /// Creates a relation between this [Team] and the given [TeamMembership]
  /// by setting the [TeamMembership]'s foreign key `teamId` to refer to this [Team].
  Future<void> memberships(
    _is.DatabaseSession session,
    Team team,
    _iromunn4.TeamMembership teamMembership, {
    _is.Transaction? transaction,
  }) async {
    if (teamMembership.id == null) {
      throw ArgumentError.notNull('teamMembership.id');
    }
    if (team.id == null) {
      throw ArgumentError.notNull('team.id');
    }

    var $teamMembership = teamMembership.copyWith(teamId: team.id);
    await session.db.updateRow<_iromunn4.TeamMembership>(
      $teamMembership,
      columns: [_iromunn4.TeamMembership.t.teamId],
      transaction: transaction,
    );
  }

  /// Creates a relation between this [Team] and the given [TeamInvite]
  /// by setting the [TeamInvite]'s foreign key `teamId` to refer to this [Team].
  Future<void> invites(
    _is.DatabaseSession session,
    Team team,
    _i710pi98.TeamInvite teamInvite, {
    _is.Transaction? transaction,
  }) async {
    if (teamInvite.id == null) {
      throw ArgumentError.notNull('teamInvite.id');
    }
    if (team.id == null) {
      throw ArgumentError.notNull('team.id');
    }

    var $teamInvite = teamInvite.copyWith(teamId: team.id);
    await session.db.updateRow<_i710pi98.TeamInvite>(
      $teamInvite,
      columns: [_i710pi98.TeamInvite.t.teamId],
      transaction: transaction,
    );
  }

  /// Creates a relation between this [Team] and the given [Recipe]
  /// by setting the [Recipe]'s foreign key `teamId` to refer to this [Team].
  Future<void> recipes(
    _is.DatabaseSession session,
    Team team,
    _iuy009ee.Recipe recipe, {
    _is.Transaction? transaction,
  }) async {
    if (recipe.id == null) {
      throw ArgumentError.notNull('recipe.id');
    }
    if (team.id == null) {
      throw ArgumentError.notNull('team.id');
    }

    var $recipe = recipe.copyWith(teamId: team.id);
    await session.db.updateRow<_iuy009ee.Recipe>(
      $recipe,
      columns: [_iuy009ee.Recipe.t.teamId],
      transaction: transaction,
    );
  }
}

class TeamDetachRepository {
  const TeamDetachRepository._();

  /// Detaches the relation between this [Team] and the given [Recipe]
  /// by setting the [Recipe]'s foreign key `teamId` to `null`.
  ///
  /// This removes the association between the two models without deleting
  /// the related record.
  Future<void> recipes(
    _is.DatabaseSession session,
    List<_iuy009ee.Recipe> recipe, {
    _is.Transaction? transaction,
  }) async {
    if (recipe.any((e) => e.id == null)) {
      throw ArgumentError.notNull('recipe.id');
    }

    var $recipe = recipe.map((e) => e.copyWith(teamId: null)).toList();
    await session.db.update<_iuy009ee.Recipe>(
      $recipe,
      columns: [_iuy009ee.Recipe.t.teamId],
      transaction: transaction,
    );
  }
}

class TeamDetachRowRepository {
  const TeamDetachRowRepository._();

  /// Detaches the relation between this [Team] and the given [Recipe]
  /// by setting the [Recipe]'s foreign key `teamId` to `null`.
  ///
  /// This removes the association between the two models without deleting
  /// the related record.
  Future<void> recipes(
    _is.DatabaseSession session,
    _iuy009ee.Recipe recipe, {
    _is.Transaction? transaction,
  }) async {
    if (recipe.id == null) {
      throw ArgumentError.notNull('recipe.id');
    }

    var $recipe = recipe.copyWith(teamId: null);
    await session.db.updateRow<_iuy009ee.Recipe>(
      $recipe,
      columns: [_iuy009ee.Recipe.t.teamId],
      transaction: transaction,
    );
  }
}
