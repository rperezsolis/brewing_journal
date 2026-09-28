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

abstract class TeamMembership
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
    _isc.UuidValue? id,
    required _isc.UuidValue teamId,
    _izqfkhlk.Team? team,
    required _isc.UuidValue memberId,
    _iacc.AuthUser? member,
    required _iea06rdc.TeamRole role,
    DateTime? createdAt,
  }) = _TeamMembershipImpl;

  factory TeamMembership.fromJson(Map<String, dynamic> jsonSerialization) {
    return TeamMembership(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      teamId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['teamId']),
      team: jsonSerialization['team'] == null
          ? null
          : _ibcyqwbp.Protocol().deserialize<_izqfkhlk.Team>(
              jsonSerialization['team'],
            ),
      memberId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['memberId'],
      ),
      member: jsonSerialization['member'] == null
          ? null
          : _ibcyqwbp.Protocol().deserialize<_iacc.AuthUser>(
              jsonSerialization['member'],
            ),
      role: _iea06rdc.TeamRole.fromJson((jsonSerialization['role'] as String)),
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

  _isc.UuidValue memberId;

  _iacc.AuthUser? member;

  _iea06rdc.TeamRole role;

  DateTime createdAt;

  /// Returns a shallow copy of this [TeamMembership]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TeamMembership copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? teamId,
    _izqfkhlk.Team? team,
    _isc.UuidValue? memberId,
    _iacc.AuthUser? member,
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

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TeamMembershipImpl extends TeamMembership {
  _TeamMembershipImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue teamId,
    _izqfkhlk.Team? team,
    required _isc.UuidValue memberId,
    _iacc.AuthUser? member,
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
  @_isc.useResult
  @override
  TeamMembership copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? teamId,
    Object? team = _Undefined,
    _isc.UuidValue? memberId,
    Object? member = _Undefined,
    _iea06rdc.TeamRole? role,
    DateTime? createdAt,
  }) {
    return TeamMembership(
      id: id is _isc.UuidValue? ? id : this.id,
      teamId: teamId ?? this.teamId,
      team: team is _izqfkhlk.Team? ? team : this.team?.copyWith(),
      memberId: memberId ?? this.memberId,
      member: member is _iacc.AuthUser? ? member : this.member?.copyWith(),
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
