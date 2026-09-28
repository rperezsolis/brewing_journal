import 'package:brewing_journal_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import '../helpers/recipe_fixtures.dart';
import '../helpers/team_fixtures.dart';
import '../helpers/test_users.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given TeamEndpoint', (sessionBuilder, endpoints) {
    late TestUser owner;

    setUp(() async {
      owner = await createTestUser(sessionBuilder);
    });

    test(
      'when creating a team then the creator has an editor membership',
      () async {
        final summary = await createTeam(endpoints, owner);

        expect(summary.team.name, 'Shop Recipes');
        expect(summary.team.ownerId, owner.authUserId);
        expect(summary.role, TeamRole.editor);

        final session = sessionBuilder.build();
        final memberships = await TeamMembership.db.find(
          session,
          where: (t) => t.teamId.equals(summary.team.id!),
        );
        expect(memberships, hasLength(1));
        expect(memberships.single.memberId, owner.authUserId);
        expect(memberships.single.role, TeamRole.editor);
      },
    );

    test(
      'when listing teams then only the caller\'s teams are returned',
      () async {
        final other = await createTestUser(sessionBuilder);
        await createTeam(endpoints, owner, name: 'Mine');
        await createTeam(endpoints, other, name: 'Theirs');

        final mine = await endpoints.team.listMine(owner.sessionBuilder);
        expect(mine.map((s) => s.team.name), ['Mine']);
        expect(mine.single.role, TeamRole.editor);
      },
    );

    test('when an editor creates an invite then forbidden', () async {
      final editor = await createTestUser(sessionBuilder);
      final team = await createTeam(endpoints, owner);
      await inviteMember(endpoints, owner, editor, team.team.id!);

      await expectLater(
        endpoints.team.createInvite(
          editor.sessionBuilder,
          team.team.id!,
          TeamRole.viewer,
          const Duration(hours: 1),
        ),
        throwsBrewing(BrewingErrorCode.forbidden),
      );
    });

    test('when a stranger creates an invite then notFound', () async {
      final stranger = await createTestUser(sessionBuilder);
      final team = await createTeam(endpoints, owner);

      await expectLater(
        endpoints.team.createInvite(
          stranger.sessionBuilder,
          team.team.id!,
          TeamRole.viewer,
          const Duration(hours: 1),
        ),
        throwsBrewing(BrewingErrorCode.notFound),
      );
    });

    test('when ttl is below 15 minutes then it is clamped', () async {
      final invite = await endpoints.team.createInvite(
        owner.sessionBuilder,
        (await createTeam(endpoints, owner)).team.id!,
        TeamRole.viewer,
        const Duration(minutes: 1),
      );

      final ttl = invite.expiresAt.difference(DateTime.now().toUtc());
      expect(ttl.inMinutes, greaterThanOrEqualTo(14));
      expect(ttl.inMinutes, lessThanOrEqualTo(16));
    });

    test('when ttl is above 7 days then it is clamped', () async {
      final invite = await endpoints.team.createInvite(
        owner.sessionBuilder,
        (await createTeam(endpoints, owner)).team.id!,
        TeamRole.editor,
        const Duration(days: 30),
      );

      final ttl = invite.expiresAt.difference(DateTime.now().toUtc());
      expect(ttl.inDays, lessThanOrEqualTo(7));
      expect(ttl.inHours, greaterThanOrEqualTo(7 * 24 - 1));
    });

    test('when name is blank then validation', () async {
      await expectLater(
        endpoints.team.create(owner.sessionBuilder, '   '),
        throwsBrewing(BrewingErrorCode.validation),
      );
    });
  });
}
