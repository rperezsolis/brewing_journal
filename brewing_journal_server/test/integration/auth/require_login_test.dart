import 'package:test/test.dart';

import '../helpers/test_users.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given a domain endpoint that requires login', (
    sessionBuilder,
    endpoints,
  ) {
    test('when called unauthenticated then it is rejected', () async {
      final unauthenticated = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.unauthenticated(),
      );

      await expectLater(
        endpoints.recipe.listMine(unauthenticated, 10, 0),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });

    test('when called as a signed-in user then it succeeds', () async {
      final user = await createTestUser(sessionBuilder);

      final recipes = await endpoints.recipe.listMine(
        user.sessionBuilder,
        10,
        0,
      );
      expect(recipes, isEmpty);
    });
  });
}
