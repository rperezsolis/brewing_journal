import 'package:test/test.dart';

import '../helpers/recipe_fixtures.dart';
import '../helpers/team_fixtures.dart';
import '../helpers/test_users.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod(
    'Given two members saving the same team recipe',
    (sessionBuilder, endpoints) {
      test(
        'when they save in sequence then get returns the last writer\'s list',
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

          await endpoints.recipe.save(
            editor.sessionBuilder,
            sampleDraft(
              recipe.recipe.ingredientId,
              instructions: ['a', 'b'],
            ).copyWith(id: recipe.recipe.id, title: recipe.recipe.title),
          );
          await endpoints.recipe.save(
            owner.sessionBuilder,
            sampleDraft(
              recipe.recipe.ingredientId,
              instructions: ['c'],
            ).copyWith(id: recipe.recipe.id, title: recipe.recipe.title),
          );

          final detail = await endpoints.recipe.get(
            owner.sessionBuilder,
            recipe.recipe.id!,
          );
          expect(detail.instructions.map((i) => i.text), ['c']);
        },
      );
    },
  );
}
