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
import '../brewing/extraction_method.dart' as _io8keuuf;
import '../brewing/ingredient.dart' as _ippg9os6;
import '../brewing/recipe_flavor_tag.dart' as _i55exiaf;
import '../brewing/recipe_instruction.dart' as _i1t6etiy;
import '../brewing/recipe_photo.dart' as _iir54vf2;
import '../teams/team.dart' as _izqfkhlk;

abstract class Recipe
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Recipe._({
    this.id,
    required this.ownerId,
    this.owner,
    this.teamId,
    this.team,
    required this.ingredientId,
    this.ingredient,
    required this.title,
    required this.waterTempC,
    required this.doseGrams,
    required this.grindSize,
    required this.grinderModel,
    required this.extractionMethod,
    this.extractionMethodNote,
    this.extractionDuration,
    required this.acidity,
    required this.sweetness,
    required this.body,
    required this.bitterness,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.instructions,
    this.photos,
    this.flavorTags,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Recipe({
    _isc.UuidValue? id,
    required _isc.UuidValue ownerId,
    _iacc.AuthUser? owner,
    _isc.UuidValue? teamId,
    _izqfkhlk.Team? team,
    required _isc.UuidValue ingredientId,
    _ippg9os6.Ingredient? ingredient,
    required String title,
    required double waterTempC,
    required double doseGrams,
    required String grindSize,
    required String grinderModel,
    required _io8keuuf.ExtractionMethod extractionMethod,
    String? extractionMethodNote,
    Duration? extractionDuration,
    required int acidity,
    required int sweetness,
    required int body,
    required int bitterness,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<_i1t6etiy.RecipeInstruction>? instructions,
    List<_iir54vf2.RecipePhoto>? photos,
    List<_i55exiaf.RecipeFlavorTag>? flavorTags,
  }) = _RecipeImpl;

  factory Recipe.fromJson(Map<String, dynamic> jsonSerialization) {
    return Recipe(
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
      teamId: jsonSerialization['teamId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['teamId']),
      team: jsonSerialization['team'] == null
          ? null
          : _ibcyqwbp.Protocol().deserialize<_izqfkhlk.Team>(
              jsonSerialization['team'],
            ),
      ingredientId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['ingredientId'],
      ),
      ingredient: jsonSerialization['ingredient'] == null
          ? null
          : _ibcyqwbp.Protocol().deserialize<_ippg9os6.Ingredient>(
              jsonSerialization['ingredient'],
            ),
      title: jsonSerialization['title'] as String,
      waterTempC: (jsonSerialization['waterTempC'] as num).toDouble(),
      doseGrams: (jsonSerialization['doseGrams'] as num).toDouble(),
      grindSize: jsonSerialization['grindSize'] as String,
      grinderModel: jsonSerialization['grinderModel'] as String,
      extractionMethod: _io8keuuf.ExtractionMethod.fromJson(
        (jsonSerialization['extractionMethod'] as String),
      ),
      extractionMethodNote:
          jsonSerialization['extractionMethodNote'] as String?,
      extractionDuration: jsonSerialization['extractionDuration'] == null
          ? null
          : _isc.DurationJsonExtension.fromJson(
              jsonSerialization['extractionDuration'],
            ),
      acidity: jsonSerialization['acidity'] as int,
      sweetness: jsonSerialization['sweetness'] as int,
      body: jsonSerialization['body'] as int,
      bitterness: jsonSerialization['bitterness'] as int,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      instructions: jsonSerialization['instructions'] == null
          ? null
          : _ibcyqwbp.Protocol().deserialize<List<_i1t6etiy.RecipeInstruction>>(
              jsonSerialization['instructions'],
            ),
      photos: jsonSerialization['photos'] == null
          ? null
          : _ibcyqwbp.Protocol().deserialize<List<_iir54vf2.RecipePhoto>>(
              jsonSerialization['photos'],
            ),
      flavorTags: jsonSerialization['flavorTags'] == null
          ? null
          : _ibcyqwbp.Protocol().deserialize<List<_i55exiaf.RecipeFlavorTag>>(
              jsonSerialization['flavorTags'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue ownerId;

  _iacc.AuthUser? owner;

  _isc.UuidValue? teamId;

  _izqfkhlk.Team? team;

  _isc.UuidValue ingredientId;

  _ippg9os6.Ingredient? ingredient;

  String title;

  double waterTempC;

  double doseGrams;

  String grindSize;

  String grinderModel;

  _io8keuuf.ExtractionMethod extractionMethod;

  String? extractionMethodNote;

  Duration? extractionDuration;

  int acidity;

  int sweetness;

  int body;

  int bitterness;

  DateTime createdAt;

  DateTime updatedAt;

  List<_i1t6etiy.RecipeInstruction>? instructions;

  List<_iir54vf2.RecipePhoto>? photos;

  List<_i55exiaf.RecipeFlavorTag>? flavorTags;

  /// Returns a shallow copy of this [Recipe]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Recipe copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? ownerId,
    _iacc.AuthUser? owner,
    _isc.UuidValue? teamId,
    _izqfkhlk.Team? team,
    _isc.UuidValue? ingredientId,
    _ippg9os6.Ingredient? ingredient,
    String? title,
    double? waterTempC,
    double? doseGrams,
    String? grindSize,
    String? grinderModel,
    _io8keuuf.ExtractionMethod? extractionMethod,
    String? extractionMethodNote,
    Duration? extractionDuration,
    int? acidity,
    int? sweetness,
    int? body,
    int? bitterness,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<_i1t6etiy.RecipeInstruction>? instructions,
    List<_iir54vf2.RecipePhoto>? photos,
    List<_i55exiaf.RecipeFlavorTag>? flavorTags,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Recipe',
      if (id != null) 'id': id?.toJson(),
      'ownerId': ownerId.toJson(),
      if (owner != null) 'owner': owner?.toJson(),
      if (teamId != null) 'teamId': teamId?.toJson(),
      if (team != null) 'team': team?.toJson(),
      'ingredientId': ingredientId.toJson(),
      if (ingredient != null) 'ingredient': ingredient?.toJson(),
      'title': title,
      'waterTempC': waterTempC,
      'doseGrams': doseGrams,
      'grindSize': grindSize,
      'grinderModel': grinderModel,
      'extractionMethod': extractionMethod.toJson(),
      if (extractionMethodNote != null)
        'extractionMethodNote': extractionMethodNote,
      if (extractionDuration != null)
        'extractionDuration': extractionDuration?.toJson(),
      'acidity': acidity,
      'sweetness': sweetness,
      'body': body,
      'bitterness': bitterness,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (instructions != null)
        'instructions': instructions?.toJson(valueToJson: (v) => v.toJson()),
      if (photos != null)
        'photos': photos?.toJson(valueToJson: (v) => v.toJson()),
      if (flavorTags != null)
        'flavorTags': flavorTags?.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Recipe',
      if (id != null) 'id': id?.toJson(),
      'ownerId': ownerId.toJson(),
      if (owner != null) 'owner': owner?.toJson(),
      if (teamId != null) 'teamId': teamId?.toJson(),
      if (team != null) 'team': team?.toJsonForProtocol(),
      'ingredientId': ingredientId.toJson(),
      if (ingredient != null) 'ingredient': ingredient?.toJsonForProtocol(),
      'title': title,
      'waterTempC': waterTempC,
      'doseGrams': doseGrams,
      'grindSize': grindSize,
      'grinderModel': grinderModel,
      'extractionMethod': extractionMethod.toJson(),
      if (extractionMethodNote != null)
        'extractionMethodNote': extractionMethodNote,
      if (extractionDuration != null)
        'extractionDuration': extractionDuration?.toJson(),
      'acidity': acidity,
      'sweetness': sweetness,
      'body': body,
      'bitterness': bitterness,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (instructions != null)
        'instructions': instructions?.toJson(
          valueToJson: (v) => v.toJsonForProtocol(),
        ),
      if (photos != null)
        'photos': photos?.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (flavorTags != null)
        'flavorTags': flavorTags?.toJson(
          valueToJson: (v) => v.toJsonForProtocol(),
        ),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RecipeImpl extends Recipe {
  _RecipeImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue ownerId,
    _iacc.AuthUser? owner,
    _isc.UuidValue? teamId,
    _izqfkhlk.Team? team,
    required _isc.UuidValue ingredientId,
    _ippg9os6.Ingredient? ingredient,
    required String title,
    required double waterTempC,
    required double doseGrams,
    required String grindSize,
    required String grinderModel,
    required _io8keuuf.ExtractionMethod extractionMethod,
    String? extractionMethodNote,
    Duration? extractionDuration,
    required int acidity,
    required int sweetness,
    required int body,
    required int bitterness,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<_i1t6etiy.RecipeInstruction>? instructions,
    List<_iir54vf2.RecipePhoto>? photos,
    List<_i55exiaf.RecipeFlavorTag>? flavorTags,
  }) : super._(
         id: id,
         ownerId: ownerId,
         owner: owner,
         teamId: teamId,
         team: team,
         ingredientId: ingredientId,
         ingredient: ingredient,
         title: title,
         waterTempC: waterTempC,
         doseGrams: doseGrams,
         grindSize: grindSize,
         grinderModel: grinderModel,
         extractionMethod: extractionMethod,
         extractionMethodNote: extractionMethodNote,
         extractionDuration: extractionDuration,
         acidity: acidity,
         sweetness: sweetness,
         body: body,
         bitterness: bitterness,
         createdAt: createdAt,
         updatedAt: updatedAt,
         instructions: instructions,
         photos: photos,
         flavorTags: flavorTags,
       );

  /// Returns a shallow copy of this [Recipe]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Recipe copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? ownerId,
    Object? owner = _Undefined,
    Object? teamId = _Undefined,
    Object? team = _Undefined,
    _isc.UuidValue? ingredientId,
    Object? ingredient = _Undefined,
    String? title,
    double? waterTempC,
    double? doseGrams,
    String? grindSize,
    String? grinderModel,
    _io8keuuf.ExtractionMethod? extractionMethod,
    Object? extractionMethodNote = _Undefined,
    Object? extractionDuration = _Undefined,
    int? acidity,
    int? sweetness,
    int? body,
    int? bitterness,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? instructions = _Undefined,
    Object? photos = _Undefined,
    Object? flavorTags = _Undefined,
  }) {
    return Recipe(
      id: id is _isc.UuidValue? ? id : this.id,
      ownerId: ownerId ?? this.ownerId,
      owner: owner is _iacc.AuthUser? ? owner : this.owner?.copyWith(),
      teamId: teamId is _isc.UuidValue? ? teamId : this.teamId,
      team: team is _izqfkhlk.Team? ? team : this.team?.copyWith(),
      ingredientId: ingredientId ?? this.ingredientId,
      ingredient: ingredient is _ippg9os6.Ingredient?
          ? ingredient
          : this.ingredient?.copyWith(),
      title: title ?? this.title,
      waterTempC: waterTempC ?? this.waterTempC,
      doseGrams: doseGrams ?? this.doseGrams,
      grindSize: grindSize ?? this.grindSize,
      grinderModel: grinderModel ?? this.grinderModel,
      extractionMethod: extractionMethod ?? this.extractionMethod,
      extractionMethodNote: extractionMethodNote is String?
          ? extractionMethodNote
          : this.extractionMethodNote,
      extractionDuration: extractionDuration is Duration?
          ? extractionDuration
          : this.extractionDuration,
      acidity: acidity ?? this.acidity,
      sweetness: sweetness ?? this.sweetness,
      body: body ?? this.body,
      bitterness: bitterness ?? this.bitterness,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      instructions: instructions is List<_i1t6etiy.RecipeInstruction>?
          ? instructions
          : this.instructions?.map((e0) => e0.copyWith()).toList(),
      photos: photos is List<_iir54vf2.RecipePhoto>?
          ? photos
          : this.photos?.map((e0) => e0.copyWith()).toList(),
      flavorTags: flavorTags is List<_i55exiaf.RecipeFlavorTag>?
          ? flavorTags
          : this.flavorTags?.map((e0) => e0.copyWith()).toList(),
    );
  }
}
