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

abstract class FavoriteSaveResult
    implements _is.SerializableModel, _is.ProtocolSerialization {
  FavoriteSaveResult._({
    required this.saved,
    this.replacedRecipeId,
  });

  factory FavoriteSaveResult({
    required bool saved,
    _is.UuidValue? replacedRecipeId,
  }) = _FavoriteSaveResultImpl;

  factory FavoriteSaveResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return FavoriteSaveResult(
      saved: _is.BoolJsonExtension.fromJson(jsonSerialization['saved']),
      replacedRecipeId: jsonSerialization['replacedRecipeId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['replacedRecipeId'],
            ),
    );
  }

  /// True when the recipe is now the caller's favorite for that title.
  bool saved;

  /// The favorite this save replaced, when [saved] is true and one was removed.
  _is.UuidValue? replacedRecipeId;

  /// Returns a shallow copy of this [FavoriteSaveResult]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  FavoriteSaveResult copyWith({
    bool? saved,
    _is.UuidValue? replacedRecipeId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FavoriteSaveResult',
      'saved': saved,
      if (replacedRecipeId != null)
        'replacedRecipeId': replacedRecipeId?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FavoriteSaveResult',
      'saved': saved,
      if (replacedRecipeId != null)
        'replacedRecipeId': replacedRecipeId?.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FavoriteSaveResultImpl extends FavoriteSaveResult {
  _FavoriteSaveResultImpl({
    required bool saved,
    _is.UuidValue? replacedRecipeId,
  }) : super._(
         saved: saved,
         replacedRecipeId: replacedRecipeId,
       );

  /// Returns a shallow copy of this [FavoriteSaveResult]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  FavoriteSaveResult copyWith({
    bool? saved,
    Object? replacedRecipeId = _Undefined,
  }) {
    return FavoriteSaveResult(
      saved: saved ?? this.saved,
      replacedRecipeId: replacedRecipeId is _is.UuidValue?
          ? replacedRecipeId
          : this.replacedRecipeId,
    );
  }
}
