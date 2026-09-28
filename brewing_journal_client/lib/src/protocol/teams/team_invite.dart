/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:brewing_journal_client/src/protocol/protocol.dart' as _ibcyqwbp;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../teams/team.dart' as _izqfkhlk;
import '../teams/team_role.dart' as _iea06rdc;

abstract class TeamInvite
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
    _isc.UuidValue? id,
    required _isc.UuidValue teamId,
    _izqfkhlk.Team? team,
    required _isc.UuidValue createdById,
    _iacc.AuthUser? createdBy,
    required String token,
    required _iea06rdc.TeamRole role,
    required DateTime expiresAt,
    DateTime? usedAt,
    _isc.UuidValue? usedById,
    _iacc.AuthUser? usedBy,
    DateTime? createdAt,
  }) = _TeamInviteImpl;

  factory TeamInvite.fromJson(Map<String, dynamic> jsonSerialization) {
    return TeamInvite(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      teamId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['teamId']),
      team: jsonSerialization['team'] == null
          ? null
          : _ibcyqwbp.Protocol().deserialize<_izqfkhlk.Team>(
              jsonSerialization['team'],
            ),
      createdById: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['createdById'],
      ),
      createdBy: jsonSerialization['createdBy'] == null
          ? null
          : _ibcyqwbp.Protocol().deserialize<_iacc.AuthUser>(
              jsonSerialization['createdBy'],
            ),
      token: jsonSerialization['token'] as String,
      role: _iea06rdc.TeamRole.fromJson((jsonSerialization['role'] as String)),
      expiresAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      usedAt: jsonSerialization['usedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['usedAt']),
      usedById: jsonSerialization['usedById'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['usedById']),
      usedBy: jsonSerialization['usedBy'] == null
          ? null
          : _ibcyqwbp.Protocol().deserialize<_iacc.AuthUser>(
              jsonSerialization['usedBy'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue teamId;

  _izqfkhlk.Team? team;

  _isc.UuidValue createdById;

  _iacc.AuthUser? createdBy;

  String token;

  _iea06rdc.TeamRole role;

  DateTime expiresAt;

  DateTime? usedAt;

  _isc.UuidValue? usedById;

  _iacc.AuthUser? usedBy;

  DateTime createdAt;

  /// Returns a shallow copy of this [TeamInvite]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TeamInvite copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? teamId,
    _izqfkhlk.Team? team,
    _isc.UuidValue? createdById,
    _iacc.AuthUser? createdBy,
    String? token,
    _iea06rdc.TeamRole? role,
    DateTime? expiresAt,
    DateTime? usedAt,
    _isc.UuidValue? usedById,
    _iacc.AuthUser? usedBy,
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

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TeamInviteImpl extends TeamInvite {
  _TeamInviteImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue teamId,
    _izqfkhlk.Team? team,
    required _isc.UuidValue createdById,
    _iacc.AuthUser? createdBy,
    required String token,
    required _iea06rdc.TeamRole role,
    required DateTime expiresAt,
    DateTime? usedAt,
    _isc.UuidValue? usedById,
    _iacc.AuthUser? usedBy,
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
  @_isc.useResult
  @override
  TeamInvite copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? teamId,
    Object? team = _Undefined,
    _isc.UuidValue? createdById,
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
      id: id is _isc.UuidValue? ? id : this.id,
      teamId: teamId ?? this.teamId,
      team: team is _izqfkhlk.Team? ? team : this.team?.copyWith(),
      createdById: createdById ?? this.createdById,
      createdBy: createdBy is _iacc.AuthUser?
          ? createdBy
          : this.createdBy?.copyWith(),
      token: token ?? this.token,
      role: role ?? this.role,
      expiresAt: expiresAt ?? this.expiresAt,
      usedAt: usedAt is DateTime? ? usedAt : this.usedAt,
      usedById: usedById is _isc.UuidValue? ? usedById : this.usedById,
      usedBy: usedBy is _iacc.AuthUser? ? usedBy : this.usedBy?.copyWith(),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
