import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:brewing_journal_flutter/data/repositories/fake_team_repository.dart';
import 'package:brewing_journal_flutter/ui/features/teams/cubit/team_members_cubit.dart';
import 'package:brewing_journal_flutter/ui/features/teams/cubit/team_members_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeTeamRepository teams;
  late UuidValue teamId;
  late UuidValue memberId;

  setUp(() async {
    teams = FakeTeamRepository();
    final team = await teams.create('Shop Recipes');
    teamId = team.team.id!;
    memberId = const Uuid().v7obj();
    teams.addMember(
      teamId: teamId,
      userId: memberId,
      preferredName: 'Ada',
      email: 'ada@example.com',
    );
  });

  test('changeRole stores the new role and records the notice', () async {
    final cubit = TeamMembersCubit(teams, teamId: teamId);
    addTearDown(cubit.close);
    await cubit.load();
    final ada = cubit.state.members.singleWhere(
      (member) => member.userId == memberId,
    );

    expect(await cubit.changeRole(ada, TeamRole.editor, 'es_419'), isTrue);

    expect(
      cubit.state.members
          .singleWhere((member) => member.userId == memberId)
          .role,
      TeamRole.editor,
    );
    expect(cubit.state.revision, 1);
    expect(cubit.state.changingUserId, isNull);
    expect(teams.roleChangeEmails.single.locale, 'es_419');
    expect(teams.roleChangeEmails.single.email, 'ada@example.com');
  });

  test('a failed change leaves the role and surfaces the error', () async {
    final cubit = TeamMembersCubit(teams, teamId: teamId);
    addTearDown(cubit.close);
    await cubit.load();
    final ada = cubit.state.members.singleWhere(
      (member) => member.userId == memberId,
    );
    teams.nextError = BrewingException(
      code: BrewingErrorCode.forbidden,
      message: "You can't change roles on this team",
    );

    expect(await cubit.changeRole(ada, TeamRole.editor, 'en'), isFalse);

    expect(cubit.state.status, TeamMembersStatus.success);
    expect(
      cubit.state.members
          .singleWhere((member) => member.userId == memberId)
          .role,
      TeamRole.viewer,
    );
    expect(cubit.state.error, isA<BrewingException>());
    expect(teams.roleChangeEmails, isEmpty);
  });
}
