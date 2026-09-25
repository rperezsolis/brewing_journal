import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

extension SessionAuth on Session {
  /// The signed-in caller's `AuthUser` id.
  ///
  /// Only valid inside endpoints with `requireLogin => true` (see
  /// `AuthenticatedEndpoint`); throws if the session is unauthenticated.
  UuidValue get callerId => authenticated!.authUserId;
}
