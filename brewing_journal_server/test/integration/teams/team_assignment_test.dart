import 'dart:typed_data';

import 'package:brewing_journal_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import '../helpers/recipe_fixtures.dart';
import '../helpers/team_fixtures.dart';
import '../helpers/test_users.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given RecipeEndpoint team assignment', (
    sessionBuilder,
    endpoints,
  ) {
    late TestUser owner;
    late TestUser editor;
    late TestUser viewer;
    late TestUser stranger;
    late TeamSummary team;
    late RecipeDetail personal;

    setUp(() async {
      owner = await createTestUser(sessionBuilder);
      editor = await createTestUser(sessionBuilder);
      viewer = await createTestUser(sessionBuilder);
      stranger = await createTestUser(sessionBuilder);
      team = await createTeam(endpoints, owner);
      await inviteMember(endpoints, owner, editor, team.team.id!);
      await inviteMember(
        endpoints,
        owner,
        viewer,
        team.team.id!,
        role: TeamRole.viewer,
      );
      personal = await createRecipe(endpoints, owner);
    });

    test('when the owner is an editor then assignToTeam succeeds', () async {
      final assigned = await endpoints.recipe.assignToTeam(
        owner.sessionBuilder,
        personal.recipe.id!,
        team.team.id!,
      );
      expect(assigned.teamId, team.team.id);
    });

    test(
      'when a viewer-member owner assigns then forbidden',
      () async {
        final viewerOwner = await createTestUser(sessionBuilder);
        final otherTeam = await createTeam(endpoints, owner, name: 'Other');
        await inviteMember(
          endpoints,
          owner,
          viewerOwner,
          otherTeam.team.id!,
          role: TeamRole.viewer,
        );
        final theirRecipe = await createRecipe(endpoints, viewerOwner);

        await expectLater(
          endpoints.recipe.assignToTeam(
            viewerOwner.sessionBuilder,
            theirRecipe.recipe.id!,
            otherTeam.team.id!,
          ),
          throwsBrewing(BrewingErrorCode.forbidden),
        );
      },
    );

    test('when a non-owner assigns then notFound', () async {
      await expectLater(
        endpoints.recipe.assignToTeam(
          editor.sessionBuilder,
          personal.recipe.id!,
          team.team.id!,
        ),
        throwsBrewing(BrewingErrorCode.notFound),
      );
    });

    test('when the owner removes from team then teamId is cleared', () async {
      await endpoints.recipe.assignToTeam(
        owner.sessionBuilder,
        personal.recipe.id!,
        team.team.id!,
      );
      final removed = await endpoints.recipe.removeFromTeam(
        owner.sessionBuilder,
        personal.recipe.id!,
      );
      expect(removed.teamId, isNull);
    });

    test(
      'when a team editor removes from team then teamId is cleared',
      () async {
        await endpoints.recipe.assignToTeam(
          owner.sessionBuilder,
          personal.recipe.id!,
          team.team.id!,
        );
        final removed = await endpoints.recipe.removeFromTeam(
          editor.sessionBuilder,
          personal.recipe.id!,
        );
        expect(removed.teamId, isNull);
      },
    );

    test('when a viewer removes from team then forbidden', () async {
      await endpoints.recipe.assignToTeam(
        owner.sessionBuilder,
        personal.recipe.id!,
        team.team.id!,
      );
      await expectLater(
        endpoints.recipe.removeFromTeam(
          viewer.sessionBuilder,
          personal.recipe.id!,
        ),
        throwsBrewing(BrewingErrorCode.forbidden),
      );
    });

    test('when a non-member lists the team then notFound', () async {
      await expectLater(
        endpoints.recipe.listForTeam(
          stranger.sessionBuilder,
          team.team.id!,
          20,
          0,
        ),
        throwsBrewing(BrewingErrorCode.notFound),
      );
    });

    test(
      'when a viewer inserts with a teamId then forbidden',
      () async {
        final bean = await registerIngredient(endpoints, viewer);
        await expectLater(
          endpoints.recipe.save(
            viewer.sessionBuilder,
            sampleDraft(bean.id!).copyWith(teamId: team.team.id),
          ),
          throwsBrewing(BrewingErrorCode.forbidden),
        );
      },
    );

    test(
      'when an editor updates with a different teamId then the stored teamId is kept',
      () async {
        final recipe = await createTeamRecipe(
          endpoints,
          owner,
          team.team.id!,
        );
        final other = await createTeam(endpoints, owner, name: 'Other shop');

        final updated = await endpoints.recipe.save(
          editor.sessionBuilder,
          sampleDraft(
            recipe.recipe.ingredientId,
          ).copyWith(id: recipe.recipe.id, teamId: other.team.id),
        );
        expect(updated.recipe.id, isNot(recipe.recipe.id));
        expect(updated.recipe.teamId, team.team.id);
        final source = await endpoints.recipe.get(
          owner.sessionBuilder,
          recipe.recipe.id!,
        );
        expect(source.recipe.teamId, team.team.id);
      },
    );

    test('when a viewer removes a photo then forbidden', () async {
      final recipe = await createTeamRecipe(
        endpoints,
        owner,
        team.team.id!,
      );
      final ticket = await endpoints.recipeMedia.createUploadDescription(
        owner.sessionBuilder,
        recipe.recipe.id!,
      );
      await sessionBuilder.build().storage.storeFile(
        storageId: 'public',
        path: ticket.path,
        byteData: ByteData.sublistView(
          Uint8List.fromList([0xFF, 0xD8, 1]),
        ),
      );
      final photo = await endpoints.recipeMedia.confirmUpload(
        owner.sessionBuilder,
        recipe.recipe.id!,
        ticket.path,
      );

      await expectLater(
        endpoints.recipeMedia.remove(viewer.sessionBuilder, photo.id!),
        throwsBrewing(BrewingErrorCode.forbidden),
      );
    });
  });
}
