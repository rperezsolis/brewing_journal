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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

abstract class RecipeAccess
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  RecipeAccess._({
    required this.canEdit,
    required this.canDelete,
  });

  factory RecipeAccess({
    required bool canEdit,
    required bool canDelete,
  }) = _RecipeAccessImpl;

  factory RecipeAccess.fromJson(Map<String, dynamic> jsonSerialization) {
    return RecipeAccess(
      canEdit: _isc.BoolJsonExtension.fromJson(jsonSerialization['canEdit']),
      canDelete: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['canDelete'],
      ),
    );
  }

  bool canEdit;

  bool canDelete;

  /// Returns a shallow copy of this [RecipeAccess]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  RecipeAccess copyWith({
    bool? canEdit,
    bool? canDelete,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RecipeAccess',
      'canEdit': canEdit,
      'canDelete': canDelete,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RecipeAccess',
      'canEdit': canEdit,
      'canDelete': canDelete,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _RecipeAccessImpl extends RecipeAccess {
  _RecipeAccessImpl({
    required bool canEdit,
    required bool canDelete,
  }) : super._(
         canEdit: canEdit,
         canDelete: canDelete,
       );

  /// Returns a shallow copy of this [RecipeAccess]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  RecipeAccess copyWith({
    bool? canEdit,
    bool? canDelete,
  }) {
    return RecipeAccess(
      canEdit: canEdit ?? this.canEdit,
      canDelete: canDelete ?? this.canDelete,
    );
  }
}
