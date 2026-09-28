import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:brewing_journal_flutter/data/repositories/fake_team_repository.dart';
import 'package:brewing_journal_flutter/ui/features/invite/cubit/invite_accept_cubit.dart';
import 'package:brewing_journal_flutter/ui/features/invite/cubit/invite_accept_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeTeamRepository teams;
  late InviteAcceptCubit cubit;

  setUp(() {
    teams = FakeTeamRepository();
    cubit = InviteAcceptCubit(teams);
  });

  tearDown(() => cubit.close());

  for (final code in [
    BrewingErrorCode.inviteExpired,
    BrewingErrorCode.inviteUsed,
    BrewingErrorCode.alreadyMember,
    BrewingErrorCode.notFound,
  ]) {
    test('maps $code to failure with that code', () async {
      teams.nextError = BrewingException(code: code, message: 'x');
      await cubit.accept('token');
      expect(cubit.state.status, InviteAcceptStatus.failure);
      expect(cubit.state.errorCode, code);
    });
  }

  test('a successful accept stores the team', () async {
    final created = await teams.create('Shop');
    final invite = await teams.createInvite(
      created.team.id!,
      TeamRole.viewer,
      const Duration(hours: 1),
    );
    teams.teams.clear();

    await cubit.accept(invite.token);

    expect(cubit.state.status, InviteAcceptStatus.success);
    expect(cubit.state.team!.role, TeamRole.viewer);
  });
}
