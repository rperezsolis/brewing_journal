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
import '../brewing/extraction_method.dart' as _io8keuuf;

abstract class RecipeDraft
    implements _is.SerializableModel, _is.ProtocolSerialization {
  RecipeDraft._({
    this.id,
    required this.ingredientId,
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
    required this.flavorTags,
    required this.instructions,
  });

  factory RecipeDraft({
    _is.UuidValue? id,
    required _is.UuidValue ingredientId,
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
    required List<String> flavorTags,
    required List<String> instructions,
  }) = _RecipeDraftImpl;

  factory RecipeDraft.fromJson(Map<String, dynamic> jsonSerialization) {
    return RecipeDraft(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      ingredientId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['ingredientId'],
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
      flavorTags: _i8dlmk64.Protocol().deserialize<List<String>>(
        jsonSerialization['flavorTags'],
      ),
      instructions: _i8dlmk64.Protocol().deserialize<List<String>>(
        jsonSerialization['instructions'],
      ),
    );
  }

  _is.UuidValue? id;

  _is.UuidValue ingredientId;

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

  List<String> flavorTags;

  List<String> instructions;

  /// Returns a shallow copy of this [RecipeDraft]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RecipeDraft copyWith({
    _is.UuidValue? id,
    _is.UuidValue? ingredientId,
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
    List<String>? flavorTags,
    List<String>? instructions,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RecipeDraft',
      if (id != null) 'id': id?.toJson(),
      'ingredientId': ingredientId.toJson(),
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
      'flavorTags': flavorTags.toJson(),
      'instructions': instructions.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RecipeDraft',
      if (id != null) 'id': id?.toJson(),
      'ingredientId': ingredientId.toJson(),
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
      'flavorTags': flavorTags.toJson(),
      'instructions': instructions.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RecipeDraftImpl extends RecipeDraft {
  _RecipeDraftImpl({
    _is.UuidValue? id,
    required _is.UuidValue ingredientId,
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
    required List<String> flavorTags,
    required List<String> instructions,
  }) : super._(
         id: id,
         ingredientId: ingredientId,
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
         flavorTags: flavorTags,
         instructions: instructions,
       );

  /// Returns a shallow copy of this [RecipeDraft]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RecipeDraft copyWith({
    Object? id = _Undefined,
    _is.UuidValue? ingredientId,
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
    List<String>? flavorTags,
    List<String>? instructions,
  }) {
    return RecipeDraft(
      id: id is _is.UuidValue? ? id : this.id,
      ingredientId: ingredientId ?? this.ingredientId,
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
      flavorTags: flavorTags ?? this.flavorTags.map((e0) => e0).toList(),
      instructions: instructions ?? this.instructions.map((e0) => e0).toList(),
    );
  }
}
