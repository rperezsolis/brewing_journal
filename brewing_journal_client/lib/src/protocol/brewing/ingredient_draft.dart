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
import '../brewing/beverage_kind.dart' as _ingr617k;
import '../brewing/roast_level.dart' as _ibx1prgb;

abstract class IngredientDraft
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  IngredientDraft._({
    required this.kind,
    required this.name,
    this.origin,
    this.roaster,
    this.roastLevel,
    this.processing,
  });

  factory IngredientDraft({
    required _ingr617k.BeverageKind kind,
    required String name,
    String? origin,
    String? roaster,
    _ibx1prgb.RoastLevel? roastLevel,
    String? processing,
  }) = _IngredientDraftImpl;

  factory IngredientDraft.fromJson(Map<String, dynamic> jsonSerialization) {
    return IngredientDraft(
      kind: _ingr617k.BeverageKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      name: jsonSerialization['name'] as String,
      origin: jsonSerialization['origin'] as String?,
      roaster: jsonSerialization['roaster'] as String?,
      roastLevel: jsonSerialization['roastLevel'] == null
          ? null
          : _ibx1prgb.RoastLevel.fromJson(
              (jsonSerialization['roastLevel'] as String),
            ),
      processing: jsonSerialization['processing'] as String?,
    );
  }

  _ingr617k.BeverageKind kind;

  String name;

  String? origin;

  String? roaster;

  _ibx1prgb.RoastLevel? roastLevel;

  String? processing;

  /// Returns a shallow copy of this [IngredientDraft]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  IngredientDraft copyWith({
    _ingr617k.BeverageKind? kind,
    String? name,
    String? origin,
    String? roaster,
    _ibx1prgb.RoastLevel? roastLevel,
    String? processing,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'IngredientDraft',
      'kind': kind.toJson(),
      'name': name,
      if (origin != null) 'origin': origin,
      if (roaster != null) 'roaster': roaster,
      if (roastLevel != null) 'roastLevel': roastLevel?.toJson(),
      if (processing != null) 'processing': processing,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'IngredientDraft',
      'kind': kind.toJson(),
      'name': name,
      if (origin != null) 'origin': origin,
      if (roaster != null) 'roaster': roaster,
      if (roastLevel != null) 'roastLevel': roastLevel?.toJson(),
      if (processing != null) 'processing': processing,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IngredientDraftImpl extends IngredientDraft {
  _IngredientDraftImpl({
    required _ingr617k.BeverageKind kind,
    required String name,
    String? origin,
    String? roaster,
    _ibx1prgb.RoastLevel? roastLevel,
    String? processing,
  }) : super._(
         kind: kind,
         name: name,
         origin: origin,
         roaster: roaster,
         roastLevel: roastLevel,
         processing: processing,
       );

  /// Returns a shallow copy of this [IngredientDraft]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  IngredientDraft copyWith({
    _ingr617k.BeverageKind? kind,
    String? name,
    Object? origin = _Undefined,
    Object? roaster = _Undefined,
    Object? roastLevel = _Undefined,
    Object? processing = _Undefined,
  }) {
    return IngredientDraft(
      kind: kind ?? this.kind,
      name: name ?? this.name,
      origin: origin is String? ? origin : this.origin,
      roaster: roaster is String? ? roaster : this.roaster,
      roastLevel: roastLevel is _ibx1prgb.RoastLevel?
          ? roastLevel
          : this.roastLevel,
      processing: processing is String? ? processing : this.processing,
    );
  }
}
