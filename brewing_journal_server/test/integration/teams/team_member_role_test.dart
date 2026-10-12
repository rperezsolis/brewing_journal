import 'package:brewing_journal_server/src/generated/protocol.dart';
import 'package:brewing_journal_server/src/teams/role_change_email.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import '../helpers/recipe_fixtures.dart';
import '../helpers/team_fixtures.dart';
import '../helpers/test_users.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given team member roles', (sessionBuilder, endpoints) {
    const viewerSentence =
        'Viewers cannot add recipes to the team, remove them, or mark them as favorites.';
    const editorSentence =
        'Editors can add recipes to the team, remove them, and mark them as favorites.';

    late TestUser owner;
    late TestUser member;

    setUp(() async {
      owner = await createTestUser(sessionBuilder);
      member = await createTestUser(sessionBuilder);
      await _profile(
        sessionBuilder,
        owner,
        name: 'Owner',
        email: 'owner@example.com',
      );
      await _profile(
        sessionBuilder,
        member,
        name: 'Ada',
        email: 'ada@example.com',
      );
    });

    test(
      'when a member lists the team then names and emails come back',
      () async {
        final team = await createTeam(endpoints, owner);
        await inviteMember(
          endpoints,
          owner,
          member,
          team.team.id!,
          role: TeamRole.viewer,
        );

        final listed = await endpoints.team.listMembers(
          member.sessionBuilder,
          team.team.id!,
        );

        expect(listed.map((item) => item.preferredName), ['Owner', 'Ada']);
        expect(listed.map((item) => item.email), [
          'owner@example.com',
          'ada@example.com',
        ]);
        expect(listed.map((item) => item.role), [
          TeamRole.editor,
          TeamRole.viewer,
        ]);
      },
    );

    test('when a stranger lists members then notFound', () async {
      final team = await createTeam(endpoints, owner);
      final stranger = await createTestUser(sessionBuilder);

      await expectLater(
        endpoints.team.listMembers(stranger.sessionBuilder, team.team.id!),
        throwsBrewing(BrewingErrorCode.notFound),
      );
    });

    test(
      'when the owner demotes an editor then the english email states the viewer limits',
      () async {
        final team = await createTeam(endpoints, owner);
        await inviteMember(endpoints, owner, member, team.team.id!);
        final before = _noticesFor('ada@example.com').length;

        final updated = await endpoints.team.changeMemberRole(
          owner.sessionBuilder,
          team.team.id!,
          member.authUserId,
          TeamRole.viewer,
          'en',
        );

        expect(updated.role, TeamRole.viewer);
        expect(updated.preferredName, 'Ada');
        final stored = await _membership(sessionBuilder, team.team.id!, member);
        expect(stored.role, TeamRole.viewer);

        final notices = _noticesFor('ada@example.com');
        expect(notices.length, before + 1);
        expect(notices.last.locale, 'en');
        expect(notices.last.subject, 'Your role on Shop Recipes changed');
        expect(notices.last.text, contains('Hello Ada'));
        expect(notices.last.text, contains(viewerSentence));
      },
    );

    test(
      'when the owner promotes a viewer in spanish then the email uses that copy',
      () async {
        final team = await createTeam(endpoints, owner);
        await inviteMember(
          endpoints,
          owner,
          member,
          team.team.id!,
          role: TeamRole.viewer,
        );

        await endpoints.team.changeMemberRole(
          owner.sessionBuilder,
          team.team.id!,
          member.authUserId,
          TeamRole.editor,
          'es',
        );

        final notice = _noticesFor('ada@example.com').last;
        expect(notice.locale, 'es');
        expect(
          notice.text,
          contains(
            'Los editores pueden agregar recetas al equipo, quitarlas y marcarlas como favoritas.',
          ),
        );
        expect(notice.text, isNot(contains(editorSentence)));
      },
    );

    test('when the locale is unknown then the email is english', () async {
      final team = await createTeam(endpoints, owner);
      await inviteMember(endpoints, owner, member, team.team.id!);

      await endpoints.team.changeMemberRole(
        owner.sessionBuilder,
        team.team.id!,
        member.authUserId,
        TeamRole.viewer,
        'fr',
      );

      final notice = _noticesFor('ada@example.com').last;
      expect(notice.locale, 'en');
      expect(notice.text, contains(viewerSentence));
    });

    test('when the role is unchanged then no email is sent', () async {
      final team = await createTeam(endpoints, owner);
      await inviteMember(
        endpoints,
        owner,
        member,
        team.team.id!,
        role: TeamRole.viewer,
      );
      final before = _noticesFor('ada@example.com').length;

      final updated = await endpoints.team.changeMemberRole(
        owner.sessionBuilder,
        team.team.id!,
        member.authUserId,
        TeamRole.viewer,
        'en',
      );

      expect(updated.role, TeamRole.viewer);
      expect(_noticesFor('ada@example.com').length, before);
    });

    test('when an editor changes a role then forbidden', () async {
      final team = await createTeam(endpoints, owner);
      await inviteMember(endpoints, owner, member, team.team.id!);
      final before = RoleChangeEmailOutbox.messages.length;

      await expectLater(
        endpoints.team.changeMemberRole(
          member.sessionBuilder,
          team.team.id!,
          owner.authUserId,
          TeamRole.viewer,
          'en',
        ),
        throwsBrewing(BrewingErrorCode.forbidden),
      );

      final stored = await _membership(sessionBuilder, team.team.id!, owner);
      expect(stored.role, TeamRole.editor);
      expect(RoleChangeEmailOutbox.messages.length, before);
    });

    test('when a stranger changes a role then notFound', () async {
      final team = await createTeam(endpoints, owner);
      final stranger = await createTestUser(sessionBuilder);

      await expectLater(
        endpoints.team.changeMemberRole(
          stranger.sessionBuilder,
          team.team.id!,
          member.authUserId,
          TeamRole.viewer,
          'en',
        ),
        throwsBrewing(BrewingErrorCode.notFound),
      );
    });

    test('when the owner changes their own role then it is stored', () async {
      final team = await createTeam(endpoints, owner);

      final updated = await endpoints.team.changeMemberRole(
        owner.sessionBuilder,
        team.team.id!,
        owner.authUserId,
        TeamRole.viewer,
        'en',
      );

      expect(updated.role, TeamRole.viewer);
      expect(updated.email, 'owner@example.com');
      final notice = _noticesFor('owner@example.com').last;
      expect(notice.text, contains(viewerSentence));
      final stored = await Team.db.findById(
        sessionBuilder.build(),
        team.team.id!,
      );
      expect(stored!.ownerId, owner.authUserId);
    });

    test(
      'when the profile has no email then the account email is used',
      () async {
        final team = await createTeam(endpoints, owner);
        final quiet = await createTestUser(sessionBuilder);
        await UserProfile.db.insertRow(
          sessionBuilder.build(),
          UserProfile(authUserId: quiet.authUserId, userName: 'Quiet'),
        );
        await EmailAccount.db.insertRow(
          sessionBuilder.build(),
          EmailAccount(
            authUserId: quiet.authUserId,
            email: 'quiet@example.com',
            passwordHash: 'not-used',
          ),
        );
        await inviteMember(
          endpoints,
          owner,
          quiet,
          team.team.id!,
          role: TeamRole.viewer,
        );

        final updated = await endpoints.team.changeMemberRole(
          owner.sessionBuilder,
          team.team.id!,
          quiet.authUserId,
          TeamRole.editor,
          'pt_BR',
        );

        expect(updated.email, 'quiet@example.com');
        expect(updated.preferredName, 'Quiet');
        final notice = _noticesFor('quiet@example.com').last;
        expect(notice.locale, 'pt_BR');
        expect(
          notice.text,
          contains(
            'Editores podem adicionar receitas à equipe, removê-las e marcá-las como favoritas.',
          ),
        );
      },
    );
  });
}

Future<void> _profile(
  TestSessionBuilder sessionBuilder,
  TestUser user, {
  required String name,
  required String email,
}) {
  return UserProfile.db.insertRow(
    sessionBuilder.build(),
    UserProfile(authUserId: user.authUserId, userName: name, email: email),
  );
}

Future<TeamMembership> _membership(
  TestSessionBuilder sessionBuilder,
  UuidValue teamId,
  TestUser user,
) async {
  final membership = await TeamMembership.db.findFirstRow(
    sessionBuilder.build(),
    where: (t) => t.teamId.equals(teamId) & t.memberId.equals(user.authUserId),
  );
  return membership!;
}

List<RoleChangeEmailMessage> _noticesFor(String email) {
  return RoleChangeEmailOutbox.messages
      .where((message) => message.recipient == email)
      .toList();
}
