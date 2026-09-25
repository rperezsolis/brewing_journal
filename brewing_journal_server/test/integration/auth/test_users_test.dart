import 'package:brewing_journal_server/src/common/session_auth.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import '../helpers/test_users.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given createTestUser', (sessionBuilder, endpoints) {
    test('when creating a user then the auth user row exists', () async {
      final user = await createTestUser(sessionBuilder);

      final authUser = await const AuthUsers().get(
        sessionBuilder.build(),
        authUserId: user.authUserId,
      );
      expect(authUser.id, user.authUserId);
    });

    test(
      'when building its session then callerId is the created user',
      () async {
        final user = await createTestUser(sessionBuilder);

        expect(user.sessionBuilder.build().callerId, user.authUserId);
      },
    );

    test('when creating two users then their ids differ', () async {
      final a = await createTestUser(sessionBuilder);
      final b = await createTestUser(sessionBuilder);

      expect(a.authUserId, isNot(b.authUserId));
    });
  });
}
