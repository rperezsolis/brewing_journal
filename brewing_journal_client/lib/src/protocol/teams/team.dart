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
import '../brewing/recipe.dart' as _iuy009ee;
import '../teams/team_invite.dart' as _i710pi98;
import '../teams/team_membership.dart' as _iromunn4;

abstract class Team
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
    _isc.UuidValue? id,
    required _isc.UuidValue ownerId,
    _iacc.AuthUser? owner,
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
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      ownerId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['ownerId'],
      ),
      owner: jsonSerialization['owner'] == null
          ? null
          : _ibcyqwbp.Protocol().deserialize<_iacc.AuthUser>(
              jsonSerialization['owner'],
            ),
      name: jsonSerialization['name'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      memberships: jsonSerialization['memberships'] == null
          ? null
          : _ibcyqwbp.Protocol().deserialize<List<_iromunn4.TeamMembership>>(
              jsonSerialization['memberships'],
            ),
      invites: jsonSerialization['invites'] == null
          ? null
          : _ibcyqwbp.Protocol().deserialize<List<_i710pi98.TeamInvite>>(
              jsonSerialization['invites'],
            ),
      recipes: jsonSerialization['recipes'] == null
          ? null
          : _ibcyqwbp.Protocol().deserialize<List<_iuy009ee.Recipe>>(
              jsonSerialization['recipes'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue ownerId;

  _iacc.AuthUser? owner;

  String name;

  DateTime createdAt;

  List<_iromunn4.TeamMembership>? memberships;

  List<_i710pi98.TeamInvite>? invites;

  List<_iuy009ee.Recipe>? recipes;

  /// Returns a shallow copy of this [Team]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Team copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? ownerId,
    _iacc.AuthUser? owner,
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

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TeamImpl extends Team {
  _TeamImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue ownerId,
    _iacc.AuthUser? owner,
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
  @_isc.useResult
  @override
  Team copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? ownerId,
    Object? owner = _Undefined,
    String? name,
    DateTime? createdAt,
    Object? memberships = _Undefined,
    Object? invites = _Undefined,
    Object? recipes = _Undefined,
  }) {
    return Team(
      id: id is _isc.UuidValue? ? id : this.id,
      ownerId: ownerId ?? this.ownerId,
      owner: owner is _iacc.AuthUser? ? owner : this.owner?.copyWith(),
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
