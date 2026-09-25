/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_null_comparison

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:brewing_journal_server/src/generated/protocol.dart'
    as _i8dlmk64;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import '../brewing/extraction_method.dart' as _io8keuuf;
import '../brewing/ingredient.dart' as _ippg9os6;
import '../brewing/recipe_flavor_tag.dart' as _i55exiaf;
import '../brewing/recipe_instruction.dart' as _i1t6etiy;
import '../brewing/recipe_photo.dart' as _iir54vf2;

abstract class Recipe
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  Recipe._({
    this.id,
    required this.ownerId,
    this.owner,
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
    _is.UuidValue? id,
    required _is.UuidValue ownerId,
    _iacs.AuthUser? owner,
    required _is.UuidValue ingredientId,
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
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      ownerId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['ownerId'],
      ),
      owner: jsonSerialization['owner'] == null
          ? null
          : _i8dlmk64.Protocol().deserialize<_iacs.AuthUser>(
              jsonSerialization['owner'],
            ),
      ingredientId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['ingredientId'],
      ),
      ingredient: jsonSerialization['ingredient'] == null
          ? null
          : _i8dlmk64.Protocol().deserialize<_ippg9os6.Ingredient>(
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
          : _is.DurationJsonExtension.fromJson(
              jsonSerialization['extractionDuration'],
            ),
      acidity: jsonSerialization['acidity'] as int,
      sweetness: jsonSerialization['sweetness'] as int,
      body: jsonSerialization['body'] as int,
      bitterness: jsonSerialization['bitterness'] as int,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      instructions: jsonSerialization['instructions'] == null
          ? null
          : _i8dlmk64.Protocol().deserialize<List<_i1t6etiy.RecipeInstruction>>(
              jsonSerialization['instructions'],
            ),
      photos: jsonSerialization['photos'] == null
          ? null
          : _i8dlmk64.Protocol().deserialize<List<_iir54vf2.RecipePhoto>>(
              jsonSerialization['photos'],
            ),
      flavorTags: jsonSerialization['flavorTags'] == null
          ? null
          : _i8dlmk64.Protocol().deserialize<List<_i55exiaf.RecipeFlavorTag>>(
              jsonSerialization['flavorTags'],
            ),
    );
  }

  static final t = RecipeTable();

  static const db = RecipeRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue ownerId;

  _iacs.AuthUser? owner;

  _is.UuidValue ingredientId;

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

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Recipe]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Recipe copyWith({
    _is.UuidValue? id,
    _is.UuidValue? ownerId,
    _iacs.AuthUser? owner,
    _is.UuidValue? ingredientId,
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

  static RecipeInclude include({
    _iacs.AuthUserInclude? owner,
    _ippg9os6.IngredientInclude? ingredient,
    _i1t6etiy.RecipeInstructionIncludeList? instructions,
    _iir54vf2.RecipePhotoIncludeList? photos,
    _i55exiaf.RecipeFlavorTagIncludeList? flavorTags,
  }) {
    return RecipeInclude._(
      owner: owner,
      ingredient: ingredient,
      instructions: instructions,
      photos: photos,
      flavorTags: flavorTags,
    );
  }

  static RecipeIncludeList includeList({
    _is.WhereExpressionBuilder<RecipeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RecipeTable>? orderBy,
    _is.OrderByListBuilder<RecipeTable>? orderByList,
    RecipeInclude? include,
  }) {
    return RecipeIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Recipe.t),
      orderByList: orderByList?.call(Recipe.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RecipeImpl extends Recipe {
  _RecipeImpl({
    _is.UuidValue? id,
    required _is.UuidValue ownerId,
    _iacs.AuthUser? owner,
    required _is.UuidValue ingredientId,
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
  @_is.useResult
  @override
  Recipe copyWith({
    Object? id = _Undefined,
    _is.UuidValue? ownerId,
    Object? owner = _Undefined,
    _is.UuidValue? ingredientId,
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
      id: id is _is.UuidValue? ? id : this.id,
      ownerId: ownerId ?? this.ownerId,
      owner: owner is _iacs.AuthUser? ? owner : this.owner?.copyWith(),
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

class RecipeUpdateTable extends _is.UpdateTable<RecipeTable> {
  RecipeUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> ownerId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.ownerId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> ingredientId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.ingredientId,
    value,
  );

  _is.ColumnValue<String, String> title(String value) => _is.ColumnValue(
    table.title,
    value,
  );

  _is.ColumnValue<double, double> waterTempC(double value) => _is.ColumnValue(
    table.waterTempC,
    value,
  );

  _is.ColumnValue<double, double> doseGrams(double value) => _is.ColumnValue(
    table.doseGrams,
    value,
  );

  _is.ColumnValue<String, String> grindSize(String value) => _is.ColumnValue(
    table.grindSize,
    value,
  );

  _is.ColumnValue<String, String> grinderModel(String value) => _is.ColumnValue(
    table.grinderModel,
    value,
  );

  _is.ColumnValue<_io8keuuf.ExtractionMethod, _io8keuuf.ExtractionMethod>
  extractionMethod(_io8keuuf.ExtractionMethod value) => _is.ColumnValue(
    table.extractionMethod,
    value,
  );

  _is.ColumnValue<String, String> extractionMethodNote(String? value) =>
      _is.ColumnValue(
        table.extractionMethodNote,
        value,
      );

  _is.ColumnValue<Duration, Duration> extractionDuration(Duration? value) =>
      _is.ColumnValue(
        table.extractionDuration,
        value,
      );

  _is.ColumnValue<int, int> acidity(int value) => _is.ColumnValue(
    table.acidity,
    value,
  );

  _is.ColumnValue<int, int> sweetness(int value) => _is.ColumnValue(
    table.sweetness,
    value,
  );

  _is.ColumnValue<int, int> body(int value) => _is.ColumnValue(
    table.body,
    value,
  );

  _is.ColumnValue<int, int> bitterness(int value) => _is.ColumnValue(
    table.bitterness,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class RecipeTable extends _is.Table<_is.UuidValue?> {
  RecipeTable({super.tableRelation}) : super(tableName: 'recipe') {
    updateTable = RecipeUpdateTable(this);
    ownerId = _is.ColumnUuid(
      'ownerId',
      this,
    );
    ingredientId = _is.ColumnUuid(
      'ingredientId',
      this,
    );
    title = _is.ColumnString(
      'title',
      this,
    );
    waterTempC = _is.ColumnDouble(
      'waterTempC',
      this,
    );
    doseGrams = _is.ColumnDouble(
      'doseGrams',
      this,
    );
    grindSize = _is.ColumnString(
      'grindSize',
      this,
    );
    grinderModel = _is.ColumnString(
      'grinderModel',
      this,
    );
    extractionMethod = _is.ColumnEnum(
      'extractionMethod',
      this,
      _is.EnumSerialization.byName,
    );
    extractionMethodNote = _is.ColumnString(
      'extractionMethodNote',
      this,
    );
    extractionDuration = _is.ColumnDuration(
      'extractionDuration',
      this,
    );
    acidity = _is.ColumnInt(
      'acidity',
      this,
    );
    sweetness = _is.ColumnInt(
      'sweetness',
      this,
    );
    body = _is.ColumnInt(
      'body',
      this,
    );
    bitterness = _is.ColumnInt(
      'bitterness',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
  }

  late final RecipeUpdateTable updateTable;

  late final _is.ColumnUuid ownerId;

  _iacs.AuthUserTable? _owner;

  late final _is.ColumnUuid ingredientId;

  _ippg9os6.IngredientTable? _ingredient;

  late final _is.ColumnString title;

  late final _is.ColumnDouble waterTempC;

  late final _is.ColumnDouble doseGrams;

  late final _is.ColumnString grindSize;

  late final _is.ColumnString grinderModel;

  late final _is.ColumnEnum<_io8keuuf.ExtractionMethod> extractionMethod;

  late final _is.ColumnString extractionMethodNote;

  late final _is.ColumnDuration extractionDuration;

  late final _is.ColumnInt acidity;

  late final _is.ColumnInt sweetness;

  late final _is.ColumnInt body;

  late final _is.ColumnInt bitterness;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  _i1t6etiy.RecipeInstructionTable? ___instructions;

  _is.ManyRelation<_i1t6etiy.RecipeInstructionTable>? _instructions;

  _iir54vf2.RecipePhotoTable? ___photos;

  _is.ManyRelation<_iir54vf2.RecipePhotoTable>? _photos;

  _i55exiaf.RecipeFlavorTagTable? ___flavorTags;

  _is.ManyRelation<_i55exiaf.RecipeFlavorTagTable>? _flavorTags;

  _iacs.AuthUserTable get owner {
    if (_owner != null) return _owner!;
    _owner = _is.createRelationTable(
      relationFieldName: 'owner',
      field: Recipe.t.ownerId,
      foreignField: _iacs.AuthUser.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _iacs.AuthUserTable(tableRelation: foreignTableRelation),
    );
    return _owner!;
  }

  _ippg9os6.IngredientTable get ingredient {
    if (_ingredient != null) return _ingredient!;
    _ingredient = _is.createRelationTable(
      relationFieldName: 'ingredient',
      field: Recipe.t.ingredientId,
      foreignField: _ippg9os6.Ingredient.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _ippg9os6.IngredientTable(tableRelation: foreignTableRelation),
    );
    return _ingredient!;
  }

  _i1t6etiy.RecipeInstructionTable get __instructions {
    if (___instructions != null) return ___instructions!;
    ___instructions = _is.createRelationTable(
      relationFieldName: '__instructions',
      field: Recipe.t.id,
      foreignField: _i1t6etiy.RecipeInstruction.t.recipeId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i1t6etiy.RecipeInstructionTable(tableRelation: foreignTableRelation),
    );
    return ___instructions!;
  }

  _iir54vf2.RecipePhotoTable get __photos {
    if (___photos != null) return ___photos!;
    ___photos = _is.createRelationTable(
      relationFieldName: '__photos',
      field: Recipe.t.id,
      foreignField: _iir54vf2.RecipePhoto.t.recipeId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _iir54vf2.RecipePhotoTable(tableRelation: foreignTableRelation),
    );
    return ___photos!;
  }

  _i55exiaf.RecipeFlavorTagTable get __flavorTags {
    if (___flavorTags != null) return ___flavorTags!;
    ___flavorTags = _is.createRelationTable(
      relationFieldName: '__flavorTags',
      field: Recipe.t.id,
      foreignField: _i55exiaf.RecipeFlavorTag.t.recipeId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i55exiaf.RecipeFlavorTagTable(tableRelation: foreignTableRelation),
    );
    return ___flavorTags!;
  }

  _is.ManyRelation<_i1t6etiy.RecipeInstructionTable> get instructions {
    if (_instructions != null) return _instructions!;
    var relationTable = _is.createRelationTable(
      relationFieldName: 'instructions',
      field: Recipe.t.id,
      foreignField: _i1t6etiy.RecipeInstruction.t.recipeId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i1t6etiy.RecipeInstructionTable(tableRelation: foreignTableRelation),
    );
    _instructions = _is.ManyRelation<_i1t6etiy.RecipeInstructionTable>(
      tableWithRelations: relationTable,
      table: _i1t6etiy.RecipeInstructionTable(
        tableRelation: relationTable.tableRelation!.lastRelation,
      ),
    );
    return _instructions!;
  }

  _is.ManyRelation<_iir54vf2.RecipePhotoTable> get photos {
    if (_photos != null) return _photos!;
    var relationTable = _is.createRelationTable(
      relationFieldName: 'photos',
      field: Recipe.t.id,
      foreignField: _iir54vf2.RecipePhoto.t.recipeId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _iir54vf2.RecipePhotoTable(tableRelation: foreignTableRelation),
    );
    _photos = _is.ManyRelation<_iir54vf2.RecipePhotoTable>(
      tableWithRelations: relationTable,
      table: _iir54vf2.RecipePhotoTable(
        tableRelation: relationTable.tableRelation!.lastRelation,
      ),
    );
    return _photos!;
  }

  _is.ManyRelation<_i55exiaf.RecipeFlavorTagTable> get flavorTags {
    if (_flavorTags != null) return _flavorTags!;
    var relationTable = _is.createRelationTable(
      relationFieldName: 'flavorTags',
      field: Recipe.t.id,
      foreignField: _i55exiaf.RecipeFlavorTag.t.recipeId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i55exiaf.RecipeFlavorTagTable(tableRelation: foreignTableRelation),
    );
    _flavorTags = _is.ManyRelation<_i55exiaf.RecipeFlavorTagTable>(
      tableWithRelations: relationTable,
      table: _i55exiaf.RecipeFlavorTagTable(
        tableRelation: relationTable.tableRelation!.lastRelation,
      ),
    );
    return _flavorTags!;
  }

  @override
  List<_is.Column> get columns => [
    id,
    ownerId,
    ingredientId,
    title,
    waterTempC,
    doseGrams,
    grindSize,
    grinderModel,
    extractionMethod,
    extractionMethodNote,
    extractionDuration,
    acidity,
    sweetness,
    body,
    bitterness,
    createdAt,
    updatedAt,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'owner') {
      return owner;
    }
    if (relationField == 'ingredient') {
      return ingredient;
    }
    if (relationField == 'instructions') {
      return __instructions;
    }
    if (relationField == 'photos') {
      return __photos;
    }
    if (relationField == 'flavorTags') {
      return __flavorTags;
    }
    return null;
  }
}

class RecipeInclude extends _is.IncludeObject {
  RecipeInclude._({
    _iacs.AuthUserInclude? owner,
    _ippg9os6.IngredientInclude? ingredient,
    _i1t6etiy.RecipeInstructionIncludeList? instructions,
    _iir54vf2.RecipePhotoIncludeList? photos,
    _i55exiaf.RecipeFlavorTagIncludeList? flavorTags,
  }) {
    _owner = owner;
    _ingredient = ingredient;
    _instructions = instructions;
    _photos = photos;
    _flavorTags = flavorTags;
  }

  _iacs.AuthUserInclude? _owner;

  _ippg9os6.IngredientInclude? _ingredient;

  _i1t6etiy.RecipeInstructionIncludeList? _instructions;

  _iir54vf2.RecipePhotoIncludeList? _photos;

  _i55exiaf.RecipeFlavorTagIncludeList? _flavorTags;

  @override
  Map<String, _is.Include?> get includes => {
    'owner': _owner,
    'ingredient': _ingredient,
    'instructions': _instructions,
    'photos': _photos,
    'flavorTags': _flavorTags,
  };

  @override
  _is.Table<_is.UuidValue?> get table => Recipe.t;
}

class RecipeIncludeList extends _is.IncludeList {
  RecipeIncludeList._({
    _is.WhereExpressionBuilder<RecipeTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Recipe.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => Recipe.t;
}

class RecipeRepository {
  const RecipeRepository._();

  final attach = const RecipeAttachRepository._();

  final attachRow = const RecipeAttachRowRepository._();

  /// Returns a list of [Recipe]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<Recipe>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RecipeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RecipeTable>? orderBy,
    _is.OrderByListBuilder<RecipeTable>? orderByList,
    _is.Transaction? transaction,
    RecipeInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Recipe>(
      where: where?.call(Recipe.t),
      orderBy: orderBy?.call(Recipe.t),
      orderByList: orderByList?.call(Recipe.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Recipe] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<Recipe?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RecipeTable>? where,
    int? offset,
    _is.OrderByBuilder<RecipeTable>? orderBy,
    _is.OrderByListBuilder<RecipeTable>? orderByList,
    _is.Transaction? transaction,
    RecipeInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Recipe>(
      where: where?.call(Recipe.t),
      orderBy: orderBy?.call(Recipe.t),
      orderByList: orderByList?.call(Recipe.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Recipe] by its [id] or null if no such row exists.
  Future<Recipe?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    RecipeInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Recipe>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Recipe]s in the list and returns the inserted rows.
  ///
  /// The returned [Recipe]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Recipe>> insert(
    _is.DatabaseSession session,
    List<Recipe> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Recipe>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Recipe] and returns the inserted row.
  ///
  /// The returned [Recipe] will have its `id` field set.
  Future<Recipe> insertRow(
    _is.DatabaseSession session,
    Recipe row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Recipe>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Recipe]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [Recipe]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Recipe>> upsert(
    _is.DatabaseSession session,
    List<Recipe> rows, {
    required _is.ColumnSelections<RecipeTable> conflictColumns,
    _is.ColumnSelections<RecipeTable>? updateColumns,
    _is.WhereExpressionBuilder<RecipeTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Recipe>(
      rows,
      conflictColumns: conflictColumns(Recipe.t),
      updateColumns: updateColumns?.call(Recipe.t),
      updateWhere: updateWhere?.call(Recipe.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Recipe] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [Recipe] will have its `id` field set.
  Future<Recipe?> upsertRow(
    _is.DatabaseSession session,
    Recipe row, {
    required _is.ColumnSelections<RecipeTable> conflictColumns,
    _is.ColumnSelections<RecipeTable>? updateColumns,
    _is.WhereExpressionBuilder<RecipeTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Recipe>(
      row,
      conflictColumns: conflictColumns(Recipe.t),
      updateColumns: updateColumns?.call(Recipe.t),
      updateWhere: updateWhere?.call(Recipe.t),
      transaction: transaction,
    );
  }

  /// Updates all [Recipe]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Recipe>> update(
    _is.DatabaseSession session,
    List<Recipe> rows, {
    _is.ColumnSelections<RecipeTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Recipe>(
      rows,
      columns: columns?.call(Recipe.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Recipe]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Recipe> updateRow(
    _is.DatabaseSession session,
    Recipe row, {
    _is.ColumnSelections<RecipeTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Recipe>(
      row,
      columns: columns?.call(Recipe.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Recipe] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Recipe?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<RecipeUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Recipe>(
      id,
      columnValues: columnValues(Recipe.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Recipe]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Recipe>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<RecipeUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<RecipeTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RecipeTable>? orderBy,
    _is.OrderByListBuilder<RecipeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Recipe>(
      columnValues: columnValues(Recipe.t.updateTable),
      where: where(Recipe.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Recipe.t),
      orderByList: orderByList?.call(Recipe.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Recipe]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Recipe>> delete(
    _is.DatabaseSession session,
    List<Recipe> rows, {
    _is.OrderByBuilder<RecipeTable>? orderBy,
    _is.OrderByListBuilder<RecipeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Recipe>(
      rows,
      orderBy: orderBy?.call(Recipe.t),
      orderByList: orderByList?.call(Recipe.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Recipe].
  Future<Recipe> deleteRow(
    _is.DatabaseSession session,
    Recipe row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Recipe>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Recipe>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RecipeTable> where,
    _is.OrderByBuilder<RecipeTable>? orderBy,
    _is.OrderByListBuilder<RecipeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Recipe>(
      where: where(Recipe.t),
      orderBy: orderBy?.call(Recipe.t),
      orderByList: orderByList?.call(Recipe.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RecipeTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Recipe>(
      where: where?.call(Recipe.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Recipe] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RecipeTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Recipe>(
      where: where(Recipe.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class RecipeAttachRepository {
  const RecipeAttachRepository._();

  /// Creates a relation between this [Recipe] and the given [RecipeInstruction]s
  /// by setting each [RecipeInstruction]'s foreign key `recipeId` to refer to this [Recipe].
  Future<void> instructions(
    _is.DatabaseSession session,
    Recipe recipe,
    List<_i1t6etiy.RecipeInstruction> recipeInstruction, {
    _is.Transaction? transaction,
  }) async {
    if (recipeInstruction.any((e) => e.id == null)) {
      throw ArgumentError.notNull('recipeInstruction.id');
    }
    if (recipe.id == null) {
      throw ArgumentError.notNull('recipe.id');
    }

    var $recipeInstruction = recipeInstruction
        .map((e) => e.copyWith(recipeId: recipe.id))
        .toList();
    await session.db.update<_i1t6etiy.RecipeInstruction>(
      $recipeInstruction,
      columns: [_i1t6etiy.RecipeInstruction.t.recipeId],
      transaction: transaction,
    );
  }

  /// Creates a relation between this [Recipe] and the given [RecipePhoto]s
  /// by setting each [RecipePhoto]'s foreign key `recipeId` to refer to this [Recipe].
  Future<void> photos(
    _is.DatabaseSession session,
    Recipe recipe,
    List<_iir54vf2.RecipePhoto> recipePhoto, {
    _is.Transaction? transaction,
  }) async {
    if (recipePhoto.any((e) => e.id == null)) {
      throw ArgumentError.notNull('recipePhoto.id');
    }
    if (recipe.id == null) {
      throw ArgumentError.notNull('recipe.id');
    }

    var $recipePhoto = recipePhoto
        .map((e) => e.copyWith(recipeId: recipe.id))
        .toList();
    await session.db.update<_iir54vf2.RecipePhoto>(
      $recipePhoto,
      columns: [_iir54vf2.RecipePhoto.t.recipeId],
      transaction: transaction,
    );
  }

  /// Creates a relation between this [Recipe] and the given [RecipeFlavorTag]s
  /// by setting each [RecipeFlavorTag]'s foreign key `recipeId` to refer to this [Recipe].
  Future<void> flavorTags(
    _is.DatabaseSession session,
    Recipe recipe,
    List<_i55exiaf.RecipeFlavorTag> recipeFlavorTag, {
    _is.Transaction? transaction,
  }) async {
    if (recipeFlavorTag.any((e) => e.id == null)) {
      throw ArgumentError.notNull('recipeFlavorTag.id');
    }
    if (recipe.id == null) {
      throw ArgumentError.notNull('recipe.id');
    }

    var $recipeFlavorTag = recipeFlavorTag
        .map((e) => e.copyWith(recipeId: recipe.id))
        .toList();
    await session.db.update<_i55exiaf.RecipeFlavorTag>(
      $recipeFlavorTag,
      columns: [_i55exiaf.RecipeFlavorTag.t.recipeId],
      transaction: transaction,
    );
  }
}

class RecipeAttachRowRepository {
  const RecipeAttachRowRepository._();

  /// Creates a relation between the given [Recipe] and [AuthUser]
  /// by setting the [Recipe]'s foreign key `ownerId` to refer to the [AuthUser].
  Future<void> owner(
    _is.DatabaseSession session,
    Recipe recipe,
    _iacs.AuthUser owner, {
    _is.Transaction? transaction,
  }) async {
    if (recipe.id == null) {
      throw ArgumentError.notNull('recipe.id');
    }
    if (owner.id == null) {
      throw ArgumentError.notNull('owner.id');
    }

    var $recipe = recipe.copyWith(ownerId: owner.id);
    await session.db.updateRow<Recipe>(
      $recipe,
      columns: [Recipe.t.ownerId],
      transaction: transaction,
    );
  }

  /// Creates a relation between the given [Recipe] and [Ingredient]
  /// by setting the [Recipe]'s foreign key `ingredientId` to refer to the [Ingredient].
  Future<void> ingredient(
    _is.DatabaseSession session,
    Recipe recipe,
    _ippg9os6.Ingredient ingredient, {
    _is.Transaction? transaction,
  }) async {
    if (recipe.id == null) {
      throw ArgumentError.notNull('recipe.id');
    }
    if (ingredient.id == null) {
      throw ArgumentError.notNull('ingredient.id');
    }

    var $recipe = recipe.copyWith(ingredientId: ingredient.id);
    await session.db.updateRow<Recipe>(
      $recipe,
      columns: [Recipe.t.ingredientId],
      transaction: transaction,
    );
  }

  /// Creates a relation between this [Recipe] and the given [RecipeInstruction]
  /// by setting the [RecipeInstruction]'s foreign key `recipeId` to refer to this [Recipe].
  Future<void> instructions(
    _is.DatabaseSession session,
    Recipe recipe,
    _i1t6etiy.RecipeInstruction recipeInstruction, {
    _is.Transaction? transaction,
  }) async {
    if (recipeInstruction.id == null) {
      throw ArgumentError.notNull('recipeInstruction.id');
    }
    if (recipe.id == null) {
      throw ArgumentError.notNull('recipe.id');
    }

    var $recipeInstruction = recipeInstruction.copyWith(recipeId: recipe.id);
    await session.db.updateRow<_i1t6etiy.RecipeInstruction>(
      $recipeInstruction,
      columns: [_i1t6etiy.RecipeInstruction.t.recipeId],
      transaction: transaction,
    );
  }

  /// Creates a relation between this [Recipe] and the given [RecipePhoto]
  /// by setting the [RecipePhoto]'s foreign key `recipeId` to refer to this [Recipe].
  Future<void> photos(
    _is.DatabaseSession session,
    Recipe recipe,
    _iir54vf2.RecipePhoto recipePhoto, {
    _is.Transaction? transaction,
  }) async {
    if (recipePhoto.id == null) {
      throw ArgumentError.notNull('recipePhoto.id');
    }
    if (recipe.id == null) {
      throw ArgumentError.notNull('recipe.id');
    }

    var $recipePhoto = recipePhoto.copyWith(recipeId: recipe.id);
    await session.db.updateRow<_iir54vf2.RecipePhoto>(
      $recipePhoto,
      columns: [_iir54vf2.RecipePhoto.t.recipeId],
      transaction: transaction,
    );
  }

  /// Creates a relation between this [Recipe] and the given [RecipeFlavorTag]
  /// by setting the [RecipeFlavorTag]'s foreign key `recipeId` to refer to this [Recipe].
  Future<void> flavorTags(
    _is.DatabaseSession session,
    Recipe recipe,
    _i55exiaf.RecipeFlavorTag recipeFlavorTag, {
    _is.Transaction? transaction,
  }) async {
    if (recipeFlavorTag.id == null) {
      throw ArgumentError.notNull('recipeFlavorTag.id');
    }
    if (recipe.id == null) {
      throw ArgumentError.notNull('recipe.id');
    }

    var $recipeFlavorTag = recipeFlavorTag.copyWith(recipeId: recipe.id);
    await session.db.updateRow<_i55exiaf.RecipeFlavorTag>(
      $recipeFlavorTag,
      columns: [_i55exiaf.RecipeFlavorTag.t.recipeId],
      transaction: transaction,
    );
  }
}
