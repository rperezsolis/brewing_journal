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

abstract class RecipePhoto
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  RecipePhoto._({
    this.id,
    required this.recipeId,
    this.recipe,
    required this.storagePath,
    required this.sortOrder,
    DateTime? createdAt,
    this.publicUrl,
  }) : createdAt = createdAt ?? DateTime.now();

  factory RecipePhoto({
    _isc.UuidValue? id,
    required _isc.UuidValue recipeId,
    _iuy009ee.Recipe? recipe,
    required String storagePath,
    required int sortOrder,
    DateTime? createdAt,
    Uri? publicUrl,
  }) = _RecipePhotoImpl;

  factory RecipePhoto.fromJson(Map<String, dynamic> jsonSerialization) {
    return RecipePhoto(
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
      storagePath: jsonSerialization['storagePath'] as String,
      sortOrder: jsonSerialization['sortOrder'] as int,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      publicUrl: jsonSerialization['publicUrl'] == null
          ? null
          : _isc.UriJsonExtension.fromJson(jsonSerialization['publicUrl']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue recipeId;

  _iuy009ee.Recipe? recipe;

  String storagePath;

  int sortOrder;

  DateTime createdAt;

  Uri? publicUrl;

  /// Returns a shallow copy of this [RecipePhoto]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  RecipePhoto copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? recipeId,
    _iuy009ee.Recipe? recipe,
    String? storagePath,
    int? sortOrder,
    DateTime? createdAt,
    Uri? publicUrl,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RecipePhoto',
      if (id != null) 'id': id?.toJson(),
      'recipeId': recipeId.toJson(),
      if (recipe != null) 'recipe': recipe?.toJson(),
      'storagePath': storagePath,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toJson(),
      if (publicUrl != null) 'publicUrl': publicUrl?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RecipePhoto',
      if (id != null) 'id': id?.toJson(),
      'recipeId': recipeId.toJson(),
      if (recipe != null) 'recipe': recipe?.toJsonForProtocol(),
      'storagePath': storagePath,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toJson(),
      if (publicUrl != null) 'publicUrl': publicUrl?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RecipePhotoImpl extends RecipePhoto {
  _RecipePhotoImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue recipeId,
    _iuy009ee.Recipe? recipe,
    required String storagePath,
    required int sortOrder,
    DateTime? createdAt,
    Uri? publicUrl,
  }) : super._(
         id: id,
         recipeId: recipeId,
         recipe: recipe,
         storagePath: storagePath,
         sortOrder: sortOrder,
         createdAt: createdAt,
         publicUrl: publicUrl,
       );

  /// Returns a shallow copy of this [RecipePhoto]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  RecipePhoto copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? recipeId,
    Object? recipe = _Undefined,
    String? storagePath,
    int? sortOrder,
    DateTime? createdAt,
    Object? publicUrl = _Undefined,
  }) {
    return RecipePhoto(
      id: id is _isc.UuidValue? ? id : this.id,
      recipeId: recipeId ?? this.recipeId,
      recipe: recipe is _iuy009ee.Recipe? ? recipe : this.recipe?.copyWith(),
      storagePath: storagePath ?? this.storagePath,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      publicUrl: publicUrl is Uri? ? publicUrl : this.publicUrl,
    );
  }
}
