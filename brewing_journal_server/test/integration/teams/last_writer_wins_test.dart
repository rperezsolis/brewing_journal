import 'package:test/test.dart';

import '../helpers/recipe_fixtures.dart';
import '../helpers/team_fixtures.dart';
import '../helpers/test_users.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod(
    'Given two members saving a new version of the same team recipe',
    (sessionBuilder, endpoints) {
      test(
        'when they save in sequence then each save is a new recipe',
        () async {
          final owner = await createTestUser(sessionBuilder);
          final editor = await createTestUser(sessionBuilder);
          final team = await createTeam(endpoints, owner);
          await inviteMember(endpoints, owner, editor, team.team.id!);
          final recipe = await createTeamRecipe(
            endpoints,
            owner,
            team.team.id!,
            instructions: ['start'],
          );

          final editors = await endpoints.recipe.save(
            editor.sessionBuilder,
            sampleDraft(
              recipe.recipe.ingredientId,
              instructions: ['a', 'b'],
            ).copyWith(id: recipe.recipe.id, title: recipe.recipe.title),
          );
          await Future<void>.delayed(const Duration(milliseconds: 20));
          final owners = await endpoints.recipe.save(
            owner.sessionBuilder,
            sampleDraft(
              recipe.recipe.ingredientId,
              instructions: ['c'],
            ).copyWith(id: recipe.recipe.id, title: recipe.recipe.title),
          );

          expect(editors.recipe.id, isNot(recipe.recipe.id));
          expect(owners.recipe.id, isNot(recipe.recipe.id));
          expect(editors.recipe.id, isNot(owners.recipe.id));
          expect(editors.recipe.ownerId, editor.authUserId);
          expect(owners.recipe.ownerId, owner.authUserId);
          expect(editors.recipe.teamId, team.team.id);
          expect(owners.recipe.teamId, team.team.id);

          final source = await endpoints.recipe.get(
            owner.sessionBuilder,
            recipe.recipe.id!,
          );
          expect(source.instructions.map((i) => i.text), ['start']);

          final listed = await endpoints.recipe.listForTeam(
            owner.sessionBuilder,
            team.team.id!,
            10,
            0,
          );
          expect(listed.map((r) => r.id), [
            owners.recipe.id,
            editors.recipe.id,
            recipe.recipe.id,
          ]);
        },
      );
    },
  );
}
