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

abstract class InviteLink
    implements _is.SerializableModel, _is.ProtocolSerialization {
  InviteLink._({
    required this.token,
    required this.role,
    required this.expiresAt,
    required this.url,
  });

  factory InviteLink({
    required String token,
    required _iea06rdc.TeamRole role,
    required DateTime expiresAt,
    required String url,
  }) = _InviteLinkImpl;

  factory InviteLink.fromJson(Map<String, dynamic> jsonSerialization) {
    return InviteLink(
      token: jsonSerialization['token'] as String,
      role: _iea06rdc.TeamRole.fromJson((jsonSerialization['role'] as String)),
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      url: jsonSerialization['url'] as String,
    );
  }

  String token;

  _iea06rdc.TeamRole role;

  DateTime expiresAt;

  String url;

  /// Returns a shallow copy of this [InviteLink]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  InviteLink copyWith({
    String? token,
    _iea06rdc.TeamRole? role,
    DateTime? expiresAt,
    String? url,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'InviteLink',
      'token': token,
      'role': role.toJson(),
      'expiresAt': expiresAt.toJson(),
      'url': url,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'InviteLink',
      'token': token,
      'role': role.toJson(),
      'expiresAt': expiresAt.toJson(),
      'url': url,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _InviteLinkImpl extends InviteLink {
  _InviteLinkImpl({
    required String token,
    required _iea06rdc.TeamRole role,
    required DateTime expiresAt,
    required String url,
  }) : super._(
         token: token,
         role: role,
         expiresAt: expiresAt,
         url: url,
       );

  /// Returns a shallow copy of this [InviteLink]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  InviteLink copyWith({
    String? token,
    _iea06rdc.TeamRole? role,
    DateTime? expiresAt,
    String? url,
  }) {
    return InviteLink(
      token: token ?? this.token,
      role: role ?? this.role,
      expiresAt: expiresAt ?? this.expiresAt,
      url: url ?? this.url,
    );
  }
}
