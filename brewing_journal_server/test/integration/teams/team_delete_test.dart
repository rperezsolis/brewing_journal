import 'package:brewing_journal_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import '../helpers/team_fixtures.dart';
import '../helpers/test_users.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod(
    'Given a recipe on a team that is deleted',
    (sessionBuilder, endpoints) {
      test(
        'when the team row is deleted then teamId is nulled and the owner still reads it',
        () async {
          final owner = await createTestUser(sessionBuilder);
          final team = await createTeam(endpoints, owner);
          final recipe = await createTeamRecipe(
            endpoints,
            owner,
            team.team.id!,
          );

          await Team.db.deleteRow(sessionBuilder.build(), team.team);

          final stored = await Recipe.db.findById(
            sessionBuilder.build(),
            recipe.recipe.id!,
          );
          expect(stored!.teamId, isNull);

          final detail = await endpoints.recipe.get(
            owner.sessionBuilder,
            recipe.recipe.id!,
          );
          expect(detail.recipe.id, recipe.recipe.id);
          expect(detail.recipe.teamId, isNull);
          expect(detail.access.canEdit, isTrue);
          expect(detail.access.canDelete, isTrue);
        },
      );
    },
  );
}
