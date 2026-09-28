import 'package:brewing_journal_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import '../helpers/recipe_fixtures.dart';
import '../helpers/team_fixtures.dart';
import '../helpers/test_users.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given TeamEndpoint.acceptInvite', (sessionBuilder, endpoints) {
    late TestUser owner;
    late TeamSummary team;

    setUp(() async {
      owner = await createTestUser(sessionBuilder);
      team = await createTeam(endpoints, owner);
    });

    test(
      'when accepting then a membership is created with the invite role',
      () async {
        final editor = await createTestUser(sessionBuilder);
        final invite = await endpoints.team.createInvite(
          owner.sessionBuilder,
          team.team.id!,
          TeamRole.editor,
          const Duration(hours: 1),
        );

        final joined = await endpoints.team.acceptInvite(
          editor.sessionBuilder,
          invite.token,
        );

        expect(joined.team.id, team.team.id);
        expect(joined.role, TeamRole.editor);
        expect(invite.url, contains('/invite/${invite.token}'));
      },
    );

    test(
      'when a second user accepts the same token then inviteUsed',
      () async {
        final first = await createTestUser(sessionBuilder);
        final second = await createTestUser(sessionBuilder);
        final invite = await endpoints.team.createInvite(
          owner.sessionBuilder,
          team.team.id!,
          TeamRole.viewer,
          const Duration(hours: 1),
        );
        await endpoints.team.acceptInvite(first.sessionBuilder, invite.token);

        await expectLater(
          endpoints.team.acceptInvite(second.sessionBuilder, invite.token),
          throwsBrewing(BrewingErrorCode.inviteUsed),
        );
        expect(
          await TeamMembership.db.find(
            sessionBuilder.build(),
            where: (t) =>
                t.teamId.equals(team.team.id!) &
                t.memberId.equals(second.authUserId),
          ),
          isEmpty,
        );
      },
    );

    test(
      'when the token is expired then inviteExpired and no membership',
      () async {
        final viewer = await createTestUser(sessionBuilder);
        await TeamInvite.db.insertRow(
          sessionBuilder.build(),
          TeamInvite(
            teamId: team.team.id!,
            createdById: owner.authUserId,
            token: 'expired-token',
            role: TeamRole.viewer,
            expiresAt: DateTime.now().toUtc().subtract(
              const Duration(minutes: 1),
            ),
          ),
        );

        await expectLater(
          endpoints.team.acceptInvite(viewer.sessionBuilder, 'expired-token'),
          throwsBrewing(BrewingErrorCode.inviteExpired),
        );
        expect(
          await TeamMembership.db.find(
            sessionBuilder.build(),
            where: (t) =>
                t.teamId.equals(team.team.id!) &
                t.memberId.equals(viewer.authUserId),
          ),
          isEmpty,
        );
      },
    );

    test(
      'when an existing editor opens a viewer link then alreadyMember, role kept, token unused',
      () async {
        final editor = await createTestUser(sessionBuilder);
        await inviteMember(
          endpoints,
          owner,
          editor,
          team.team.id!,
        );
        final viewerInvite = await endpoints.team.createInvite(
          owner.sessionBuilder,
          team.team.id!,
          TeamRole.viewer,
          const Duration(hours: 1),
        );

        await expectLater(
          endpoints.team.acceptInvite(
            editor.sessionBuilder,
            viewerInvite.token,
          ),
          throwsBrewing(BrewingErrorCode.alreadyMember),
        );

        final membership = await TeamMembership.db.findFirstRow(
          sessionBuilder.build(),
          where: (t) =>
              t.teamId.equals(team.team.id!) &
              t.memberId.equals(editor.authUserId),
        );
        expect(membership!.role, TeamRole.editor);

        final stored = await TeamInvite.db.findFirstRow(
          sessionBuilder.build(),
          where: (t) => t.token.equals(viewerInvite.token),
        );
        expect(stored!.usedAt, isNull);

        final stranger = await createTestUser(sessionBuilder);
        final joined = await endpoints.team.acceptInvite(
          stranger.sessionBuilder,
          viewerInvite.token,
        );
        expect(joined.role, TeamRole.viewer);
      },
    );

    test('when the token is unknown then notFound', () async {
      final stranger = await createTestUser(sessionBuilder);
      await expectLater(
        endpoints.team.acceptInvite(stranger.sessionBuilder, 'no-such-token'),
        throwsBrewing(BrewingErrorCode.notFound),
      );
    });
  });
}
