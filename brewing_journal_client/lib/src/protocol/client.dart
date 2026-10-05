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
import 'dart:async' as _ida;
import 'package:brewing_journal_client/src/protocol/brewing/beverage_kind.dart'
    as _i4erj0ra;
import 'package:brewing_journal_client/src/protocol/brewing/favorite_save_result.dart'
    as _i6y9w12f;
import 'package:brewing_journal_client/src/protocol/brewing/ingredient.dart'
    as _ifm45unr;
import 'package:brewing_journal_client/src/protocol/brewing/ingredient_draft.dart'
    as _i1d0oxbl;
import 'package:brewing_journal_client/src/protocol/brewing/recipe.dart'
    as _i261jxz0;
import 'package:brewing_journal_client/src/protocol/brewing/recipe_access.dart'
    as _i6vleds3;
import 'package:brewing_journal_client/src/protocol/brewing/recipe_detail.dart'
    as _io43huzj;
import 'package:brewing_journal_client/src/protocol/brewing/recipe_draft.dart'
    as _ii9ba79p;
import 'package:brewing_journal_client/src/protocol/brewing/recipe_photo.dart'
    as _ijse9n9l;
import 'package:brewing_journal_client/src/protocol/brewing/upload_ticket.dart'
    as _i1wqbnj3;
import 'package:brewing_journal_client/src/protocol/teams/invite_link.dart'
    as _i5bdzsjf;
import 'package:brewing_journal_client/src/protocol/teams/team_role.dart'
    as _in4rfda8;
import 'package:brewing_journal_client/src/protocol/teams/team_summary.dart'
    as _ih3q8aev;
import 'package:http/http.dart' as _i85jenna;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'protocol.dart' as _il2as5qe;

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
/// {@category Endpoint}
class EndpointEmailIdp extends _iaic.EndpointEmailIdpBase {
  EndpointEmailIdp(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  /// Logs in the user and returns a new session.
  ///
  /// Throws an [EmailAccountLoginException] in case of errors, with reason:
  /// - [EmailAccountLoginExceptionReason.invalidCredentials] if the email or
  ///   password is incorrect.
  /// - [EmailAccountLoginExceptionReason.tooManyAttempts] if there have been
  ///   too many failed login attempts.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<_iacc.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  /// Starts the registration for a new user account with an email-based login
  /// associated to it.
  ///
  /// Upon successful completion of this method, an email will have been
  /// sent to [email] with a verification link, which the user must open to
  /// complete the registration.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _ida.Future<_isc.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _ida.Future<String> verifyRegistrationCode({
    required _isc.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _ida.Future<_iacc.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _ida.Future<_isc.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _ida.Future<String> verifyPasswordResetCode({
    required _isc.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );

  @override
  _ida.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'emailIdp',
    'hasAccount',
    {},
  );
}

/// By extending [RefreshJwtTokensEndpoint], the JWT token refresh endpoint
/// is made available on the server and enables automatic token refresh on the client.
/// {@category Endpoint}
class EndpointJwtRefresh extends _iacc.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// If [refreshToken] is omitted, cookie-mode web clients fall back to the
  /// configured HttpOnly refresh cookie. When neither source is present this
  /// throws [RefreshTokenNotFoundException], the same public "no usable refresh
  /// credential" exception used for unknown refresh tokens.
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _ida.Future<_iacc.AuthSuccess> refreshAccessToken({String? refreshToken}) =>
      caller.callServerEndpoint<_iacc.AuthSuccess>(
        'jwtRefresh',
        'refreshAccessToken',
        {'refreshToken': refreshToken},
        authenticated: false,
      );
}

