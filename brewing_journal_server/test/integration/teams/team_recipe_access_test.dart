import 'package:brewing_journal_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import '../helpers/recipe_fixtures.dart';
import '../helpers/team_fixtures.dart';
import '../helpers/test_users.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given a team recipe', (sessionBuilder, endpoints) {
    late TestUser owner;
    late TestUser editor;
    late TestUser viewer;
    late TestUser stranger;
    late RecipeDetail recipe;

    setUp(() async {
      owner = await createTestUser(sessionBuilder);
      editor = await createTestUser(sessionBuilder);
      viewer = await createTestUser(sessionBuilder);
      stranger = await createTestUser(sessionBuilder);
      final team = await createTeam(endpoints, owner);
      await inviteMember(endpoints, owner, editor, team.team.id!);
      await inviteMember(
        endpoints,
        owner,
        viewer,
        team.team.id!,
        role: TeamRole.viewer,
      );
      recipe = await createTeamRecipe(
        endpoints,
        owner,
        team.team.id!,
        instructions: ['bloom', 'pour'],
      );
    });

    test('when an editor gets then they can read and edit', () async {
      final detail = await endpoints.recipe.get(
        editor.sessionBuilder,
        recipe.recipe.id!,
      );
      expect(detail.instructions.map((i) => i.text), ['bloom', 'pour']);
      expect(detail.access.canEdit, isTrue);
      expect(detail.access.canDelete, isFalse);
      expect(detail.access.role, TeamRole.editor);
    });

    test(
      'when an editor saves then instructions are replaced in full',
      () async {
        final updated = await endpoints.recipe.save(
          editor.sessionBuilder,
          sampleDraft(
            recipe.recipe.ingredientId,
            instructions: ['stir'],
          ).copyWith(id: recipe.recipe.id, title: recipe.recipe.title),
        );
        expect(updated.instructions.map((i) => i.text), ['stir']);
      },
    );

    test('when a viewer gets then they can read but not write', () async {
      final detail = await endpoints.recipe.get(
        viewer.sessionBuilder,
        recipe.recipe.id!,
      );
      expect(detail.access.canEdit, isFalse);
      expect(detail.access.canDelete, isFalse);
      expect(detail.access.role, TeamRole.viewer);

      await expectLater(
        endpoints.recipe.save(
          viewer.sessionBuilder,
          sampleDraft(
            recipe.recipe.ingredientId,
            instructions: ['nope'],
          ).copyWith(id: recipe.recipe.id),
        ),
        throwsBrewing(BrewingErrorCode.forbidden),
      );
      await expectLater(
        endpoints.recipeMedia.createUploadDescription(
          viewer.sessionBuilder,
          recipe.recipe.id!,
        ),
        throwsBrewing(BrewingErrorCode.forbidden),
      );
    });

    test('when an editor deletes then forbidden', () async {
      await expectLater(
        endpoints.recipe.delete(editor.sessionBuilder, recipe.recipe.id!),
        throwsBrewing(BrewingErrorCode.forbidden),
      );
    });

    test('when a stranger gets then notFound', () async {
      await expectLater(
        endpoints.recipe.get(stranger.sessionBuilder, recipe.recipe.id!),
        throwsBrewing(BrewingErrorCode.notFound),
      );
    });
  });
}
