import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:brewing_journal_flutter/data/repositories/fake_team_repository.dart';
import 'package:brewing_journal_flutter/ui/features/teams/cubit/teams_cubit.dart';
import 'package:brewing_journal_flutter/ui/features/teams/cubit/teams_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeTeamRepository teams;
  late TeamsCubit cubit;

  setUp(() {
    teams = FakeTeamRepository();
    cubit = TeamsCubit(teams);
  });

  tearDown(() => cubit.close());

  test('create appends the team with role editor', () async {
    expect(await cubit.create('Shop Recipes'), isTrue);
    expect(cubit.state.status, TeamsStatus.success);
    expect(cubit.state.teams, hasLength(1));
    expect(cubit.state.teams.single.team.name, 'Shop Recipes');
    expect(cubit.state.teams.single.role, TeamRole.editor);
  });

  test('reset empties the list', () async {
    await cubit.create('Shop');
    cubit.reset();
    expect(cubit.state, const TeamsState());
  });

  test('recipesChanged increments recipeRevision', () {
    cubit.recipesChanged();
    expect(cubit.state.recipeRevision, 1);
    cubit.recipesChanged();
    expect(cubit.state.recipeRevision, 2);
  });

  test('load keeps recipeRevision', () async {
    cubit.recipesChanged();
    await cubit.load();
    expect(cubit.state.status, TeamsStatus.success);
    expect(cubit.state.recipeRevision, 1);
  });
}
