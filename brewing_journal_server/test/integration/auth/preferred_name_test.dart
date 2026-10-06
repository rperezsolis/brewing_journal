import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import '../helpers/test_users.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given UserProfileEditEndpoint.changeUserName', (
    sessionBuilder,
    endpoints,
  ) {
    test('when called unauthenticated then it is rejected', () async {
      final unauthenticated = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.unauthenticated(),
      );

      await expectLater(
        endpoints.userProfileEdit.changeUserName(unauthenticated, 'Ada'),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });

    test('when the name is blank then it is rejected', () async {
      final user = await createTestUser(sessionBuilder);

      await expectLater(
        endpoints.userProfileEdit.changeUserName(user.sessionBuilder, '   '),
        throwsArgumentError,
      );
    });

    test(
      'when a preferred name is saved then it is stored as userName',
      () async {
        final user = await createTestUser(sessionBuilder);
        await UserProfile.db.insertRow(
          sessionBuilder.build(),
          UserProfile(
            authUserId: user.authUserId,
            email: 'ada@example.com',
          ),
        );

        final profile = await endpoints.userProfileEdit.changeUserName(
          user.sessionBuilder,
          '  Ada  ',
        );

        expect(profile.userName, 'Ada');
        expect(profile.fullName, isNull);

        final stored = await UserProfile.db.findFirstRow(
          sessionBuilder.build(),
          where: (t) => t.authUserId.equals(user.authUserId),
        );
        expect(stored?.userName, 'Ada');
        expect(stored?.fullName, isNull);
      },
    );
  });
}
