/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:brewing_journal_client/src/protocol/brewing/ingredient.dart'
    as _ifm45unr;
import 'package:brewing_journal_client/src/protocol/brewing/recipe.dart'
    as _i261jxz0;
import 'package:brewing_journal_client/src/protocol/teams/team_member.dart'
    as _i9lbxgbk;
import 'package:brewing_journal_client/src/protocol/teams/team_summary.dart'
    as _ih3q8aev;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'brewing/beverage_kind.dart' as _ino7p0mu;
import 'brewing/brewing_error_code.dart' as _ioc3dgt7;
import 'brewing/brewing_exception.dart' as _iim692ik;
import 'brewing/extraction_method.dart' as _i54p6pxa;
import 'brewing/favorite_save_result.dart' as _i73spzup;
import 'brewing/ingredient.dart' as _ihnk7xbr;
import 'brewing/ingredient_draft.dart' as _idpdlwt4;
import 'brewing/recipe.dart' as _izkawori;
import 'brewing/recipe_access.dart' as _i99euqmx;
import 'brewing/recipe_detail.dart' as _ijpoq8bv;
import 'brewing/recipe_draft.dart' as _iy437pkv;
import 'brewing/recipe_flavor_tag.dart' as _ij3iqvmk;
import 'brewing/recipe_instruction.dart' as _id0mij74;
import 'brewing/recipe_photo.dart' as _i9xtdqqg;
import 'brewing/roast_level.dart' as _ilmoykyi;
import 'brewing/upload_ticket.dart' as _ivpdymeq;
import 'rate_limit/rate_limit_exception.dart' as _ijrm85le;
import 'teams/invite_link.dart' as _ih3460lx;
import 'teams/team.dart' as _im6wd3ml;
import 'teams/team_invite.dart' as _ixubbi3v;
import 'teams/team_member.dart' as _ijp4z787;
import 'teams/team_membership.dart' as _it1ysroj;
import 'teams/team_role.dart' as _i8uq5mqx;
import 'teams/team_summary.dart' as _i5r78mbx;
export 'brewing/beverage_kind.dart';
export 'brewing/brewing_error_code.dart';
export 'brewing/brewing_exception.dart';
export 'brewing/extraction_method.dart';
export 'brewing/favorite_save_result.dart';
export 'brewing/ingredient.dart';
export 'brewing/ingredient_draft.dart';
export 'brewing/recipe.dart';
export 'brewing/recipe_access.dart';
export 'brewing/recipe_detail.dart';
export 'brewing/recipe_draft.dart';
export 'brewing/recipe_flavor_tag.dart';
export 'brewing/recipe_instruction.dart';
export 'brewing/recipe_photo.dart';
export 'brewing/roast_level.dart';
export 'brewing/upload_ticket.dart';
export 'rate_limit/rate_limit_exception.dart';
export 'teams/invite_link.dart';
export 'teams/team.dart';
export 'teams/team_invite.dart';
export 'teams/team_member.dart';
export 'teams/team_membership.dart';
export 'teams/team_role.dart';
export 'teams/team_summary.dart';
export 'client.dart';

