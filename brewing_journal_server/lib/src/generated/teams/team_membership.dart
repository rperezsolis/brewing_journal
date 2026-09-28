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
import '../teams/team.dart' as _izqfkhlk;
import '../teams/team_role.dart' as _iea06rdc;

abstract class TeamMembership
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  TeamMembership._({
    this.id,
    required this.teamId,
    this.team,
    required this.memberId,
    this.member,
    required this.role,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory TeamMembership({
    _is.UuidValue? id,
    required _is.UuidValue teamId,
    _izqfkhlk.Team? team,
    required _is.UuidValue memberId,
    _iacs.AuthUser? member,
    required _iea06rdc.TeamRole role,
    DateTime? createdAt,
  }) = _TeamMembershipImpl;

  factory TeamMembership.fromJson(Map<String, dynamic> jsonSerialization) {
    return TeamMembership(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      teamId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['teamId']),
      team: jsonSerialization['team'] == null
          ? null
          : _i8dlmk64.Protocol().deserialize<_izqfkhlk.Team>(
              jsonSerialization['team'],
            ),
      memberId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['memberId'],
      ),
      member: jsonSerialization['member'] == null
          ? null
          : _i8dlmk64.Protocol().deserialize<_iacs.AuthUser>(
              jsonSerialization['member'],
            ),
      role: _iea06rdc.TeamRole.fromJson((jsonSerialization['role'] as String)),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = TeamMembershipTable();

  static const db = TeamMembershipRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue teamId;

  _izqfkhlk.Team? team;

  _is.UuidValue memberId;

  _iacs.AuthUser? member;

  _iea06rdc.TeamRole role;

  DateTime createdAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [TeamMembership]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TeamMembership copyWith({
    _is.UuidValue? id,
    _is.UuidValue? teamId,
    _izqfkhlk.Team? team,
    _is.UuidValue? memberId,
    _iacs.AuthUser? member,
    _iea06rdc.TeamRole? role,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TeamMembership',
      if (id != null) 'id': id?.toJson(),
      'teamId': teamId.toJson(),
      if (team != null) 'team': team?.toJson(),
      'memberId': memberId.toJson(),
      if (member != null) 'member': member?.toJson(),
      'role': role.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TeamMembership',
      if (id != null) 'id': id?.toJson(),
      'teamId': teamId.toJson(),
      if (team != null) 'team': team?.toJsonForProtocol(),
      'memberId': memberId.toJson(),
      if (member != null) 'member': member?.toJson(),
      'role': role.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  static TeamMembershipInclude include({
    _izqfkhlk.TeamInclude? team,
    _iacs.AuthUserInclude? member,
  }) {
    return TeamMembershipInclude._(
      team: team,
      member: member,
    );
  }

  static TeamMembershipIncludeList includeList({
    _is.WhereExpressionBuilder<TeamMembershipTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TeamMembershipTable>? orderBy,
    _is.OrderByListBuilder<TeamMembershipTable>? orderByList,
    TeamMembershipInclude? include,
  }) {
    return TeamMembershipIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TeamMembership.t),
      orderByList: orderByList?.call(TeamMembership.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TeamMembershipImpl extends TeamMembership {
  _TeamMembershipImpl({
    _is.UuidValue? id,
    required _is.UuidValue teamId,
    _izqfkhlk.Team? team,
    required _is.UuidValue memberId,
    _iacs.AuthUser? member,
    required _iea06rdc.TeamRole role,
    DateTime? createdAt,
  }) : super._(
         id: id,
         teamId: teamId,
         team: team,
         memberId: memberId,
         member: member,
         role: role,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [TeamMembership]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TeamMembership copyWith({
    Object? id = _Undefined,
    _is.UuidValue? teamId,
    Object? team = _Undefined,
    _is.UuidValue? memberId,
    Object? member = _Undefined,
    _iea06rdc.TeamRole? role,
    DateTime? createdAt,
  }) {
    return TeamMembership(
      id: id is _is.UuidValue? ? id : this.id,
      teamId: teamId ?? this.teamId,
      team: team is _izqfkhlk.Team? ? team : this.team?.copyWith(),
      memberId: memberId ?? this.memberId,
      member: member is _iacs.AuthUser? ? member : this.member?.copyWith(),
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class TeamMembershipUpdateTable extends _is.UpdateTable<TeamMembershipTable> {
  TeamMembershipUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> teamId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.teamId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> memberId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.memberId,
        value,
      );

  _is.ColumnValue<_iea06rdc.TeamRole, _iea06rdc.TeamRole> role(
    _iea06rdc.TeamRole value,
  ) => _is.ColumnValue(
    table.role,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class TeamMembershipTable extends _is.Table<_is.UuidValue?> {
  TeamMembershipTable({super.tableRelation})
    : super(tableName: 'team_membership') {
    updateTable = TeamMembershipUpdateTable(this);
    teamId = _is.ColumnUuid(
      'teamId',
      this,
    );
    memberId = _is.ColumnUuid(
      'memberId',
      this,
    );
    role = _is.ColumnEnum(
      'role',
      this,
      _is.EnumSerialization.byName,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final TeamMembershipUpdateTable updateTable;

  late final _is.ColumnUuid teamId;

  _izqfkhlk.TeamTable? _team;

  late final _is.ColumnUuid memberId;

  _iacs.AuthUserTable? _member;

  late final _is.ColumnEnum<_iea06rdc.TeamRole> role;

  late final _is.ColumnDateTime createdAt;

  _izqfkhlk.TeamTable get team {
    if (_team != null) return _team!;
    _team = _is.createRelationTable(
      relationFieldName: 'team',
      field: TeamMembership.t.teamId,
      foreignField: _izqfkhlk.Team.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _izqfkhlk.TeamTable(tableRelation: foreignTableRelation),
    );
    return _team!;
  }

  _iacs.AuthUserTable get member {
    if (_member != null) return _member!;
    _member = _is.createRelationTable(
      relationFieldName: 'member',
      field: TeamMembership.t.memberId,
      foreignField: _iacs.AuthUser.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _iacs.AuthUserTable(tableRelation: foreignTableRelation),
    );
    return _member!;
  }

  @override
  List<_is.Column> get columns => [
    id,
    teamId,
    memberId,
    role,
    createdAt,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'team') {
      return team;
    }
    if (relationField == 'member') {
      return member;
    }
    return null;
  }
}

class TeamMembershipInclude extends _is.IncludeObject {
  TeamMembershipInclude._({
    _izqfkhlk.TeamInclude? team,
    _iacs.AuthUserInclude? member,
  }) {
    _team = team;
    _member = member;
  }

  _izqfkhlk.TeamInclude? _team;

  _iacs.AuthUserInclude? _member;

  @override
  Map<String, _is.Include?> get includes => {
    'team': _team,
    'member': _member,
  };

  @override
  _is.Table<_is.UuidValue?> get table => TeamMembership.t;
}

class TeamMembershipIncludeList extends _is.IncludeList {
  TeamMembershipIncludeList._({
    _is.WhereExpressionBuilder<TeamMembershipTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(TeamMembership.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => TeamMembership.t;
}

class TeamMembershipRepository {
  const TeamMembershipRepository._();

  final attachRow = const TeamMembershipAttachRowRepository._();

  /// Returns a list of [TeamMembership]s matching the given query parameters.
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
  Future<List<TeamMembership>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TeamMembershipTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TeamMembershipTable>? orderBy,
    _is.OrderByListBuilder<TeamMembershipTable>? orderByList,
    _is.Transaction? transaction,
    TeamMembershipInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<TeamMembership>(
      where: where?.call(TeamMembership.t),
      orderBy: orderBy?.call(TeamMembership.t),
      orderByList: orderByList?.call(TeamMembership.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [TeamMembership] matching the given query parameters.
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
  Future<TeamMembership?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TeamMembershipTable>? where,
    int? offset,
    _is.OrderByBuilder<TeamMembershipTable>? orderBy,
    _is.OrderByListBuilder<TeamMembershipTable>? orderByList,
    _is.Transaction? transaction,
    TeamMembershipInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<TeamMembership>(
      where: where?.call(TeamMembership.t),
      orderBy: orderBy?.call(TeamMembership.t),
      orderByList: orderByList?.call(TeamMembership.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [TeamMembership] by its [id] or null if no such row exists.
  Future<TeamMembership?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    TeamMembershipInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<TeamMembership>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [TeamMembership]s in the list and returns the inserted rows.
  ///
  /// The returned [TeamMembership]s will have their `id` fields set.
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
  Future<List<TeamMembership>> insert(
    _is.DatabaseSession session,
    List<TeamMembership> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<TeamMembership>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [TeamMembership] and returns the inserted row.
  ///
  /// The returned [TeamMembership] will have its `id` field set.
  Future<TeamMembership> insertRow(
    _is.DatabaseSession session,
    TeamMembership row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<TeamMembership>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [TeamMembership]s in the list and returns the resulting rows.
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
  /// The returned [TeamMembership]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TeamMembership>> upsert(
    _is.DatabaseSession session,
    List<TeamMembership> rows, {
    required _is.ColumnSelections<TeamMembershipTable> conflictColumns,
    _is.ColumnSelections<TeamMembershipTable>? updateColumns,
    _is.WhereExpressionBuilder<TeamMembershipTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<TeamMembership>(
      rows,
      conflictColumns: conflictColumns(TeamMembership.t),
      updateColumns: updateColumns?.call(TeamMembership.t),
      updateWhere: updateWhere?.call(TeamMembership.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [TeamMembership] and returns the resulting row.
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
  /// The returned [TeamMembership] will have its `id` field set.
  Future<TeamMembership?> upsertRow(
    _is.DatabaseSession session,
    TeamMembership row, {
    required _is.ColumnSelections<TeamMembershipTable> conflictColumns,
    _is.ColumnSelections<TeamMembershipTable>? updateColumns,
    _is.WhereExpressionBuilder<TeamMembershipTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<TeamMembership>(
      row,
      conflictColumns: conflictColumns(TeamMembership.t),
      updateColumns: updateColumns?.call(TeamMembership.t),
      updateWhere: updateWhere?.call(TeamMembership.t),
      transaction: transaction,
    );
  }

  /// Updates all [TeamMembership]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TeamMembership>> update(
    _is.DatabaseSession session,
    List<TeamMembership> rows, {
    _is.ColumnSelections<TeamMembershipTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<TeamMembership>(
      rows,
      columns: columns?.call(TeamMembership.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [TeamMembership]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<TeamMembership> updateRow(
    _is.DatabaseSession session,
    TeamMembership row, {
    _is.ColumnSelections<TeamMembershipTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<TeamMembership>(
      row,
      columns: columns?.call(TeamMembership.t),
      transaction: transaction,
    );
  }

  /// Updates a single [TeamMembership] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<TeamMembership?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<TeamMembershipUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<TeamMembership>(
      id,
      columnValues: columnValues(TeamMembership.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [TeamMembership]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TeamMembership>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<TeamMembershipUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<TeamMembershipTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TeamMembershipTable>? orderBy,
    _is.OrderByListBuilder<TeamMembershipTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<TeamMembership>(
      columnValues: columnValues(TeamMembership.t.updateTable),
      where: where(TeamMembership.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TeamMembership.t),
      orderByList: orderByList?.call(TeamMembership.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [TeamMembership]s in the list and returns the deleted rows.
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
  Future<List<TeamMembership>> delete(
    _is.DatabaseSession session,
    List<TeamMembership> rows, {
    _is.OrderByBuilder<TeamMembershipTable>? orderBy,
    _is.OrderByListBuilder<TeamMembershipTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<TeamMembership>(
      rows,
      orderBy: orderBy?.call(TeamMembership.t),
      orderByList: orderByList?.call(TeamMembership.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [TeamMembership].
  Future<TeamMembership> deleteRow(
    _is.DatabaseSession session,
    TeamMembership row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<TeamMembership>(
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
  Future<List<TeamMembership>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TeamMembershipTable> where,
    _is.OrderByBuilder<TeamMembershipTable>? orderBy,
    _is.OrderByListBuilder<TeamMembershipTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<TeamMembership>(
      where: where(TeamMembership.t),
      orderBy: orderBy?.call(TeamMembership.t),
      orderByList: orderByList?.call(TeamMembership.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TeamMembershipTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<TeamMembership>(
      where: where?.call(TeamMembership.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [TeamMembership] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TeamMembershipTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<TeamMembership>(
      where: where(TeamMembership.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class TeamMembershipAttachRowRepository {
  const TeamMembershipAttachRowRepository._();

  /// Creates a relation between the given [TeamMembership] and [Team]
  /// by setting the [TeamMembership]'s foreign key `teamId` to refer to the [Team].
  Future<void> team(
    _is.DatabaseSession session,
    TeamMembership teamMembership,
    _izqfkhlk.Team team, {
    _is.Transaction? transaction,
  }) async {
    if (teamMembership.id == null) {
      throw ArgumentError.notNull('teamMembership.id');
    }
    if (team.id == null) {
      throw ArgumentError.notNull('team.id');
    }

    var $teamMembership = teamMembership.copyWith(teamId: team.id);
    await session.db.updateRow<TeamMembership>(
      $teamMembership,
      columns: [TeamMembership.t.teamId],
      transaction: transaction,
    );
  }

  /// Creates a relation between the given [TeamMembership] and [AuthUser]
  /// by setting the [TeamMembership]'s foreign key `memberId` to refer to the [AuthUser].
  Future<void> member(
    _is.DatabaseSession session,
    TeamMembership teamMembership,
    _iacs.AuthUser member, {
    _is.Transaction? transaction,
  }) async {
    if (teamMembership.id == null) {
      throw ArgumentError.notNull('teamMembership.id');
    }
    if (member.id == null) {
      throw ArgumentError.notNull('member.id');
    }

    var $teamMembership = teamMembership.copyWith(memberId: member.id);
    await session.db.updateRow<TeamMembership>(
      $teamMembership,
      columns: [TeamMembership.t.memberId],
      transaction: transaction,
    );
  }
}
