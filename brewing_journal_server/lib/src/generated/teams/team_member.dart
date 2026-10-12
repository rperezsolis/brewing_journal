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
import 'package:serverpod/serverpod.dart' as _is;
import '../teams/team_role.dart' as _iea06rdc;

abstract class TeamMember
    implements _is.SerializableModel, _is.ProtocolSerialization {
  TeamMember._({
    required this.membershipId,
    required this.userId,
    required this.preferredName,
    required this.email,
    required this.role,
  });

  factory TeamMember({
    required _is.UuidValue membershipId,
    required _is.UuidValue userId,
    required String preferredName,
    required String email,
    required _iea06rdc.TeamRole role,
  }) = _TeamMemberImpl;

  factory TeamMember.fromJson(Map<String, dynamic> jsonSerialization) {
    return TeamMember(
      membershipId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['membershipId'],
      ),
      userId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      preferredName: jsonSerialization['preferredName'] as String,
      email: jsonSerialization['email'] as String,
      role: _iea06rdc.TeamRole.fromJson((jsonSerialization['role'] as String)),
    );
  }

  _is.UuidValue membershipId;

  _is.UuidValue userId;

  String preferredName;

  String email;

  _iea06rdc.TeamRole role;

  /// Returns a shallow copy of this [TeamMember]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TeamMember copyWith({
    _is.UuidValue? membershipId,
    _is.UuidValue? userId,
    String? preferredName,
    String? email,
    _iea06rdc.TeamRole? role,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TeamMember',
      'membershipId': membershipId.toJson(),
      'userId': userId.toJson(),
      'preferredName': preferredName,
      'email': email,
      'role': role.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TeamMember',
      'membershipId': membershipId.toJson(),
      'userId': userId.toJson(),
      'preferredName': preferredName,
      'email': email,
      'role': role.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _TeamMemberImpl extends TeamMember {
  _TeamMemberImpl({
    required _is.UuidValue membershipId,
    required _is.UuidValue userId,
    required String preferredName,
    required String email,
    required _iea06rdc.TeamRole role,
  }) : super._(
         membershipId: membershipId,
         userId: userId,
         preferredName: preferredName,
         email: email,
         role: role,
       );

  /// Returns a shallow copy of this [TeamMember]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TeamMember copyWith({
    _is.UuidValue? membershipId,
    _is.UuidValue? userId,
    String? preferredName,
    String? email,
    _iea06rdc.TeamRole? role,
  }) {
    return TeamMember(
      membershipId: membershipId ?? this.membershipId,
      userId: userId ?? this.userId,
      preferredName: preferredName ?? this.preferredName,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }
}
