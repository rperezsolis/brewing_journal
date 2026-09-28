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
import 'package:brewing_journal_server/src/generated/protocol.dart'
    as _i8dlmk64;
import 'package:serverpod/serverpod.dart' as _is;
import '../teams/team.dart' as _izqfkhlk;
import '../teams/team_role.dart' as _iea06rdc;

abstract class TeamSummary
    implements _is.SerializableModel, _is.ProtocolSerialization {
  TeamSummary._({
    required this.team,
    required this.role,
  });

  factory TeamSummary({
    required _izqfkhlk.Team team,
    required _iea06rdc.TeamRole role,
  }) = _TeamSummaryImpl;

  factory TeamSummary.fromJson(Map<String, dynamic> jsonSerialization) {
    return TeamSummary(
      team: _i8dlmk64.Protocol().deserialize<_izqfkhlk.Team>(
        jsonSerialization['team'],
      ),
      role: _iea06rdc.TeamRole.fromJson((jsonSerialization['role'] as String)),
    );
  }

  _izqfkhlk.Team team;

  _iea06rdc.TeamRole role;

  /// Returns a shallow copy of this [TeamSummary]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TeamSummary copyWith({
    _izqfkhlk.Team? team,
    _iea06rdc.TeamRole? role,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TeamSummary',
      'team': team.toJson(),
      'role': role.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TeamSummary',
      'team': team.toJsonForProtocol(),
      'role': role.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _TeamSummaryImpl extends TeamSummary {
  _TeamSummaryImpl({
    required _izqfkhlk.Team team,
    required _iea06rdc.TeamRole role,
  }) : super._(
         team: team,
         role: role,
       );

  /// Returns a shallow copy of this [TeamSummary]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TeamSummary copyWith({
    _izqfkhlk.Team? team,
    _iea06rdc.TeamRole? role,
  }) {
    return TeamSummary(
      team: team ?? this.team.copyWith(),
      role: role ?? this.role,
    );
  }
}
