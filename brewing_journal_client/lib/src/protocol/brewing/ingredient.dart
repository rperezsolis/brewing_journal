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
import '../brewing/beverage_kind.dart' as _ingr617k;
import '../brewing/roast_level.dart' as _ibx1prgb;

abstract class Ingredient
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Ingredient._({
    this.id,
    required this.ownerId,
    this.owner,
    required this.kind,
    required this.name,
    required this.nameKey,
    this.origin,
    this.roaster,
    this.roastLevel,
    this.processing,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Ingredient({
    _isc.UuidValue? id,
    required _isc.UuidValue ownerId,
    _iacc.AuthUser? owner,
    required _ingr617k.BeverageKind kind,
    required String name,
    required String nameKey,
    String? origin,
    String? roaster,
    _ibx1prgb.RoastLevel? roastLevel,
    String? processing,
    DateTime? createdAt,
  }) = _IngredientImpl;

  factory Ingredient.fromJson(Map<String, dynamic> jsonSerialization) {
    return Ingredient(
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
      kind: _ingr617k.BeverageKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      name: jsonSerialization['name'] as String,
      nameKey: jsonSerialization['nameKey'] as String,
      origin: jsonSerialization['origin'] as String?,
      roaster: jsonSerialization['roaster'] as String?,
      roastLevel: jsonSerialization['roastLevel'] == null
          ? null
          : _ibx1prgb.RoastLevel.fromJson(
              (jsonSerialization['roastLevel'] as String),
            ),
      processing: jsonSerialization['processing'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue ownerId;

  _iacc.AuthUser? owner;

  _ingr617k.BeverageKind kind;

  String name;

  String nameKey;

  String? origin;

  String? roaster;

  _ibx1prgb.RoastLevel? roastLevel;

  String? processing;

  DateTime createdAt;

  /// Returns a shallow copy of this [Ingredient]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Ingredient copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? ownerId,
    _iacc.AuthUser? owner,
    _ingr617k.BeverageKind? kind,
    String? name,
    String? nameKey,
    String? origin,
    String? roaster,
    _ibx1prgb.RoastLevel? roastLevel,
    String? processing,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Ingredient',
      if (id != null) 'id': id?.toJson(),
      'ownerId': ownerId.toJson(),
      if (owner != null) 'owner': owner?.toJson(),
      'kind': kind.toJson(),
      'name': name,
      'nameKey': nameKey,
      if (origin != null) 'origin': origin,
      if (roaster != null) 'roaster': roaster,
      if (roastLevel != null) 'roastLevel': roastLevel?.toJson(),
      if (processing != null) 'processing': processing,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Ingredient',
      if (id != null) 'id': id?.toJson(),
      'ownerId': ownerId.toJson(),
      if (owner != null) 'owner': owner?.toJson(),
      'kind': kind.toJson(),
      'name': name,
      'nameKey': nameKey,
      if (origin != null) 'origin': origin,
      if (roaster != null) 'roaster': roaster,
      if (roastLevel != null) 'roastLevel': roastLevel?.toJson(),
      if (processing != null) 'processing': processing,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IngredientImpl extends Ingredient {
  _IngredientImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue ownerId,
    _iacc.AuthUser? owner,
    required _ingr617k.BeverageKind kind,
    required String name,
    required String nameKey,
    String? origin,
    String? roaster,
    _ibx1prgb.RoastLevel? roastLevel,
    String? processing,
    DateTime? createdAt,
  }) : super._(
         id: id,
         ownerId: ownerId,
         owner: owner,
         kind: kind,
         name: name,
         nameKey: nameKey,
         origin: origin,
         roaster: roaster,
         roastLevel: roastLevel,
         processing: processing,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Ingredient]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Ingredient copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? ownerId,
    Object? owner = _Undefined,
    _ingr617k.BeverageKind? kind,
    String? name,
    String? nameKey,
    Object? origin = _Undefined,
    Object? roaster = _Undefined,
    Object? roastLevel = _Undefined,
    Object? processing = _Undefined,
    DateTime? createdAt,
  }) {
    return Ingredient(
      id: id is _isc.UuidValue? ? id : this.id,
      ownerId: ownerId ?? this.ownerId,
      owner: owner is _iacc.AuthUser? ? owner : this.owner?.copyWith(),
      kind: kind ?? this.kind,
      name: name ?? this.name,
      nameKey: nameKey ?? this.nameKey,
      origin: origin is String? ? origin : this.origin,
      roaster: roaster is String? ? roaster : this.roaster,
      roastLevel: roastLevel is _ibx1prgb.RoastLevel?
          ? roastLevel
          : this.roastLevel,
      processing: processing is String? ? processing : this.processing,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
