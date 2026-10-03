import 'package:brewing_journal_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import '../helpers/recipe_fixtures.dart';
import '../helpers/team_fixtures.dart';
import '../helpers/test_users.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given RecipeEndpoint favorites', (sessionBuilder, endpoints) {
    late TestUser owner;

    setUp(() async {
      owner = await createTestUser(sessionBuilder);
    });

    test('when a recipe is saved then reads mark it as a favorite', () async {
      final recipe = await createRecipe(endpoints, owner, title: 'V60');
      final id = recipe.recipe.id!;

      final result = await endpoints.recipe.saveFavorite(
        owner.sessionBuilder,
        id,
        false,
      );

      expect(result.saved, isTrue);
      expect(result.replacedRecipeId, isNull);
      final loaded = await endpoints.recipe.get(owner.sessionBuilder, id);
      expect(loaded.recipe.isFavorite, isTrue);
      final listed = await endpoints.recipe.listMine(
        owner.sessionBuilder,
        10,
        0,
      );
      expect(listed.single.isFavorite, isTrue);
    });

    test(
      'when another recipe has the same name then save does not replace it',
      () async {
        final first = await createRecipe(endpoints, owner, title: 'V60');
        final second = await createRecipe(endpoints, owner, title: '  v60 ');
        await endpoints.recipe.saveFavorite(
          owner.sessionBuilder,
          first.recipe.id!,
          false,
        );

        final blocked = await endpoints.recipe.saveFavorite(
          owner.sessionBuilder,
          second.recipe.id!,
          false,
        );

        expect(blocked.saved, isFalse);
        expect(blocked.replacedRecipeId, isNull);
        final rows = await endpoints.recipe.listMine(
          owner.sessionBuilder,
          10,
          0,
        );
        final byId = {for (final row in rows) row.id: row.isFavorite};
        expect(byId[first.recipe.id], isTrue);
        expect(byId[second.recipe.id], isFalse);
      },
    );

    test('when replace is true then the new recipe is the favorite', () async {
      final first = await createRecipe(endpoints, owner, title: 'V60');
      final second = await createRecipe(endpoints, owner, title: 'V60');
      await endpoints.recipe.saveFavorite(
        owner.sessionBuilder,
        first.recipe.id!,
        false,
      );

      final replaced = await endpoints.recipe.saveFavorite(
        owner.sessionBuilder,
        second.recipe.id!,
        true,
      );

      expect(replaced.saved, isTrue);
      expect(replaced.replacedRecipeId, first.recipe.id);
      final favorites = await endpoints.recipe.listFavorites(
        owner.sessionBuilder,
        10,
        0,
      );
      expect(favorites.single.id, second.recipe.id);
      expect(favorites.single.isFavorite, isTrue);
    });

    test('when titles differ then both can be favorites', () async {
      final v60 = await createRecipe(endpoints, owner, title: 'V60');
      final aeropress = await createRecipe(
        endpoints,
        owner,
        title: 'Aeropress',
      );
      await endpoints.recipe.saveFavorite(
        owner.sessionBuilder,
        v60.recipe.id!,
        false,
      );
      final second = await endpoints.recipe.saveFavorite(
        owner.sessionBuilder,
        aeropress.recipe.id!,
        false,
      );

      expect(second.saved, isTrue);
      final favorites = await endpoints.recipe.listFavorites(
        owner.sessionBuilder,
        10,
        0,
      );
      expect(favorites.map((recipe) => recipe.title), [
        'Aeropress',
        'V60',
      ]);
    });

    test('when removed then the recipe is no longer a favorite', () async {
      final recipe = await createRecipe(endpoints, owner, title: 'V60');
      await endpoints.recipe.saveFavorite(
        owner.sessionBuilder,
        recipe.recipe.id!,
        false,
      );

      await endpoints.recipe.removeFavorite(
        owner.sessionBuilder,
        recipe.recipe.id!,
      );

      final loaded = await endpoints.recipe.get(
        owner.sessionBuilder,
        recipe.recipe.id!,
      );
      expect(loaded.recipe.isFavorite, isFalse);
      final favorites = await endpoints.recipe.listFavorites(
        owner.sessionBuilder,
        10,
        0,
      );
      expect(favorites, isEmpty);
    });

    test(
      'when another user favorites the same title then both are kept',
      () async {
        final other = await createTestUser(sessionBuilder);
        final mine = await createRecipe(endpoints, owner, title: 'V60');
        final theirs = await createRecipe(endpoints, other, title: 'V60');
        await endpoints.recipe.saveFavorite(
          owner.sessionBuilder,
          mine.recipe.id!,
          false,
        );

        final result = await endpoints.recipe.saveFavorite(
          other.sessionBuilder,
          theirs.recipe.id!,
          false,
        );

        expect(result.saved, isTrue);
        final mineListed = await endpoints.recipe.listFavorites(
          owner.sessionBuilder,
          10,
          0,
        );
        final theirsListed = await endpoints.recipe.listFavorites(
          other.sessionBuilder,
          10,
          0,
        );
        expect(mineListed.single.id, mine.recipe.id);
        expect(theirsListed.single.id, theirs.recipe.id);
      },
    );

    test('when the recipe is not readable then save throws notFound', () async {
      final other = await createTestUser(sessionBuilder);
      final recipe = await createRecipe(endpoints, owner, title: 'V60');

      await expectLater(
        endpoints.recipe.saveFavorite(
          other.sessionBuilder,
          recipe.recipe.id!,
          false,
        ),
        throwsBrewing(BrewingErrorCode.notFound),
      );
    });

    test(
      'when a team member favorites a shared recipe then only they see the flag',
      () async {
        final member = await createTestUser(sessionBuilder);
        final team = await createTeam(endpoints, owner);
        await inviteMember(
          endpoints,
          owner,
          member,
          team.team.id!,
          role: TeamRole.viewer,
        );
        final recipe = await createTeamRecipe(
          endpoints,
          owner,
          team.team.id!,
          title: 'Shop V60',
        );

        final saved = await endpoints.recipe.saveFavorite(
          member.sessionBuilder,
          recipe.recipe.id!,
          false,
        );

        expect(saved.saved, isTrue);
        final memberList = await endpoints.recipe.listForTeam(
          member.sessionBuilder,
          team.team.id!,
          10,
          0,
        );
        final ownerList = await endpoints.recipe.listForTeam(
          owner.sessionBuilder,
          team.team.id!,
          10,
          0,
        );
        expect(memberList.single.isFavorite, isTrue);
        expect(ownerList.single.isFavorite, isFalse);
        final memberHome = await endpoints.recipe.listFavorites(
          member.sessionBuilder,
          10,
          0,
        );
        expect(memberHome, isEmpty);
      },
    );

    test('when paging favorites then limit and offset apply', () async {
      for (final title in ['first', 'second', 'third']) {
        final recipe = await createRecipe(endpoints, owner, title: title);
        await endpoints.recipe.saveFavorite(
          owner.sessionBuilder,
          recipe.recipe.id!,
          false,
        );
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }

      final page = await endpoints.recipe.listFavorites(
        owner.sessionBuilder,
        2,
        0,
      );
      final rest = await endpoints.recipe.listFavorites(
        owner.sessionBuilder,
        2,
        2,
      );

      expect(page.map((recipe) => recipe.title), ['third', 'second']);
      expect(rest.map((recipe) => recipe.title), ['first']);
    });
  });
}
