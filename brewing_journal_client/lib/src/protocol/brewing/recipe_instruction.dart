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
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../brewing/recipe.dart' as _iuy009ee;

abstract class RecipeInstruction
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  RecipeInstruction._({
    this.id,
    required this.recipeId,
    this.recipe,
    required this.sortOrder,
    required this.text,
  });

  factory RecipeInstruction({
    _isc.UuidValue? id,
    required _isc.UuidValue recipeId,
    _iuy009ee.Recipe? recipe,
    required int sortOrder,
    required String text,
  }) = _RecipeInstructionImpl;

  factory RecipeInstruction.fromJson(Map<String, dynamic> jsonSerialization) {
    return RecipeInstruction(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      recipeId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['recipeId'],
      ),
      recipe: jsonSerialization['recipe'] == null
          ? null
          : _ibcyqwbp.Protocol().deserialize<_iuy009ee.Recipe>(
              jsonSerialization['recipe'],
            ),
      sortOrder: jsonSerialization['sortOrder'] as int,
      text: jsonSerialization['text'] as String,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue recipeId;

  _iuy009ee.Recipe? recipe;

  int sortOrder;

  String text;

  /// Returns a shallow copy of this [RecipeInstruction]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  RecipeInstruction copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? recipeId,
    _iuy009ee.Recipe? recipe,
    int? sortOrder,
    String? text,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RecipeInstruction',
      if (id != null) 'id': id?.toJson(),
      'recipeId': recipeId.toJson(),
      if (recipe != null) 'recipe': recipe?.toJson(),
      'sortOrder': sortOrder,
      'text': text,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RecipeInstruction',
      if (id != null) 'id': id?.toJson(),
      'recipeId': recipeId.toJson(),
      if (recipe != null) 'recipe': recipe?.toJsonForProtocol(),
      'sortOrder': sortOrder,
      'text': text,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RecipeInstructionImpl extends RecipeInstruction {
  _RecipeInstructionImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue recipeId,
    _iuy009ee.Recipe? recipe,
    required int sortOrder,
    required String text,
  }) : super._(
         id: id,
         recipeId: recipeId,
         recipe: recipe,
         sortOrder: sortOrder,
         text: text,
       );

  /// Returns a shallow copy of this [RecipeInstruction]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  RecipeInstruction copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? recipeId,
    Object? recipe = _Undefined,
    int? sortOrder,
    String? text,
  }) {
    return RecipeInstruction(
      id: id is _isc.UuidValue? ? id : this.id,
      recipeId: recipeId ?? this.recipeId,
      recipe: recipe is _iuy009ee.Recipe? ? recipe : this.recipe?.copyWith(),
      sortOrder: sortOrder ?? this.sortOrder,
      text: text ?? this.text,
    );
  }
}
