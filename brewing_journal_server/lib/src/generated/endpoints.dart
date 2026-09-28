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
import 'package:brewing_journal_server/src/generated/brewing/beverage_kind.dart'
    as _i32g9f9h;
import 'package:brewing_journal_server/src/generated/brewing/ingredient_draft.dart'
    as _ia1mb7ic;
import 'package:brewing_journal_server/src/generated/brewing/recipe_draft.dart'
    as _ig3znlm5;
import 'package:brewing_journal_server/src/generated/teams/team_role.dart'
    as _i0s6zzin;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import '../auth/email_idp_endpoint.dart' as _iuc1hd5t;
import '../auth/jwt_refresh_endpoint.dart' as _inwq3ztq;
import '../brewing/ingredient_endpoint.dart' as _iow895b6;
import '../brewing/recipe_endpoint.dart' as _i34apttk;
import '../brewing/recipe_media_endpoint.dart' as _i76lspal;
import '../teams/team_endpoint.dart' as _i4y95ffu;

class Endpoints extends _is.EndpointDispatch {
  @override
  void initializeEndpoints(_is.Server server) {
    var endpoints = <String, _is.Endpoint>{
      'emailIdp': _iuc1hd5t.EmailIdpEndpoint()
        ..initialize(
          server,
          'emailIdp',
          null,
        ),
      'jwtRefresh': _inwq3ztq.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'ingredient': _iow895b6.IngredientEndpoint()
        ..initialize(
          server,
          'ingredient',
          null,
        ),
      'recipe': _i34apttk.RecipeEndpoint()
        ..initialize(
          server,
          'recipe',
          null,
        ),
      'recipeMedia': _i76lspal.RecipeMediaEndpoint()
        ..initialize(
          server,
          'recipeMedia',
          null,
        ),
      'team': _i4y95ffu.TeamEndpoint()
        ..initialize(
          server,
          'team',
          null,
        ),
    };
    connectors['emailIdp'] = _is.EndpointConnector(
      name: 'emailIdp',
      endpoint: endpoints['emailIdp']!,
      methodConnectors: {
        'login': _is.MethodConnector(
          name: 'login',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint).login(
                    session,
                    email: params['email'],
                    password: params['password'],
                  ),
        ),
        'startRegistration': _is.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .startRegistration(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyRegistrationCode': _is.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _is.ParameterDescription(
              name: 'accountRequestId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _is.ParameterDescription(
              name: 'verificationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .verifyRegistrationCode(
                    session,
                    accountRequestId: params['accountRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishRegistration': _is.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _is.ParameterDescription(
              name: 'registrationToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .finishRegistration(
                    session,
                    registrationToken: params['registrationToken'],
                    password: params['password'],
                  ),
        ),
        'startPasswordReset': _is.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .startPasswordReset(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyPasswordResetCode': _is.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _is.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _is.ParameterDescription(
              name: 'verificationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .verifyPasswordResetCode(
                    session,
                    passwordResetRequestId: params['passwordResetRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishPasswordReset': _is.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _is.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'newPassword': _is.ParameterDescription(
              name: 'newPassword',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .finishPasswordReset(
                    session,
                    finishPasswordResetToken:
                        params['finishPasswordResetToken'],
                    newPassword: params['newPassword'],
                  ),
        ),
        'hasAccount': _is.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['jwtRefresh'] = _is.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _is.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _is.ParameterDescription(
              name: 'refreshToken',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['jwtRefresh'] as _inwq3ztq.JwtRefreshEndpoint)
                      .refreshAccessToken(
                        session,
                        refreshToken: params['refreshToken'],
                      ),
        ),
      },
    );
    connectors['ingredient'] = _is.EndpointConnector(
      name: 'ingredient',
      endpoint: endpoints['ingredient']!,
      methodConnectors: {
        'search': _is.MethodConnector(
          name: 'search',
          params: {
            'kind': _is.ParameterDescription(
              name: 'kind',
              type: _is.getType<_i32g9f9h.BeverageKind>(),
              nullable: false,
            ),
            'query': _is.ParameterDescription(
              name: 'query',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['ingredient'] as _iow895b6.IngredientEndpoint)
                      .search(
                        session,
                        params['kind'],
                        params['query'],
                        params['limit'],
                      ),
        ),
        'register': _is.MethodConnector(
          name: 'register',
          params: {
            'draft': _is.ParameterDescription(
              name: 'draft',
              type: _is.getType<_ia1mb7ic.IngredientDraft>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['ingredient'] as _iow895b6.IngredientEndpoint)
                      .register(
                        session,
                        params['draft'],
                      ),
        ),
      },
    );
    connectors['recipe'] = _is.EndpointConnector(
      name: 'recipe',
      endpoint: endpoints['recipe']!,
      methodConnectors: {
        'save': _is.MethodConnector(
          name: 'save',
          params: {
            'draft': _is.ParameterDescription(
              name: 'draft',
              type: _is.getType<_ig3znlm5.RecipeDraft>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['recipe'] as _i34apttk.RecipeEndpoint).save(
                session,
                params['draft'],
              ),
        ),
        'get': _is.MethodConnector(
          name: 'get',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['recipe'] as _i34apttk.RecipeEndpoint).get(
                session,
                params['id'],
              ),
        ),
        'listMine': _is.MethodConnector(
          name: 'listMine',
          params: {
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'offset': _is.ParameterDescription(
              name: 'offset',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['recipe'] as _i34apttk.RecipeEndpoint).listMine(
                    session,
                    params['limit'],
                    params['offset'],
                  ),
        ),
        'getAccess': _is.MethodConnector(
          name: 'getAccess',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['recipe'] as _i34apttk.RecipeEndpoint).getAccess(
                    session,
                    params['id'],
                  ),
        ),
        'listForTeam': _is.MethodConnector(
          name: 'listForTeam',
          params: {
            'teamId': _is.ParameterDescription(
              name: 'teamId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'offset': _is.ParameterDescription(
              name: 'offset',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['recipe'] as _i34apttk.RecipeEndpoint).listForTeam(
                    session,
                    params['teamId'],
                    params['limit'],
                    params['offset'],
                  ),
        ),
        'assignToTeam': _is.MethodConnector(
          name: 'assignToTeam',
          params: {
            'recipeId': _is.ParameterDescription(
              name: 'recipeId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'teamId': _is.ParameterDescription(
              name: 'teamId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['recipe'] as _i34apttk.RecipeEndpoint)
                  .assignToTeam(
                    session,
                    params['recipeId'],
                    params['teamId'],
                  ),
        ),
        'removeFromTeam': _is.MethodConnector(
          name: 'removeFromTeam',
          params: {
            'recipeId': _is.ParameterDescription(
              name: 'recipeId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['recipe'] as _i34apttk.RecipeEndpoint)
                  .removeFromTeam(
                    session,
                    params['recipeId'],
                  ),
        ),
        'delete': _is.MethodConnector(
          name: 'delete',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['recipe'] as _i34apttk.RecipeEndpoint).delete(
                    session,
                    params['id'],
                  ),
        ),
      },
    );
    connectors['recipeMedia'] = _is.EndpointConnector(
      name: 'recipeMedia',
      endpoint: endpoints['recipeMedia']!,
      methodConnectors: {
        'createUploadDescription': _is.MethodConnector(
          name: 'createUploadDescription',
          params: {
            'recipeId': _is.ParameterDescription(
              name: 'recipeId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['recipeMedia'] as _i76lspal.RecipeMediaEndpoint)
                      .createUploadDescription(
                        session,
                        params['recipeId'],
                      ),
        ),
        'confirmUpload': _is.MethodConnector(
          name: 'confirmUpload',
          params: {
            'recipeId': _is.ParameterDescription(
              name: 'recipeId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'path': _is.ParameterDescription(
              name: 'path',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['recipeMedia'] as _i76lspal.RecipeMediaEndpoint)
                      .confirmUpload(
                        session,
                        params['recipeId'],
                        params['path'],
                      ),
        ),
        'remove': _is.MethodConnector(
          name: 'remove',
          params: {
            'photoId': _is.ParameterDescription(
              name: 'photoId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['recipeMedia'] as _i76lspal.RecipeMediaEndpoint)
                      .remove(
                        session,
                        params['photoId'],
                      ),
        ),
      },
    );
    connectors['team'] = _is.EndpointConnector(
      name: 'team',
      endpoint: endpoints['team']!,
      methodConnectors: {
        'create': _is.MethodConnector(
          name: 'create',
          params: {
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['team'] as _i4y95ffu.TeamEndpoint).create(
                session,
                params['name'],
              ),
        ),
        'listMine': _is.MethodConnector(
          name: 'listMine',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['team'] as _i4y95ffu.TeamEndpoint).listMine(
                session,
              ),
        ),
        'createInvite': _is.MethodConnector(
          name: 'createInvite',
          params: {
            'teamId': _is.ParameterDescription(
              name: 'teamId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'role': _is.ParameterDescription(
              name: 'role',
              type: _is.getType<_i0s6zzin.TeamRole>(),
              nullable: false,
            ),
            'ttl': _is.ParameterDescription(
              name: 'ttl',
              type: _is.getType<Duration>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['team'] as _i4y95ffu.TeamEndpoint).createInvite(
                    session,
                    params['teamId'],
                    params['role'],
                    params['ttl'],
                  ),
        ),
        'acceptInvite': _is.MethodConnector(
          name: 'acceptInvite',
          params: {
            'token': _is.ParameterDescription(
              name: 'token',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['team'] as _i4y95ffu.TeamEndpoint).acceptInvite(
                    session,
                    params['token'],
                  ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _iais.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _iacs.Endpoints()
      ..initializeEndpoints(server);
  }
}
