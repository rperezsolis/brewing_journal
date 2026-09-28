import 'package:brewing_journal_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import '../helpers/team_fixtures.dart';
import '../helpers/test_users.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod(
    'Given two concurrent acceptInvite calls on one token',
    (sessionBuilder, endpoints) {
      test('then exactly one membership is created', () async {
        final owner = await createTestUser(sessionBuilder);
        final a = await createTestUser(sessionBuilder);
        final b = await createTestUser(sessionBuilder);
        final team = await createTeam(endpoints, owner);
        final invite = await endpoints.team.createInvite(
          owner.sessionBuilder,
          team.team.id!,
          TeamRole.viewer,
          const Duration(hours: 1),
        );

        final results = await Future.wait<Object?>([
          endpoints.team
              .acceptInvite(a.sessionBuilder, invite.token)
              .then<Object?>((value) => value)
              .catchError((Object e) => e),
          endpoints.team
              .acceptInvite(b.sessionBuilder, invite.token)
              .then<Object?>((value) => value)
              .catchError((Object e) => e),
        ]);

        final successes = results.whereType<TeamSummary>();
        final failures = results.whereType<BrewingException>();
        expect(successes, hasLength(1));
        expect(failures, hasLength(1));
        expect(failures.single.code, BrewingErrorCode.inviteUsed);

        final memberships = await TeamMembership.db.find(
          sessionBuilder.build(),
          where: (t) =>
              t.teamId.equals(team.team.id!) &
              (t.memberId.equals(a.authUserId) |
                  t.memberId.equals(b.authUserId)),
        );
        expect(memberships, hasLength(1));
      });
    },
    rollbackDatabase: RollbackDatabase.disabled,
  );
}
