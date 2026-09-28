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

abstract class TeamInvite
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  TeamInvite._({
    this.id,
    required this.teamId,
    this.team,
    required this.createdById,
    this.createdBy,
    required this.token,
    required this.role,
    required this.expiresAt,
    this.usedAt,
    this.usedById,
    this.usedBy,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory TeamInvite({
    _is.UuidValue? id,
    required _is.UuidValue teamId,
    _izqfkhlk.Team? team,
    required _is.UuidValue createdById,
    _iacs.AuthUser? createdBy,
    required String token,
    required _iea06rdc.TeamRole role,
    required DateTime expiresAt,
    DateTime? usedAt,
    _is.UuidValue? usedById,
    _iacs.AuthUser? usedBy,
    DateTime? createdAt,
  }) = _TeamInviteImpl;

  factory TeamInvite.fromJson(Map<String, dynamic> jsonSerialization) {
    return TeamInvite(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      teamId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['teamId']),
      team: jsonSerialization['team'] == null
          ? null
          : _i8dlmk64.Protocol().deserialize<_izqfkhlk.Team>(
              jsonSerialization['team'],
            ),
      createdById: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['createdById'],
      ),
      createdBy: jsonSerialization['createdBy'] == null
          ? null
          : _i8dlmk64.Protocol().deserialize<_iacs.AuthUser>(
              jsonSerialization['createdBy'],
            ),
      token: jsonSerialization['token'] as String,
      role: _iea06rdc.TeamRole.fromJson((jsonSerialization['role'] as String)),
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      usedAt: jsonSerialization['usedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['usedAt']),
      usedById: jsonSerialization['usedById'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['usedById']),
      usedBy: jsonSerialization['usedBy'] == null
          ? null
          : _i8dlmk64.Protocol().deserialize<_iacs.AuthUser>(
              jsonSerialization['usedBy'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = TeamInviteTable();

  static const db = TeamInviteRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue teamId;

  _izqfkhlk.Team? team;

  _is.UuidValue createdById;

  _iacs.AuthUser? createdBy;

  String token;

  _iea06rdc.TeamRole role;

  DateTime expiresAt;

  DateTime? usedAt;

  _is.UuidValue? usedById;

  _iacs.AuthUser? usedBy;

  DateTime createdAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [TeamInvite]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TeamInvite copyWith({
    _is.UuidValue? id,
    _is.UuidValue? teamId,
    _izqfkhlk.Team? team,
    _is.UuidValue? createdById,
    _iacs.AuthUser? createdBy,
    String? token,
    _iea06rdc.TeamRole? role,
    DateTime? expiresAt,
    DateTime? usedAt,
    _is.UuidValue? usedById,
    _iacs.AuthUser? usedBy,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TeamInvite',
      if (id != null) 'id': id?.toJson(),
      'teamId': teamId.toJson(),
      if (team != null) 'team': team?.toJson(),
      'createdById': createdById.toJson(),
      if (createdBy != null) 'createdBy': createdBy?.toJson(),
      'token': token,
      'role': role.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (usedAt != null) 'usedAt': usedAt?.toJson(),
      if (usedById != null) 'usedById': usedById?.toJson(),
      if (usedBy != null) 'usedBy': usedBy?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TeamInvite',
      if (id != null) 'id': id?.toJson(),
      'teamId': teamId.toJson(),
      if (team != null) 'team': team?.toJsonForProtocol(),
      'createdById': createdById.toJson(),
      if (createdBy != null) 'createdBy': createdBy?.toJson(),
      'token': token,
      'role': role.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (usedAt != null) 'usedAt': usedAt?.toJson(),
      if (usedById != null) 'usedById': usedById?.toJson(),
      if (usedBy != null) 'usedBy': usedBy?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  static TeamInviteInclude include({
    _izqfkhlk.TeamInclude? team,
    _iacs.AuthUserInclude? createdBy,
    _iacs.AuthUserInclude? usedBy,
  }) {
    return TeamInviteInclude._(
      team: team,
      createdBy: createdBy,
      usedBy: usedBy,
    );
  }

  static TeamInviteIncludeList includeList({
    _is.WhereExpressionBuilder<TeamInviteTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TeamInviteTable>? orderBy,
    _is.OrderByListBuilder<TeamInviteTable>? orderByList,
    TeamInviteInclude? include,
  }) {
    return TeamInviteIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TeamInvite.t),
      orderByList: orderByList?.call(TeamInvite.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TeamInviteImpl extends TeamInvite {
  _TeamInviteImpl({
    _is.UuidValue? id,
    required _is.UuidValue teamId,
    _izqfkhlk.Team? team,
    required _is.UuidValue createdById,
    _iacs.AuthUser? createdBy,
    required String token,
    required _iea06rdc.TeamRole role,
    required DateTime expiresAt,
    DateTime? usedAt,
    _is.UuidValue? usedById,
    _iacs.AuthUser? usedBy,
    DateTime? createdAt,
  }) : super._(
         id: id,
         teamId: teamId,
         team: team,
         createdById: createdById,
         createdBy: createdBy,
         token: token,
         role: role,
         expiresAt: expiresAt,
         usedAt: usedAt,
         usedById: usedById,
         usedBy: usedBy,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [TeamInvite]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TeamInvite copyWith({
    Object? id = _Undefined,
    _is.UuidValue? teamId,
    Object? team = _Undefined,
    _is.UuidValue? createdById,
    Object? createdBy = _Undefined,
    String? token,
    _iea06rdc.TeamRole? role,
    DateTime? expiresAt,
    Object? usedAt = _Undefined,
    Object? usedById = _Undefined,
    Object? usedBy = _Undefined,
    DateTime? createdAt,
  }) {
    return TeamInvite(
      id: id is _is.UuidValue? ? id : this.id,
      teamId: teamId ?? this.teamId,
      team: team is _izqfkhlk.Team? ? team : this.team?.copyWith(),
      createdById: createdById ?? this.createdById,
      createdBy: createdBy is _iacs.AuthUser?
          ? createdBy
          : this.createdBy?.copyWith(),
      token: token ?? this.token,
      role: role ?? this.role,
      expiresAt: expiresAt ?? this.expiresAt,
      usedAt: usedAt is DateTime? ? usedAt : this.usedAt,
      usedById: usedById is _is.UuidValue? ? usedById : this.usedById,
      usedBy: usedBy is _iacs.AuthUser? ? usedBy : this.usedBy?.copyWith(),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class TeamInviteUpdateTable extends _is.UpdateTable<TeamInviteTable> {
  TeamInviteUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> teamId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.teamId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> createdById(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.createdById,
    value,
  );

  _is.ColumnValue<String, String> token(String value) => _is.ColumnValue(
    table.token,
    value,
  );

  _is.ColumnValue<_iea06rdc.TeamRole, _iea06rdc.TeamRole> role(
    _iea06rdc.TeamRole value,
  ) => _is.ColumnValue(
    table.role,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _is.ColumnValue(
        table.expiresAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> usedAt(DateTime? value) =>
      _is.ColumnValue(
        table.usedAt,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> usedById(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.usedById,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class TeamInviteTable extends _is.Table<_is.UuidValue?> {
  TeamInviteTable({super.tableRelation}) : super(tableName: 'team_invite') {
    updateTable = TeamInviteUpdateTable(this);
    teamId = _is.ColumnUuid(
      'teamId',
      this,
    );
    createdById = _is.ColumnUuid(
      'createdById',
      this,
    );
    token = _is.ColumnString(
      'token',
      this,
    );
    role = _is.ColumnEnum(
      'role',
      this,
      _is.EnumSerialization.byName,
    );
    expiresAt = _is.ColumnDateTime(
      'expiresAt',
      this,
    );
    usedAt = _is.ColumnDateTime(
      'usedAt',
      this,
    );
    usedById = _is.ColumnUuid(
      'usedById',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final TeamInviteUpdateTable updateTable;

  late final _is.ColumnUuid teamId;

  _izqfkhlk.TeamTable? _team;

  late final _is.ColumnUuid createdById;

  _iacs.AuthUserTable? _createdBy;

  late final _is.ColumnString token;

  late final _is.ColumnEnum<_iea06rdc.TeamRole> role;

  late final _is.ColumnDateTime expiresAt;

  late final _is.ColumnDateTime usedAt;

  late final _is.ColumnUuid usedById;

  _iacs.AuthUserTable? _usedBy;

  late final _is.ColumnDateTime createdAt;

  _izqfkhlk.TeamTable get team {
    if (_team != null) return _team!;
    _team = _is.createRelationTable(
      relationFieldName: 'team',
      field: TeamInvite.t.teamId,
      foreignField: _izqfkhlk.Team.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _izqfkhlk.TeamTable(tableRelation: foreignTableRelation),
    );
    return _team!;
  }

  _iacs.AuthUserTable get createdBy {
    if (_createdBy != null) return _createdBy!;
    _createdBy = _is.createRelationTable(
      relationFieldName: 'createdBy',
      field: TeamInvite.t.createdById,
      foreignField: _iacs.AuthUser.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _iacs.AuthUserTable(tableRelation: foreignTableRelation),
    );
    return _createdBy!;
  }

  _iacs.AuthUserTable get usedBy {
    if (_usedBy != null) return _usedBy!;
    _usedBy = _is.createRelationTable(
      relationFieldName: 'usedBy',
      field: TeamInvite.t.usedById,
      foreignField: _iacs.AuthUser.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _iacs.AuthUserTable(tableRelation: foreignTableRelation),
    );
    return _usedBy!;
  }

  @override
  List<_is.Column> get columns => [
    id,
    teamId,
    createdById,
    token,
    role,
    expiresAt,
    usedAt,
    usedById,
    createdAt,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'team') {
      return team;
    }
    if (relationField == 'createdBy') {
      return createdBy;
    }
    if (relationField == 'usedBy') {
      return usedBy;
    }
    return null;
  }
}

class TeamInviteInclude extends _is.IncludeObject {
  TeamInviteInclude._({
    _izqfkhlk.TeamInclude? team,
    _iacs.AuthUserInclude? createdBy,
    _iacs.AuthUserInclude? usedBy,
  }) {
    _team = team;
    _createdBy = createdBy;
    _usedBy = usedBy;
  }

  _izqfkhlk.TeamInclude? _team;

  _iacs.AuthUserInclude? _createdBy;

  _iacs.AuthUserInclude? _usedBy;

  @override
  Map<String, _is.Include?> get includes => {
    'team': _team,
    'createdBy': _createdBy,
    'usedBy': _usedBy,
  };

  @override
  _is.Table<_is.UuidValue?> get table => TeamInvite.t;
}

class TeamInviteIncludeList extends _is.IncludeList {
  TeamInviteIncludeList._({
    _is.WhereExpressionBuilder<TeamInviteTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(TeamInvite.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => TeamInvite.t;
}

class TeamInviteRepository {
  const TeamInviteRepository._();

  final attachRow = const TeamInviteAttachRowRepository._();

  final detachRow = const TeamInviteDetachRowRepository._();

  /// Returns a list of [TeamInvite]s matching the given query parameters.
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
  Future<List<TeamInvite>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TeamInviteTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TeamInviteTable>? orderBy,
    _is.OrderByListBuilder<TeamInviteTable>? orderByList,
    _is.Transaction? transaction,
    TeamInviteInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<TeamInvite>(
      where: where?.call(TeamInvite.t),
      orderBy: orderBy?.call(TeamInvite.t),
      orderByList: orderByList?.call(TeamInvite.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [TeamInvite] matching the given query parameters.
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
  Future<TeamInvite?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TeamInviteTable>? where,
    int? offset,
    _is.OrderByBuilder<TeamInviteTable>? orderBy,
    _is.OrderByListBuilder<TeamInviteTable>? orderByList,
    _is.Transaction? transaction,
    TeamInviteInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<TeamInvite>(
      where: where?.call(TeamInvite.t),
      orderBy: orderBy?.call(TeamInvite.t),
      orderByList: orderByList?.call(TeamInvite.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [TeamInvite] by its [id] or null if no such row exists.
  Future<TeamInvite?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    TeamInviteInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<TeamInvite>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [TeamInvite]s in the list and returns the inserted rows.
  ///
  /// The returned [TeamInvite]s will have their `id` fields set.
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
  Future<List<TeamInvite>> insert(
    _is.DatabaseSession session,
    List<TeamInvite> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<TeamInvite>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [TeamInvite] and returns the inserted row.
  ///
  /// The returned [TeamInvite] will have its `id` field set.
  Future<TeamInvite> insertRow(
    _is.DatabaseSession session,
    TeamInvite row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<TeamInvite>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [TeamInvite]s in the list and returns the resulting rows.
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
  /// The returned [TeamInvite]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TeamInvite>> upsert(
    _is.DatabaseSession session,
    List<TeamInvite> rows, {
    required _is.ColumnSelections<TeamInviteTable> conflictColumns,
    _is.ColumnSelections<TeamInviteTable>? updateColumns,
    _is.WhereExpressionBuilder<TeamInviteTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<TeamInvite>(
      rows,
      conflictColumns: conflictColumns(TeamInvite.t),
      updateColumns: updateColumns?.call(TeamInvite.t),
      updateWhere: updateWhere?.call(TeamInvite.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [TeamInvite] and returns the resulting row.
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
  /// The returned [TeamInvite] will have its `id` field set.
  Future<TeamInvite?> upsertRow(
    _is.DatabaseSession session,
    TeamInvite row, {
    required _is.ColumnSelections<TeamInviteTable> conflictColumns,
    _is.ColumnSelections<TeamInviteTable>? updateColumns,
    _is.WhereExpressionBuilder<TeamInviteTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<TeamInvite>(
      row,
      conflictColumns: conflictColumns(TeamInvite.t),
      updateColumns: updateColumns?.call(TeamInvite.t),
      updateWhere: updateWhere?.call(TeamInvite.t),
      transaction: transaction,
    );
  }

  /// Updates all [TeamInvite]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TeamInvite>> update(
    _is.DatabaseSession session,
    List<TeamInvite> rows, {
    _is.ColumnSelections<TeamInviteTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<TeamInvite>(
      rows,
      columns: columns?.call(TeamInvite.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [TeamInvite]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<TeamInvite> updateRow(
    _is.DatabaseSession session,
    TeamInvite row, {
    _is.ColumnSelections<TeamInviteTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<TeamInvite>(
      row,
      columns: columns?.call(TeamInvite.t),
      transaction: transaction,
    );
  }

  /// Updates a single [TeamInvite] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<TeamInvite?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<TeamInviteUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<TeamInvite>(
      id,
      columnValues: columnValues(TeamInvite.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [TeamInvite]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TeamInvite>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<TeamInviteUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<TeamInviteTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TeamInviteTable>? orderBy,
    _is.OrderByListBuilder<TeamInviteTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<TeamInvite>(
      columnValues: columnValues(TeamInvite.t.updateTable),
      where: where(TeamInvite.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TeamInvite.t),
      orderByList: orderByList?.call(TeamInvite.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [TeamInvite]s in the list and returns the deleted rows.
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
  Future<List<TeamInvite>> delete(
    _is.DatabaseSession session,
    List<TeamInvite> rows, {
    _is.OrderByBuilder<TeamInviteTable>? orderBy,
    _is.OrderByListBuilder<TeamInviteTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<TeamInvite>(
      rows,
      orderBy: orderBy?.call(TeamInvite.t),
      orderByList: orderByList?.call(TeamInvite.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [TeamInvite].
  Future<TeamInvite> deleteRow(
    _is.DatabaseSession session,
    TeamInvite row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<TeamInvite>(
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
  Future<List<TeamInvite>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TeamInviteTable> where,
    _is.OrderByBuilder<TeamInviteTable>? orderBy,
    _is.OrderByListBuilder<TeamInviteTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<TeamInvite>(
      where: where(TeamInvite.t),
      orderBy: orderBy?.call(TeamInvite.t),
      orderByList: orderByList?.call(TeamInvite.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TeamInviteTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<TeamInvite>(
      where: where?.call(TeamInvite.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [TeamInvite] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TeamInviteTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<TeamInvite>(
      where: where(TeamInvite.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class TeamInviteAttachRowRepository {
  const TeamInviteAttachRowRepository._();

  /// Creates a relation between the given [TeamInvite] and [Team]
  /// by setting the [TeamInvite]'s foreign key `teamId` to refer to the [Team].
  Future<void> team(
    _is.DatabaseSession session,
    TeamInvite teamInvite,
    _izqfkhlk.Team team, {
    _is.Transaction? transaction,
  }) async {
    if (teamInvite.id == null) {
      throw ArgumentError.notNull('teamInvite.id');
    }
    if (team.id == null) {
      throw ArgumentError.notNull('team.id');
    }

    var $teamInvite = teamInvite.copyWith(teamId: team.id);
    await session.db.updateRow<TeamInvite>(
      $teamInvite,
      columns: [TeamInvite.t.teamId],
      transaction: transaction,
    );
  }

  /// Creates a relation between the given [TeamInvite] and [AuthUser]
  /// by setting the [TeamInvite]'s foreign key `createdById` to refer to the [AuthUser].
  Future<void> createdBy(
    _is.DatabaseSession session,
    TeamInvite teamInvite,
    _iacs.AuthUser createdBy, {
    _is.Transaction? transaction,
  }) async {
    if (teamInvite.id == null) {
      throw ArgumentError.notNull('teamInvite.id');
    }
    if (createdBy.id == null) {
      throw ArgumentError.notNull('createdBy.id');
    }

    var $teamInvite = teamInvite.copyWith(createdById: createdBy.id);
    await session.db.updateRow<TeamInvite>(
      $teamInvite,
      columns: [TeamInvite.t.createdById],
      transaction: transaction,
    );
  }

  /// Creates a relation between the given [TeamInvite] and [AuthUser]
  /// by setting the [TeamInvite]'s foreign key `usedById` to refer to the [AuthUser].
  Future<void> usedBy(
    _is.DatabaseSession session,
    TeamInvite teamInvite,
    _iacs.AuthUser usedBy, {
    _is.Transaction? transaction,
  }) async {
    if (teamInvite.id == null) {
      throw ArgumentError.notNull('teamInvite.id');
    }
    if (usedBy.id == null) {
      throw ArgumentError.notNull('usedBy.id');
    }

    var $teamInvite = teamInvite.copyWith(usedById: usedBy.id);
    await session.db.updateRow<TeamInvite>(
      $teamInvite,
      columns: [TeamInvite.t.usedById],
      transaction: transaction,
    );
  }
}

class TeamInviteDetachRowRepository {
  const TeamInviteDetachRowRepository._();

  /// Detaches the relation between this [TeamInvite] and the [AuthUser] set in `usedBy`
  /// by setting the [TeamInvite]'s foreign key `usedById` to `null`.
  ///
  /// This removes the association between the two models without deleting
  /// the related record.
  Future<void> usedBy(
    _is.DatabaseSession session,
    TeamInvite teamInvite, {
    _is.Transaction? transaction,
  }) async {
    if (teamInvite.id == null) {
      throw ArgumentError.notNull('teamInvite.id');
    }

    var $teamInvite = teamInvite.copyWith(usedById: null);
    await session.db.updateRow<TeamInvite>(
      $teamInvite,
      columns: [TeamInvite.t.usedById],
      transaction: transaction,
    );
  }
}
