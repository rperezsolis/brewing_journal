import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../test_tools/serverpod_test_tools.dart';

/// A real `serverpod_auth_core_user` row plus a session builder signed in as it.
class TestUser {
  const TestUser({required this.authUserId, required this.sessionBuilder});

  final UuidValue authUserId;
  final TestSessionBuilder sessionBuilder;
}

/// Creates an auth user, so domain rows referencing it satisfy their
/// foreign keys, and returns a session builder authenticated as that user.
Future<TestUser> createTestUser(TestSessionBuilder sessionBuilder) async {
  final authUser = await const AuthUsers().create(sessionBuilder.build());
  return TestUser(
    authUserId: authUser.id,
    sessionBuilder: sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        authUser.id.toString(),
        {},
      ),
    ),
  );
}
