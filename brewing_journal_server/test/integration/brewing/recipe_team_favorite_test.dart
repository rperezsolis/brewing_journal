import 'package:brewing_journal_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import '../helpers/recipe_fixtures.dart';
import '../helpers/team_fixtures.dart';
import '../helpers/test_users.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given team favorites', (sessionBuilder, endpoints) {
    late TestUser owner;

    setUp(() async {
      owner = await createTestUser(sessionBuilder);
    });

    test(
      'when an editor saves a team favorite then every member sees it',
      () async {
        final viewer = await createTestUser(sessionBuilder);
        final team = await createTeam(endpoints, owner);
        await inviteMember(
          endpoints,
          owner,
          viewer,
          team.team.id!,
          role: TeamRole.viewer,
        );
        final recipe = await createTeamRecipe(
          endpoints,
          owner,
          team.team.id!,
          title: 'Shop V60',
        );

        final saved = await endpoints.recipe.saveTeamFavorite(
          owner.sessionBuilder,
          team.team.id!,
          recipe.recipe.id!,
          false,
        );

        expect(saved.saved, isTrue);
        final editorList = await endpoints.recipe.listForTeam(
          owner.sessionBuilder,
          team.team.id!,
          10,
          0,
        );
        final viewerList = await endpoints.recipe.listForTeam(
          viewer.sessionBuilder,
          team.team.id!,
          10,
          0,
        );
        expect(editorList.single.isFavorite, isTrue);
        expect(viewerList.single.isFavorite, isTrue);
        final viewerHome = await endpoints.recipe.listFavorites(
          viewer.sessionBuilder,
          10,
          0,
        );
        expect(viewerHome, isEmpty);
      },
    );

    test(
      'when a personal favorite is saved then the team heart stays empty',
      () async {
        final team = await createTeam(endpoints, owner);
        final recipe = await createTeamRecipe(
          endpoints,
          owner,
          team.team.id!,
          title: 'Shop V60',
        );
        await endpoints.recipe.saveFavorite(
          owner.sessionBuilder,
          recipe.recipe.id!,
          false,
        );

        final mine = await endpoints.recipe.listMine(
          owner.sessionBuilder,
          10,
          0,
        );
        final teamList = await endpoints.recipe.listForTeam(
          owner.sessionBuilder,
          team.team.id!,
          10,
          0,
        );
        expect(mine.single.isFavorite, isTrue);
        expect(teamList.single.isFavorite, isFalse);
        final home = await endpoints.recipe.listFavorites(
          owner.sessionBuilder,
          10,
          0,
        );
        expect(home.single.id, recipe.recipe.id);
      },
    );

    test(
      'when another recipe has the same name then replace is required',
      () async {
        final team = await createTeam(endpoints, owner);
        final first = await createTeamRecipe(
          endpoints,
          owner,
          team.team.id!,
          title: 'V60',
        );
        final second = await createTeamRecipe(
          endpoints,
          owner,
          team.team.id!,
          title: '  v60 ',
        );
        await endpoints.recipe.saveTeamFavorite(
          owner.sessionBuilder,
          team.team.id!,
          first.recipe.id!,
          false,
        );

        final blocked = await endpoints.recipe.saveTeamFavorite(
          owner.sessionBuilder,
          team.team.id!,
          second.recipe.id!,
          false,
        );
        expect(blocked.saved, isFalse);

        final replaced = await endpoints.recipe.saveTeamFavorite(
          owner.sessionBuilder,
          team.team.id!,
          second.recipe.id!,
          true,
        );
        expect(replaced.saved, isTrue);
        expect(replaced.replacedRecipeId, first.recipe.id);
        final favorites = await endpoints.recipe.listTeamFavorites(
          owner.sessionBuilder,
          team.team.id!,
          10,
          0,
        );
        expect(favorites.single.id, second.recipe.id);
      },
    );

    test(
      'when titles or teams differ then each favorite is kept',
      () async {
        final editor = await createTestUser(sessionBuilder);
        final otherOwner = await createTestUser(sessionBuilder);
        final team = await createTeam(endpoints, owner);
        final otherTeam = await createTeam(endpoints, otherOwner, name: 'Bar');
        await inviteMember(
          endpoints,
          owner,
          editor,
          team.team.id!,
        );
        final v60 = await createTeamRecipe(
          endpoints,
          owner,
          team.team.id!,
          title: 'V60',
        );
        final aeropress = await createTeamRecipe(
          endpoints,
          owner,
          team.team.id!,
          title: 'Aeropress',
        );
        final other = await createTeamRecipe(
          endpoints,
          otherOwner,
          otherTeam.team.id!,
          title: 'V60',
        );
        await endpoints.recipe.saveTeamFavorite(
          owner.sessionBuilder,
          team.team.id!,
          v60.recipe.id!,
          false,
        );
        await endpoints.recipe.saveTeamFavorite(
          owner.sessionBuilder,
          team.team.id!,
          aeropress.recipe.id!,
          false,
        );
        await endpoints.recipe.saveTeamFavorite(
          otherOwner.sessionBuilder,
          otherTeam.team.id!,
          other.recipe.id!,
          false,
        );
        await endpoints.recipe.saveFavorite(
          owner.sessionBuilder,
          v60.recipe.id!,
          false,
        );
        final editorRecipe = await createRecipe(
          endpoints,
          editor,
          title: 'V60',
        );
        await endpoints.recipe.saveFavorite(
          editor.sessionBuilder,
          editorRecipe.recipe.id!,
          false,
        );

        final teamFavorites = await endpoints.recipe.listTeamFavorites(
          owner.sessionBuilder,
          team.team.id!,
          10,
          0,
        );
        expect(teamFavorites.map((recipe) => recipe.id).toSet(), {
          v60.recipe.id,
          aeropress.recipe.id,
        });
        final otherFavorites = await endpoints.recipe.listTeamFavorites(
          otherOwner.sessionBuilder,
          otherTeam.team.id!,
          10,
          0,
        );
        expect(otherFavorites.single.id, other.recipe.id);
        final ownerPersonal = await endpoints.recipe.get(
          owner.sessionBuilder,
          v60.recipe.id!,
        );
        final editorPersonal = await endpoints.recipe.get(
          editor.sessionBuilder,
          editorRecipe.recipe.id!,
        );
        expect(ownerPersonal.recipe.isFavorite, isTrue);
        expect(editorPersonal.recipe.isFavorite, isTrue);
      },
    );

    test('when removed then every member sees an empty heart', () async {
      final viewer = await createTestUser(sessionBuilder);
      final team = await createTeam(endpoints, owner);
      await inviteMember(
        endpoints,
        owner,
        viewer,
        team.team.id!,
        role: TeamRole.viewer,
      );
      final recipe = await createTeamRecipe(
        endpoints,
        owner,
        team.team.id!,
        title: 'V60',
      );
      await endpoints.recipe.saveTeamFavorite(
        owner.sessionBuilder,
        team.team.id!,
        recipe.recipe.id!,
        false,
      );

      await endpoints.recipe.removeTeamFavorite(
        owner.sessionBuilder,
        team.team.id!,
        recipe.recipe.id!,
      );
      await endpoints.recipe.removeTeamFavorite(
        owner.sessionBuilder,
        team.team.id!,
        recipe.recipe.id!,
      );

      final editorList = await endpoints.recipe.listForTeam(
        owner.sessionBuilder,
        team.team.id!,
        10,
        0,
      );
      final viewerList = await endpoints.recipe.listForTeam(
        viewer.sessionBuilder,
        team.team.id!,
        10,
        0,
      );
      expect(editorList.single.isFavorite, isFalse);
      expect(viewerList.single.isFavorite, isFalse);
    });

    test(
      'when the caller is a viewer then team favorite writes are forbidden',
      () async {
        final viewer = await createTestUser(sessionBuilder);
        final team = await createTeam(endpoints, owner);
        await inviteMember(
          endpoints,
          owner,
          viewer,
          team.team.id!,
          role: TeamRole.viewer,
        );
        final recipe = await createTeamRecipe(
          endpoints,
          owner,
          team.team.id!,
          title: 'V60',
        );
        await endpoints.recipe.saveTeamFavorite(
          owner.sessionBuilder,
          team.team.id!,
          recipe.recipe.id!,
          false,
        );

        await expectLater(
          endpoints.recipe.saveTeamFavorite(
            viewer.sessionBuilder,
            team.team.id!,
            recipe.recipe.id!,
            false,
          ),
          throwsBrewing(BrewingErrorCode.forbidden),
        );
        await expectLater(
          endpoints.recipe.removeTeamFavorite(
            viewer.sessionBuilder,
            team.team.id!,
            recipe.recipe.id!,
          ),
          throwsBrewing(BrewingErrorCode.forbidden),
        );

        final membership = await TeamMembership.db.findFirstRow(
          sessionBuilder.build(),
          where: (t) =>
              t.teamId.equals(team.team.id!) &
              t.memberId.equals(owner.authUserId),
        );
        await TeamMembership.db.updateRow(
          sessionBuilder.build(),
          membership!.copyWith(role: TeamRole.viewer),
        );
        final access = await endpoints.recipe.getAccess(
          owner.sessionBuilder,
          recipe.recipe.id!,
        );
        expect(access.canEdit, isTrue);
        expect(access.role, TeamRole.viewer);
        await expectLater(
          endpoints.recipe.saveTeamFavorite(
            owner.sessionBuilder,
            team.team.id!,
            recipe.recipe.id!,
            false,
          ),
          throwsBrewing(BrewingErrorCode.forbidden),
        );

        await endpoints.recipe.removeFromTeam(
          owner.sessionBuilder,
          recipe.recipe.id!,
        );
        final favorites = await endpoints.recipe.listTeamFavorites(
          viewer.sessionBuilder,
          team.team.id!,
          10,
          0,
        );
        expect(favorites, isEmpty);
      },
    );

    test(
      'when the recipe is outside the team then save throws notFound',
      () async {
        final stranger = await createTestUser(sessionBuilder);
        final team = await createTeam(endpoints, owner);
        final other = await createTeam(endpoints, stranger, name: 'Other');
        final personal = await createRecipe(endpoints, owner, title: 'Home');
        final elsewhere = await createTeamRecipe(
          endpoints,
          stranger,
          other.team.id!,
          title: 'Theirs',
        );

        await expectLater(
          endpoints.recipe.saveTeamFavorite(
            stranger.sessionBuilder,
            team.team.id!,
            personal.recipe.id!,
            false,
          ),
          throwsBrewing(BrewingErrorCode.notFound),
        );
        await expectLater(
          endpoints.recipe.saveTeamFavorite(
            owner.sessionBuilder,
            team.team.id!,
            elsewhere.recipe.id!,
            false,
          ),
          throwsBrewing(BrewingErrorCode.notFound),
        );
        await expectLater(
          endpoints.recipe.saveTeamFavorite(
            owner.sessionBuilder,
            team.team.id!,
            personal.recipe.id!,
            false,
          ),
          throwsBrewing(BrewingErrorCode.notFound),
        );
        await expectLater(
          endpoints.recipe.listTeamFavorites(
            stranger.sessionBuilder,
            team.team.id!,
            10,
            0,
          ),
          throwsBrewing(BrewingErrorCode.notFound),
        );
      },
    );

    test(
      'when a recipe leaves the team then only the team favorite is dropped',
      () async {
        final team = await createTeam(endpoints, owner);
        final recipe = await createRecipe(endpoints, owner, title: 'House');
        await endpoints.recipe.saveFavorite(
          owner.sessionBuilder,
          recipe.recipe.id!,
          false,
        );
        await endpoints.recipe.assignToTeam(
          owner.sessionBuilder,
          recipe.recipe.id!,
          team.team.id!,
        );
        final onTeam = await endpoints.recipe.listForTeam(
          owner.sessionBuilder,
          team.team.id!,
          10,
          0,
        );
        expect(onTeam.single.isFavorite, isFalse);
        final stillPersonal = await endpoints.recipe.listMine(
          owner.sessionBuilder,
          10,
          0,
        );
        expect(stillPersonal.single.isFavorite, isTrue);

        await endpoints.recipe.saveTeamFavorite(
          owner.sessionBuilder,
          team.team.id!,
          recipe.recipe.id!,
          false,
        );
        await endpoints.recipe.removeFromTeam(
          owner.sessionBuilder,
          recipe.recipe.id!,
        );
        final teamFavorites = await endpoints.recipe.listTeamFavorites(
          owner.sessionBuilder,
          team.team.id!,
          10,
          0,
        );
        expect(teamFavorites, isEmpty);
        final personal = await endpoints.recipe.listFavorites(
          owner.sessionBuilder,
          10,
          0,
        );
        expect(personal.single.id, recipe.recipe.id);
        expect(personal.single.isFavorite, isTrue);
      },
    );

    test(
      'when a new version is saved then the source stays the team favorite',
      () async {
        final team = await createTeam(endpoints, owner);
        final source = await createTeamRecipe(
          endpoints,
          owner,
          team.team.id!,
          title: 'V60',
        );
        await endpoints.recipe.saveTeamFavorite(
          owner.sessionBuilder,
          team.team.id!,
          source.recipe.id!,
          false,
        );

        final version = await endpoints.recipe.save(
          owner.sessionBuilder,
          sampleDraft(source.ingredient.id!).copyWith(
            id: source.recipe.id,
            title: 'V60',
          ),
        );
        final listed = await endpoints.recipe.listForTeam(
          owner.sessionBuilder,
          team.team.id!,
          10,
          0,
        );
        final byId = {for (final row in listed) row.id: row.isFavorite};
        expect(byId[source.recipe.id], isTrue);
        expect(byId[version.recipe.id], isFalse);

        final blocked = await endpoints.recipe.saveTeamFavorite(
          owner.sessionBuilder,
          team.team.id!,
          version.recipe.id!,
          false,
        );
        expect(blocked.saved, isFalse);
        final replaced = await endpoints.recipe.saveTeamFavorite(
          owner.sessionBuilder,
          team.team.id!,
          version.recipe.id!,
          true,
        );
        expect(replaced.saved, isTrue);
        expect(replaced.replacedRecipeId, source.recipe.id);
      },
    );

    test(
      'when the team is deleted then team favorites go and personal ones stay',
      () async {
        final team = await createTeam(endpoints, owner);
        final recipe = await createTeamRecipe(
          endpoints,
          owner,
          team.team.id!,
          title: 'V60',
        );
        await endpoints.recipe.saveFavorite(
          owner.sessionBuilder,
          recipe.recipe.id!,
          false,
        );
        await endpoints.recipe.saveTeamFavorite(
          owner.sessionBuilder,
          team.team.id!,
          recipe.recipe.id!,
          false,
        );

        await Team.db.deleteRow(sessionBuilder.build(), team.team);

        final stored = await Recipe.db.findById(
          sessionBuilder.build(),
          recipe.recipe.id!,
        );
        expect(stored!.teamId, isNull);
        final marks = await TeamRecipeFavorite.db.find(sessionBuilder.build());
        expect(marks, isEmpty);
        final personal = await endpoints.recipe.get(
          owner.sessionBuilder,
          recipe.recipe.id!,
        );
        expect(personal.recipe.isFavorite, isTrue);
      },
    );

    test('when paging team favorites then limit and offset apply', () async {
      final team = await createTeam(endpoints, owner);
      for (final title in ['first', 'second', 'third']) {
        final recipe = await createTeamRecipe(
          endpoints,
          owner,
          team.team.id!,
          title: title,
        );
        await endpoints.recipe.saveTeamFavorite(
          owner.sessionBuilder,
          team.team.id!,
          recipe.recipe.id!,
          false,
        );
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }

      final page = await endpoints.recipe.listTeamFavorites(
        owner.sessionBuilder,
        team.team.id!,
        2,
        0,
      );
      final rest = await endpoints.recipe.listTeamFavorites(
        owner.sessionBuilder,
        team.team.id!,
        2,
        2,
      );
      expect(page.map((recipe) => recipe.title), ['third', 'second']);
      expect(rest.map((recipe) => recipe.title), ['first']);
    });

    test(
      'when get is scoped to the team then it reports the team flag',
      () async {
        final team = await createTeam(endpoints, owner);
        final recipe = await createTeamRecipe(
          endpoints,
          owner,
          team.team.id!,
          title: 'V60',
        );
        await endpoints.recipe.saveFavorite(
          owner.sessionBuilder,
          recipe.recipe.id!,
          false,
        );

        final personal = await endpoints.recipe.get(
          owner.sessionBuilder,
          recipe.recipe.id!,
        );
        final teamRead = await endpoints.recipe.get(
          owner.sessionBuilder,
          recipe.recipe.id!,
          teamId: team.team.id!,
        );
        expect(personal.recipe.isFavorite, isTrue);
        expect(teamRead.recipe.isFavorite, isFalse);

        await endpoints.recipe.saveTeamFavorite(
          owner.sessionBuilder,
          team.team.id!,
          recipe.recipe.id!,
          false,
        );
        final teamStarred = await endpoints.recipe.get(
          owner.sessionBuilder,
          recipe.recipe.id!,
          teamId: team.team.id!,
        );
        final stillPersonal = await endpoints.recipe.get(
          owner.sessionBuilder,
          recipe.recipe.id!,
        );
        expect(teamStarred.recipe.isFavorite, isTrue);
        expect(stillPersonal.recipe.isFavorite, isTrue);
      },
    );
  });
}
