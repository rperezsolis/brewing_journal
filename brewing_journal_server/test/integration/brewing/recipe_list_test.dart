import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import '../helpers/recipe_fixtures.dart';
import '../helpers/team_fixtures.dart';
import '../helpers/test_users.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given RecipeEndpoint.listMine', (sessionBuilder, endpoints) {
    late TestUser a;

    setUp(() async {
      a = await createTestUser(sessionBuilder);
      for (final title in ['first', 'second', 'third']) {
        await createRecipe(endpoints, a, title: title);
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
    });

    test('when listing then the newest updatedAt comes first', () async {
      final recipes = await endpoints.recipe.listMine(a.sessionBuilder, 10, 0);
      expect(recipes.map((r) => r.title), ['third', 'second', 'first']);
    });

    test('when paging then limit and offset apply', () async {
      final first = await endpoints.recipe.listMine(a.sessionBuilder, 2, 0);
      final second = await endpoints.recipe.listMine(a.sessionBuilder, 2, 2);

      expect(first.map((r) => r.title), ['third', 'second']);
      expect(second.map((r) => r.title), ['first']);
    });

    test(
      'when the owner has a profile then each recipe shows that name',
      () async {
        await UserProfile.db.insertRow(
          sessionBuilder.build(),
          UserProfile(
            authUserId: a.authUserId,
            userName: 'ada',
            fullName: 'Ada Lovelace',
            email: 'ada@example.com',
          ),
        );
        final recipes = await endpoints.recipe.listMine(
          a.sessionBuilder,
          10,
          0,
        );
        expect(
          recipes.map((r) => r.authorName),
          everyElement('Ada Lovelace'),
        );
      },
    );

    test(
      'when the profile has only an email then that email is the author',
      () async {
        final b = await createTestUser(sessionBuilder);
        await UserProfile.db.insertRow(
          sessionBuilder.build(),
          UserProfile(authUserId: b.authUserId, email: 'brew@example.com'),
        );
        await createRecipe(endpoints, b, title: 'theirs');

        final recipes = await endpoints.recipe.listMine(
          b.sessionBuilder,
          10,
          0,
        );
        expect(recipes.single.authorName, 'brew@example.com');
      },
    );

    test('when user B has recipes then they are never listed', () async {
      final b = await createTestUser(sessionBuilder);
      await createRecipe(endpoints, b, title: 'not mine');

      final recipes = await endpoints.recipe.listMine(a.sessionBuilder, 50, 0);
      expect(recipes.map((r) => r.title), isNot(contains('not mine')));
      expect(recipes, hasLength(3));
    });
  });

  withServerpod(
    'Given RecipeEndpoint.listForTeam',
    (sessionBuilder, endpoints) {
      test('when listing then the newest updatedAt comes first', () async {
        final owner = await createTestUser(sessionBuilder);
        final team = await createTeam(endpoints, owner);
        for (final title in ['first', 'second', 'third']) {
          await createTeamRecipe(
            endpoints,
            owner,
            team.team.id!,
            title: title,
          );
          await Future<void>.delayed(const Duration(milliseconds: 5));
        }

        final recipes = await endpoints.recipe.listForTeam(
          owner.sessionBuilder,
          team.team.id!,
          10,
          0,
        );
        expect(recipes.map((r) => r.title), ['third', 'second', 'first']);
      });
    },
  );
}
