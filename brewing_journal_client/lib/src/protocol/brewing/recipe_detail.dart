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
import '../brewing/ingredient.dart' as _ippg9os6;
import '../brewing/recipe.dart' as _iuy009ee;
import '../brewing/recipe_access.dart' as _ih2o0uqp;
import '../brewing/recipe_flavor_tag.dart' as _i55exiaf;
import '../brewing/recipe_instruction.dart' as _i1t6etiy;
import '../brewing/recipe_photo.dart' as _iir54vf2;

abstract class RecipeDetail
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  RecipeDetail._({
    required this.recipe,
    required this.ingredient,
    required this.instructions,
    required this.flavorTags,
    required this.photos,
    required this.access,
  });

  factory RecipeDetail({
    required _iuy009ee.Recipe recipe,
    required _ippg9os6.Ingredient ingredient,
    required List<_i1t6etiy.RecipeInstruction> instructions,
    required List<_i55exiaf.RecipeFlavorTag> flavorTags,
    required List<_iir54vf2.RecipePhoto> photos,
    required _ih2o0uqp.RecipeAccess access,
  }) = _RecipeDetailImpl;

  factory RecipeDetail.fromJson(Map<String, dynamic> jsonSerialization) {
    return RecipeDetail(
      recipe: _ibcyqwbp.Protocol().deserialize<_iuy009ee.Recipe>(
        jsonSerialization['recipe'],
      ),
      ingredient: _ibcyqwbp.Protocol().deserialize<_ippg9os6.Ingredient>(
        jsonSerialization['ingredient'],
      ),
      instructions: _ibcyqwbp.Protocol()
          .deserialize<List<_i1t6etiy.RecipeInstruction>>(
            jsonSerialization['instructions'],
          ),
      flavorTags: _ibcyqwbp.Protocol()
          .deserialize<List<_i55exiaf.RecipeFlavorTag>>(
            jsonSerialization['flavorTags'],
          ),
      photos: _ibcyqwbp.Protocol().deserialize<List<_iir54vf2.RecipePhoto>>(
        jsonSerialization['photos'],
      ),
      access: _ibcyqwbp.Protocol().deserialize<_ih2o0uqp.RecipeAccess>(
        jsonSerialization['access'],
      ),
    );
  }

  _iuy009ee.Recipe recipe;

  _ippg9os6.Ingredient ingredient;

  List<_i1t6etiy.RecipeInstruction> instructions;

  List<_i55exiaf.RecipeFlavorTag> flavorTags;

  List<_iir54vf2.RecipePhoto> photos;

  _ih2o0uqp.RecipeAccess access;

  /// Returns a shallow copy of this [RecipeDetail]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  RecipeDetail copyWith({
    _iuy009ee.Recipe? recipe,
    _ippg9os6.Ingredient? ingredient,
    List<_i1t6etiy.RecipeInstruction>? instructions,
    List<_i55exiaf.RecipeFlavorTag>? flavorTags,
    List<_iir54vf2.RecipePhoto>? photos,
    _ih2o0uqp.RecipeAccess? access,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RecipeDetail',
      'recipe': recipe.toJson(),
      'ingredient': ingredient.toJson(),
      'instructions': instructions.toJson(valueToJson: (v) => v.toJson()),
      'flavorTags': flavorTags.toJson(valueToJson: (v) => v.toJson()),
      'photos': photos.toJson(valueToJson: (v) => v.toJson()),
      'access': access.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RecipeDetail',
      'recipe': recipe.toJsonForProtocol(),
      'ingredient': ingredient.toJsonForProtocol(),
      'instructions': instructions.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'flavorTags': flavorTags.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'photos': photos.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'access': access.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _RecipeDetailImpl extends RecipeDetail {
  _RecipeDetailImpl({
    required _iuy009ee.Recipe recipe,
    required _ippg9os6.Ingredient ingredient,
    required List<_i1t6etiy.RecipeInstruction> instructions,
    required List<_i55exiaf.RecipeFlavorTag> flavorTags,
    required List<_iir54vf2.RecipePhoto> photos,
    required _ih2o0uqp.RecipeAccess access,
  }) : super._(
         recipe: recipe,
         ingredient: ingredient,
         instructions: instructions,
         flavorTags: flavorTags,
         photos: photos,
         access: access,
       );

  /// Returns a shallow copy of this [RecipeDetail]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  RecipeDetail copyWith({
    _iuy009ee.Recipe? recipe,
    _ippg9os6.Ingredient? ingredient,
    List<_i1t6etiy.RecipeInstruction>? instructions,
    List<_i55exiaf.RecipeFlavorTag>? flavorTags,
    List<_iir54vf2.RecipePhoto>? photos,
    _ih2o0uqp.RecipeAccess? access,
  }) {
    return RecipeDetail(
      recipe: recipe ?? this.recipe.copyWith(),
      ingredient: ingredient ?? this.ingredient.copyWith(),
      instructions:
          instructions ?? this.instructions.map((e0) => e0.copyWith()).toList(),
      flavorTags:
          flavorTags ?? this.flavorTags.map((e0) => e0.copyWith()).toList(),
      photos: photos ?? this.photos.map((e0) => e0.copyWith()).toList(),
      access: access ?? this.access.copyWith(),
    );
  }
}