/// The caller's coffee beans, tea leaves, and matcha grades, plus ingredients
/// used by recipes on the caller's teams.
/// {@category Endpoint}
class EndpointIngredient extends EndpointAuthenticated {
  EndpointIngredient(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'ingredient';

  /// Ingredients of [kind] whose name starts with [query] (case-insensitive),
  /// ordered by name. Includes the caller's rows and rows used on their teams.
  /// One row per folded name; the caller's own row wins.
  _ida.Future<List<_ifm45unr.Ingredient>> search(
    _i4erj0ra.BeverageKind kind,
    String query,
    int limit,
  ) => caller.callServerEndpoint<List<_ifm45unr.Ingredient>>(
    'ingredient',
    'search',
    {
      'kind': kind,
      'query': query,
      'limit': limit,
    },
  );

  /// Returns the caller's existing ingredient with the same kind and name
  /// (case-insensitive), or inserts a new one.
  _ida.Future<_ifm45unr.Ingredient> register(_i1d0oxbl.IngredientDraft draft) =>
      caller.callServerEndpoint<_ifm45unr.Ingredient>(
        'ingredient',
        'register',
        {'draft': draft},
      );

  /// Copies a team ingredient onto the caller, or returns the row they
  /// already have for that kind and name. The caller's own id is returned
  /// unchanged. A private ingredient is [BrewingErrorCode.notFound].
  _ida.Future<_ifm45unr.Ingredient> adopt(_isc.UuidValue id) =>
      caller.callServerEndpoint<_ifm45unr.Ingredient>(
        'ingredient',
        'adopt',
        {'id': id},
      );
}

/// {@category Endpoint}
class EndpointRecipe extends EndpointAuthenticated {
  EndpointRecipe(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'recipe';

  /// Inserts a recipe. When [draft.id] is set, that recipe is the source of a
  /// new version: the caller must be allowed to edit it, the new row keeps
  /// its team and photos, and the source row is left unchanged.
  _ida.Future<_io43huzj.RecipeDetail> save(_ii9ba79p.RecipeDraft draft) =>
      caller.callServerEndpoint<_io43huzj.RecipeDetail>(
        'recipe',
        'save',
        {'draft': draft},
      );

  /// The recipe with its ingredient, ordered instructions, tags, photos (with
  /// `publicUrl`), and the caller's access.
  ///
  /// [teamId] null fills [Recipe.isFavorite] from the caller's personal rows.
  /// Set fills it from that team's rows. The caller must be a member and the
  /// recipe must be on that team.
  _ida.Future<_io43huzj.RecipeDetail> get(
    _isc.UuidValue id, {
    _isc.UuidValue? teamId,
  }) => caller.callServerEndpoint<_io43huzj.RecipeDetail>(
    'recipe',
    'get',
    {
      'id': id,
      'teamId': teamId,
    },
  );

  /// The caller's own recipes, most recently updated first.
  _ida.Future<List<_i261jxz0.Recipe>> listMine(
    int limit,
    int offset,
  ) => caller.callServerEndpoint<List<_i261jxz0.Recipe>>(
    'recipe',
    'listMine',
    {
      'limit': limit,
      'offset': offset,
    },
  );

  /// The caller's own recipes that are in favorites, most recently updated first.
  _ida.Future<List<_i261jxz0.Recipe>> listFavorites(
    int limit,
    int offset,
  ) => caller.callServerEndpoint<List<_i261jxz0.Recipe>>(
    'recipe',
    'listFavorites',
    {
      'limit': limit,
      'offset': offset,
    },
  );

  /// Team recipes the team has saved, most recently updated first.
  /// Membership required.
  _ida.Future<List<_i261jxz0.Recipe>> listTeamFavorites(
    _isc.UuidValue teamId,
    int limit,
    int offset,
  ) => caller.callServerEndpoint<List<_i261jxz0.Recipe>>(
    'recipe',
    'listTeamFavorites',
    {
      'teamId': teamId,
      'limit': limit,
      'offset': offset,
    },
  );

  /// Saves [recipeId] as the caller's favorite for its title.
  ///
  /// When another favorite already uses that title and [replace] is false,
  /// nothing changes and [FavoriteSaveResult.saved] is false.
  _ida.Future<_i6y9w12f.FavoriteSaveResult> saveFavorite(
    _isc.UuidValue recipeId,
    bool replace,
  ) => caller.callServerEndpoint<_i6y9w12f.FavoriteSaveResult>(
    'recipe',
    'saveFavorite',
    {
      'recipeId': recipeId,
      'replace': replace,
    },
  );

  /// Removes [recipeId] from the caller's favorites.
  _ida.Future<void> removeFavorite(_isc.UuidValue recipeId) =>
      caller.callServerEndpoint<void>(
        'recipe',
        'removeFavorite',
        {'recipeId': recipeId},
      );

  /// Saves [recipeId] as [teamId]'s favorite for its title.
  _ida.Future<_i6y9w12f.FavoriteSaveResult> saveTeamFavorite(
    _isc.UuidValue teamId,
    _isc.UuidValue recipeId,
    bool replace,
  ) => caller.callServerEndpoint<_i6y9w12f.FavoriteSaveResult>(
    'recipe',
    'saveTeamFavorite',
    {
      'teamId': teamId,
      'recipeId': recipeId,
      'replace': replace,
    },
  );

  /// Removes [recipeId] from [teamId]'s favorites.
  _ida.Future<void> removeTeamFavorite(
    _isc.UuidValue teamId,
    _isc.UuidValue recipeId,
  ) => caller.callServerEndpoint<void>(
    'recipe',
    'removeTeamFavorite',
    {
      'teamId': teamId,
      'recipeId': recipeId,
    },
  );

  _ida.Future<_i6vleds3.RecipeAccess> getAccess(_isc.UuidValue id) =>
      caller.callServerEndpoint<_i6vleds3.RecipeAccess>(
        'recipe',
        'getAccess',
        {'id': id},
      );

  /// Grinder models from the caller's recipes and from recipes on the
  /// caller's teams. One spelling per folded name, from the newest recipe.
  _ida.Future<List<String>> listGrinderModels(
    String query,
    int limit,
  ) => caller.callServerEndpoint<List<String>>(
    'recipe',
    'listGrinderModels',
    {
      'query': query,
      'limit': limit,
    },
  );

  /// Team recipes, most recently updated first. Membership required.
  _ida.Future<List<_i261jxz0.Recipe>> listForTeam(
    _isc.UuidValue teamId,
    int limit,
    int offset,
  ) => caller.callServerEndpoint<List<_i261jxz0.Recipe>>(
    'recipe',
    'listForTeam',
    {
      'teamId': teamId,
      'limit': limit,
      'offset': offset,
    },
  );

  /// Moves a personal recipe the caller owns onto a team they edit.
  _ida.Future<_i261jxz0.Recipe> assignToTeam(
    _isc.UuidValue recipeId,
    _isc.UuidValue teamId,
  ) => caller.callServerEndpoint<_i261jxz0.Recipe>(
    'recipe',
    'assignToTeam',
    {
      'recipeId': recipeId,
      'teamId': teamId,
    },
  );

  /// Clears `teamId`. The recipe owner or a team editor may do this.
  _ida.Future<_i261jxz0.Recipe> removeFromTeam(_isc.UuidValue recipeId) =>
      caller.callServerEndpoint<_i261jxz0.Recipe>(
        'recipe',
        'removeFromTeam',
        {'recipeId': recipeId},
      );

  /// Deletes the recipe and its child rows; photo files are removed
  /// best-effort after the delete commits.
  _ida.Future<void> delete(_isc.UuidValue id) =>
      caller.callServerEndpoint<void>(
        'recipe',
        'delete',
        {'id': id},
      );
}

/// Photo uploads: the server picks the storage path, the client uploads to
/// it, and a row is written only after the upload is verified.
/// {@category Endpoint}
class EndpointRecipeMedia extends EndpointAuthenticated {
  EndpointRecipeMedia(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'recipeMedia';

  _ida.Future<_i1wqbnj3.UploadTicket> createUploadDescription(
    _isc.UuidValue recipeId,
  ) => caller.callServerEndpoint<_i1wqbnj3.UploadTicket>(
    'recipeMedia',
    'createUploadDescription',
    {'recipeId': recipeId},
  );

  /// Verifies the upload at [path] and attaches it to the recipe. Calling it
  /// again for the same path returns the same row.
  _ida.Future<_ijse9n9l.RecipePhoto> confirmUpload(
    _isc.UuidValue recipeId,
    String path,
  ) => caller.callServerEndpoint<_ijse9n9l.RecipePhoto>(
    'recipeMedia',
    'confirmUpload',
    {
      'recipeId': recipeId,
      'path': path,
    },
  );

  _ida.Future<void> remove(_isc.UuidValue photoId) =>
      caller.callServerEndpoint<void>(
        'recipeMedia',
        'remove',
        {'photoId': photoId},
      );
}

/// Base class for every domain endpoint: all methods require a signed-in user.
/// {@category Endpoint}
abstract class EndpointAuthenticated extends _isc.EndpointRef {
  EndpointAuthenticated(_isc.EndpointCaller caller) : super(caller);
}

/// {@category Endpoint}
class EndpointTeam extends EndpointAuthenticated {
  EndpointTeam(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'team';

  /// Creates a team and an editor membership for the caller.
  _ida.Future<_ih3q8aev.TeamSummary> create(String name) =>
      caller.callServerEndpoint<_ih3q8aev.TeamSummary>(
        'team',
        'create',
        {'name': name},
      );

  /// Teams the caller belongs to, with their role on each.
  _ida.Future<List<_ih3q8aev.TeamSummary>> listMine() =>
      caller.callServerEndpoint<List<_ih3q8aev.TeamSummary>>(
        'team',
        'listMine',
        {},
      );

  /// Issues a single-use invite URL. Only the team owner may create invites.
  _ida.Future<_i5bdzsjf.InviteLink> createInvite(
    _isc.UuidValue teamId,
    _in4rfda8.TeamRole role,
    Duration ttl,
  ) => caller.callServerEndpoint<_i5bdzsjf.InviteLink>(
    'team',
    'createInvite',
    {
      'teamId': teamId,
      'role': role,
      'ttl': ttl,
    },
  );

  /// Claims an unused, unexpired invite and inserts a membership.
  ///
  /// Already a member → `alreadyMember` (invite stays unused). A lost race
  /// on the claim → `inviteUsed` or `inviteExpired`, with no write.
  _ida.Future<_ih3q8aev.TeamSummary> acceptInvite(String token) =>
      caller.callServerEndpoint<_ih3q8aev.TeamSummary>(
        'team',
        'acceptInvite',
        {'token': token},
      );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _iaic.Caller(client);
    serverpod_auth_core = _iacc.Caller(client);
  }

  late final _iaic.Caller serverpod_auth_idp;

  late final _iacc.Caller serverpod_auth_core;
}

class Client extends _isc.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _isc.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_isc.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
    _i85jenna.Client? httpClientOverride,
  }) : super(
         host,
         _il2as5qe.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
         httpClientOverride: httpClientOverride,
       ) {
    emailIdp = EndpointEmailIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    ingredient = EndpointIngredient(this);
    recipe = EndpointRecipe(this);
    recipeMedia = EndpointRecipeMedia(this);
    team = EndpointTeam(this);
    modules = Modules(this);
  }

  late final EndpointEmailIdp emailIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointIngredient ingredient;

  late final EndpointRecipe recipe;

  late final EndpointRecipeMedia recipeMedia;

  late final EndpointTeam team;

  late final Modules modules;

  @override
  Map<String, _isc.EndpointRef> get endpointRefLookup => {
    'emailIdp': emailIdp,
    'jwtRefresh': jwtRefresh,
    'ingredient': ingredient,
    'recipe': recipe,
    'recipeMedia': recipeMedia,
    'team': team,
  };

  @override
  Map<String, _isc.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