class Protocol extends _isc.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _isc.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _ino7p0mu.BeverageKind) {
      return _ino7p0mu.BeverageKind.fromJson(data) as T;
    }
    if (t == _ioc3dgt7.BrewingErrorCode) {
      return _ioc3dgt7.BrewingErrorCode.fromJson(data) as T;
    }
    if (t == _iim692ik.BrewingException) {
      return _iim692ik.BrewingException.fromJson(data) as T;
    }
    if (t == _i54p6pxa.ExtractionMethod) {
      return _i54p6pxa.ExtractionMethod.fromJson(data) as T;
    }
    if (t == _i73spzup.FavoriteSaveResult) {
      return _i73spzup.FavoriteSaveResult.fromJson(data) as T;
    }
    if (t == _ihnk7xbr.Ingredient) {
      return _ihnk7xbr.Ingredient.fromJson(data) as T;
    }
    if (t == _idpdlwt4.IngredientDraft) {
      return _idpdlwt4.IngredientDraft.fromJson(data) as T;
    }
    if (t == _izkawori.Recipe) {
      return _izkawori.Recipe.fromJson(data) as T;
    }
    if (t == _i99euqmx.RecipeAccess) {
      return _i99euqmx.RecipeAccess.fromJson(data) as T;
    }
    if (t == _ijpoq8bv.RecipeDetail) {
      return _ijpoq8bv.RecipeDetail.fromJson(data) as T;
    }
    if (t == _iy437pkv.RecipeDraft) {
      return _iy437pkv.RecipeDraft.fromJson(data) as T;
    }
    if (t == _ij3iqvmk.RecipeFlavorTag) {
      return _ij3iqvmk.RecipeFlavorTag.fromJson(data) as T;
    }
    if (t == _id0mij74.RecipeInstruction) {
      return _id0mij74.RecipeInstruction.fromJson(data) as T;
    }
    if (t == _i9xtdqqg.RecipePhoto) {
      return _i9xtdqqg.RecipePhoto.fromJson(data) as T;
    }
    if (t == _ilmoykyi.RoastLevel) {
      return _ilmoykyi.RoastLevel.fromJson(data) as T;
    }
    if (t == _ivpdymeq.UploadTicket) {
      return _ivpdymeq.UploadTicket.fromJson(data) as T;
    }
    if (t == _ijrm85le.RateLimitException) {
      return _ijrm85le.RateLimitException.fromJson(data) as T;
    }
    if (t == _ih3460lx.InviteLink) {
      return _ih3460lx.InviteLink.fromJson(data) as T;
    }
    if (t == _im6wd3ml.Team) {
      return _im6wd3ml.Team.fromJson(data) as T;
    }
    if (t == _ixubbi3v.TeamInvite) {
      return _ixubbi3v.TeamInvite.fromJson(data) as T;
    }
    if (t == _ijp4z787.TeamMember) {
      return _ijp4z787.TeamMember.fromJson(data) as T;
    }
    if (t == _it1ysroj.TeamMembership) {
      return _it1ysroj.TeamMembership.fromJson(data) as T;
    }
    if (t == _i8uq5mqx.TeamRole) {
      return _i8uq5mqx.TeamRole.fromJson(data) as T;
    }
    if (t == _i5r78mbx.TeamSummary) {
      return _i5r78mbx.TeamSummary.fromJson(data) as T;
    }
    if (t == _isc.getType<_ino7p0mu.BeverageKind?>()) {
      return (data != null ? _ino7p0mu.BeverageKind.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ioc3dgt7.BrewingErrorCode?>()) {
      return (data != null ? _ioc3dgt7.BrewingErrorCode.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iim692ik.BrewingException?>()) {
      return (data != null ? _iim692ik.BrewingException.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i54p6pxa.ExtractionMethod?>()) {
      return (data != null ? _i54p6pxa.ExtractionMethod.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i73spzup.FavoriteSaveResult?>()) {
      return (data != null ? _i73spzup.FavoriteSaveResult.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ihnk7xbr.Ingredient?>()) {
      return (data != null ? _ihnk7xbr.Ingredient.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_idpdlwt4.IngredientDraft?>()) {
      return (data != null ? _idpdlwt4.IngredientDraft.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_izkawori.Recipe?>()) {
      return (data != null ? _izkawori.Recipe.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i99euqmx.RecipeAccess?>()) {
      return (data != null ? _i99euqmx.RecipeAccess.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ijpoq8bv.RecipeDetail?>()) {
      return (data != null ? _ijpoq8bv.RecipeDetail.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iy437pkv.RecipeDraft?>()) {
      return (data != null ? _iy437pkv.RecipeDraft.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ij3iqvmk.RecipeFlavorTag?>()) {
      return (data != null ? _ij3iqvmk.RecipeFlavorTag.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_id0mij74.RecipeInstruction?>()) {
      return (data != null ? _id0mij74.RecipeInstruction.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i9xtdqqg.RecipePhoto?>()) {
      return (data != null ? _i9xtdqqg.RecipePhoto.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ilmoykyi.RoastLevel?>()) {
      return (data != null ? _ilmoykyi.RoastLevel.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ivpdymeq.UploadTicket?>()) {
      return (data != null ? _ivpdymeq.UploadTicket.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ijrm85le.RateLimitException?>()) {
      return (data != null ? _ijrm85le.RateLimitException.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ih3460lx.InviteLink?>()) {
      return (data != null ? _ih3460lx.InviteLink.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_im6wd3ml.Team?>()) {
      return (data != null ? _im6wd3ml.Team.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ixubbi3v.TeamInvite?>()) {
      return (data != null ? _ixubbi3v.TeamInvite.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ijp4z787.TeamMember?>()) {
      return (data != null ? _ijp4z787.TeamMember.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_it1ysroj.TeamMembership?>()) {
      return (data != null ? _it1ysroj.TeamMembership.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i8uq5mqx.TeamRole?>()) {
      return (data != null ? _i8uq5mqx.TeamRole.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i5r78mbx.TeamSummary?>()) {
      return (data != null ? _i5r78mbx.TeamSummary.fromJson(data) : null) as T;
    }
    if (t == List<_id0mij74.RecipeInstruction>) {
      return (data as List)
              .map((e) => deserialize<_id0mij74.RecipeInstruction>(e))
              .toList()
          as T;
    }
    if (t == _isc.getType<List<_id0mij74.RecipeInstruction>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_id0mij74.RecipeInstruction>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i9xtdqqg.RecipePhoto>) {
      return (data as List)
              .map((e) => deserialize<_i9xtdqqg.RecipePhoto>(e))
              .toList()
          as T;
    }
    if (t == _isc.getType<List<_i9xtdqqg.RecipePhoto>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i9xtdqqg.RecipePhoto>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_ij3iqvmk.RecipeFlavorTag>) {
      return (data as List)
              .map((e) => deserialize<_ij3iqvmk.RecipeFlavorTag>(e))
              .toList()
          as T;
    }
    if (t == _isc.getType<List<_ij3iqvmk.RecipeFlavorTag>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_ij3iqvmk.RecipeFlavorTag>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_it1ysroj.TeamMembership>) {
      return (data as List)
              .map((e) => deserialize<_it1ysroj.TeamMembership>(e))
              .toList()
          as T;
    }
    if (t == _isc.getType<List<_it1ysroj.TeamMembership>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_it1ysroj.TeamMembership>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_ixubbi3v.TeamInvite>) {
      return (data as List)
              .map((e) => deserialize<_ixubbi3v.TeamInvite>(e))
              .toList()
          as T;
    }
    if (t == _isc.getType<List<_ixubbi3v.TeamInvite>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_ixubbi3v.TeamInvite>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_izkawori.Recipe>) {
      return (data as List)
              .map((e) => deserialize<_izkawori.Recipe>(e))
              .toList()
          as T;
    }
    if (t == _isc.getType<List<_izkawori.Recipe>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_izkawori.Recipe>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_ifm45unr.Ingredient>) {
      return (data as List)
              .map((e) => deserialize<_ifm45unr.Ingredient>(e))
              .toList()
          as T;
    }
    if (t == List<_i261jxz0.Recipe>) {
      return (data as List)
              .map((e) => deserialize<_i261jxz0.Recipe>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_ih3q8aev.TeamSummary>) {
      return (data as List)
              .map((e) => deserialize<_ih3q8aev.TeamSummary>(e))
              .toList()
          as T;
    }
    if (t == List<_i9lbxgbk.TeamMember>) {
      return (data as List)
              .map((e) => deserialize<_i9lbxgbk.TeamMember>(e))
              .toList()
          as T;
    }
    try {
      return _iaic.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacc.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _ino7p0mu.BeverageKind => 'BeverageKind',
      _ioc3dgt7.BrewingErrorCode => 'BrewingErrorCode',
      _iim692ik.BrewingException => 'BrewingException',
      _i54p6pxa.ExtractionMethod => 'ExtractionMethod',
      _i73spzup.FavoriteSaveResult => 'FavoriteSaveResult',
      _ihnk7xbr.Ingredient => 'Ingredient',
      _idpdlwt4.IngredientDraft => 'IngredientDraft',
      _izkawori.Recipe => 'Recipe',
      _i99euqmx.RecipeAccess => 'RecipeAccess',
      _ijpoq8bv.RecipeDetail => 'RecipeDetail',
      _iy437pkv.RecipeDraft => 'RecipeDraft',
      _ij3iqvmk.RecipeFlavorTag => 'RecipeFlavorTag',
      _id0mij74.RecipeInstruction => 'RecipeInstruction',
      _i9xtdqqg.RecipePhoto => 'RecipePhoto',
      _ilmoykyi.RoastLevel => 'RoastLevel',
      _ivpdymeq.UploadTicket => 'UploadTicket',
      _ijrm85le.RateLimitException => 'RateLimitException',
      _ih3460lx.InviteLink => 'InviteLink',
      _im6wd3ml.Team => 'Team',
      _ixubbi3v.TeamInvite => 'TeamInvite',
      _ijp4z787.TeamMember => 'TeamMember',
      _it1ysroj.TeamMembership => 'TeamMembership',
      _i8uq5mqx.TeamRole => 'TeamRole',
      _i5r78mbx.TeamSummary => 'TeamSummary',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst(
        'brewing_journal.',
        '',
      );
    }

    switch (data) {
      case _ino7p0mu.BeverageKind():
        return 'BeverageKind';
      case _ioc3dgt7.BrewingErrorCode():
        return 'BrewingErrorCode';
      case _iim692ik.BrewingException():
        return 'BrewingException';
      case _i54p6pxa.ExtractionMethod():
        return 'ExtractionMethod';
      case _i73spzup.FavoriteSaveResult():
        return 'FavoriteSaveResult';
      case _ihnk7xbr.Ingredient():
        return 'Ingredient';
      case _idpdlwt4.IngredientDraft():
        return 'IngredientDraft';
      case _izkawori.Recipe():
        return 'Recipe';
      case _i99euqmx.RecipeAccess():
        return 'RecipeAccess';
      case _ijpoq8bv.RecipeDetail():
        return 'RecipeDetail';
      case _iy437pkv.RecipeDraft():
        return 'RecipeDraft';
      case _ij3iqvmk.RecipeFlavorTag():
        return 'RecipeFlavorTag';
      case _id0mij74.RecipeInstruction():
        return 'RecipeInstruction';
      case _i9xtdqqg.RecipePhoto():
        return 'RecipePhoto';
      case _ilmoykyi.RoastLevel():
        return 'RoastLevel';
      case _ivpdymeq.UploadTicket():
        return 'UploadTicket';
      case _ijrm85le.RateLimitException():
        return 'RateLimitException';
      case _ih3460lx.InviteLink():
        return 'InviteLink';
      case _im6wd3ml.Team():
        return 'Team';
      case _ixubbi3v.TeamInvite():
        return 'TeamInvite';
      case _ijp4z787.TeamMember():
        return 'TeamMember';
      case _it1ysroj.TeamMembership():
        return 'TeamMembership';
      case _i8uq5mqx.TeamRole():
        return 'TeamRole';
      case _i5r78mbx.TeamSummary():
        return 'TeamSummary';
    }
    className = _iaic.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacc.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'BeverageKind') {
      return deserialize<_ino7p0mu.BeverageKind>(data['data']);
    }
    if (dataClassName == 'BrewingErrorCode') {
      return deserialize<_ioc3dgt7.BrewingErrorCode>(data['data']);
    }
    if (dataClassName == 'BrewingException') {
      return deserialize<_iim692ik.BrewingException>(data['data']);
    }
    if (dataClassName == 'ExtractionMethod') {
      return deserialize<_i54p6pxa.ExtractionMethod>(data['data']);
    }
    if (dataClassName == 'FavoriteSaveResult') {
      return deserialize<_i73spzup.FavoriteSaveResult>(data['data']);
    }
    if (dataClassName == 'Ingredient') {
      return deserialize<_ihnk7xbr.Ingredient>(data['data']);
    }
    if (dataClassName == 'IngredientDraft') {
      return deserialize<_idpdlwt4.IngredientDraft>(data['data']);
    }
    if (dataClassName == 'Recipe') {
      return deserialize<_izkawori.Recipe>(data['data']);
    }
    if (dataClassName == 'RecipeAccess') {
      return deserialize<_i99euqmx.RecipeAccess>(data['data']);
    }
    if (dataClassName == 'RecipeDetail') {
      return deserialize<_ijpoq8bv.RecipeDetail>(data['data']);
    }
    if (dataClassName == 'RecipeDraft') {
      return deserialize<_iy437pkv.RecipeDraft>(data['data']);
    }
    if (dataClassName == 'RecipeFlavorTag') {
      return deserialize<_ij3iqvmk.RecipeFlavorTag>(data['data']);
    }
    if (dataClassName == 'RecipeInstruction') {
      return deserialize<_id0mij74.RecipeInstruction>(data['data']);
    }
    if (dataClassName == 'RecipePhoto') {
      return deserialize<_i9xtdqqg.RecipePhoto>(data['data']);
    }
    if (dataClassName == 'RoastLevel') {
      return deserialize<_ilmoykyi.RoastLevel>(data['data']);
    }
    if (dataClassName == 'UploadTicket') {
      return deserialize<_ivpdymeq.UploadTicket>(data['data']);
    }
    if (dataClassName == 'RateLimitException') {
      return deserialize<_ijrm85le.RateLimitException>(data['data']);
    }
    if (dataClassName == 'InviteLink') {
      return deserialize<_ih3460lx.InviteLink>(data['data']);
    }
    if (dataClassName == 'Team') {
      return deserialize<_im6wd3ml.Team>(data['data']);
    }
    if (dataClassName == 'TeamInvite') {
      return deserialize<_ixubbi3v.TeamInvite>(data['data']);
    }
    if (dataClassName == 'TeamMember') {
      return deserialize<_ijp4z787.TeamMember>(data['data']);
    }
    if (dataClassName == 'TeamMembership') {
      return deserialize<_it1ysroj.TeamMembership>(data['data']);
    }
    if (dataClassName == 'TeamRole') {
      return deserialize<_i8uq5mqx.TeamRole>(data['data']);
    }
    if (dataClassName == 'TeamSummary') {
      return deserialize<_i5r78mbx.TeamSummary>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iaic.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacc.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iaic.Protocol().registerHostProtocol('brewing_journal', this);
    _iacc.Protocol().registerHostProtocol('brewing_journal', this);
  }

  @override
  String getModuleName() => 'brewing_journal';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iaic.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacc.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
