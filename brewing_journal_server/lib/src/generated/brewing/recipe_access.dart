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

abstract class RecipeAccess
    implements _is.SerializableModel, _is.ProtocolSerialization {
  RecipeAccess._({
    this.role,
    required this.canEdit,
    required this.canDelete,
  });

  factory RecipeAccess({
    _iea06rdc.TeamRole? role,
    required bool canEdit,
    required bool canDelete,
  }) = _RecipeAccessImpl;

  factory RecipeAccess.fromJson(Map<String, dynamic> jsonSerialization) {
    return RecipeAccess(
      role: jsonSerialization['role'] == null
          ? null
          : _iea06rdc.TeamRole.fromJson((jsonSerialization['role'] as String)),
      canEdit: _is.BoolJsonExtension.fromJson(jsonSerialization['canEdit']),
      canDelete: _is.BoolJsonExtension.fromJson(jsonSerialization['canDelete']),
    );
  }

  _iea06rdc.TeamRole? role;

  bool canEdit;

  bool canDelete;

  /// Returns a shallow copy of this [RecipeAccess]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RecipeAccess copyWith({
    _iea06rdc.TeamRole? role,
    bool? canEdit,
    bool? canDelete,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RecipeAccess',
      if (role != null) 'role': role?.toJson(),
      'canEdit': canEdit,
      'canDelete': canDelete,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RecipeAccess',
      if (role != null) 'role': role?.toJson(),
      'canEdit': canEdit,
      'canDelete': canDelete,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RecipeAccessImpl extends RecipeAccess {
  _RecipeAccessImpl({
    _iea06rdc.TeamRole? role,
    required bool canEdit,
    required bool canDelete,
  }) : super._(
         role: role,
         canEdit: canEdit,
         canDelete: canDelete,
       );

  /// Returns a shallow copy of this [RecipeAccess]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RecipeAccess copyWith({
    Object? role = _Undefined,
    bool? canEdit,
    bool? canDelete,
  }) {
    return RecipeAccess(
      role: role is _iea06rdc.TeamRole? ? role : this.role,
      canEdit: canEdit ?? this.canEdit,
      canDelete: canDelete ?? this.canDelete,
    );
  }
}
