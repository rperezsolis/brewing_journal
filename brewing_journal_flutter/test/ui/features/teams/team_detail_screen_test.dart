import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:brewing_journal_flutter/data/repositories/auth_repository.dart';
import 'package:brewing_journal_flutter/data/repositories/fake_auth_repository.dart';
import 'package:brewing_journal_flutter/data/repositories/fake_ingredient_repository.dart';
import 'package:brewing_journal_flutter/data/repositories/fake_recipe_repository.dart';
import 'package:brewing_journal_flutter/data/repositories/fake_team_repository.dart';
import 'package:brewing_journal_flutter/data/repositories/recipe_repository.dart';
import 'package:brewing_journal_flutter/l10n/app_localizations.dart';
import 'package:brewing_journal_flutter/ui/core/locale_resolution.dart';
import 'package:brewing_journal_flutter/ui/features/teams/cubit/teams_cubit.dart';
import 'package:brewing_journal_flutter/ui/features/teams/view/team_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeIngredientRepository ingredients;
  late FakeRecipeRepository recipes;
  late FakeTeamRepository teams;
  late FakeAuthRepository auth;
  late TeamsCubit teamsCubit;
  late TeamSummary team;
  late Recipe recipe;

  setUp(() async {
    ingredients = FakeIngredientRepository();
    recipes = FakeRecipeRepository(ingredients);
    teams = FakeTeamRepository();
    auth = FakeAuthRepository(currentUserId: teams.ownerId);
    teamsCubit = TeamsCubit(teams);
    team = await teams.create('Shop Recipes');
    await teamsCubit.load();
    final bean = await ingredients.register(
      IngredientDraft(kind: BeverageKind.coffee, name: 'Kenya AA'),
    );
    final saved = await recipes.save(
      RecipeDraft(
        ingredientId: bean.id!,
        title: 'Morning V60',
        waterTempC: 93,
        doseGrams: 15,
        grindSize: 'fine',
        grinderModel: 'Niche',
        extractionMethod: ExtractionMethod.v60,
        acidity: 0,
        sweetness: 0,
        body: 0,
        bitterness: 0,
        flavorTags: const [],
        instructions: const [],
      ),
    );
    recipe = saved.recipe;
  });

  tearDown(() => teamsCubit.close());

  Future<void> pumpHarness(WidgetTester tester, ValueNotifier<int> tab) async {
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<RecipeRepository>.value(value: recipes),
          RepositoryProvider<AuthRepository>.value(value: auth),
        ],
        child: BlocProvider<TeamsCubit>.value(
          value: teamsCubit,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            localeListResolutionCallback: resolveBrewSyncLocales,
            home: ValueListenableBuilder<int>(
              valueListenable: tab,
              builder: (context, index, _) {
                return IndexedStack(
                  index: index,
                  children: [
                    const SizedBox.shrink(),
                    TeamDetailScreen(teamId: team.team.id!),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('shows a recipe assigned while the teams tab was hidden', (
    tester,
  ) async {
    final tab = ValueNotifier(1);
    addTearDown(tab.dispose);
    await pumpHarness(tester, tab);
    expect(find.text('No recipes on this team yet.'), findsOneWidget);

    tab.value = 0;
    await tester.pump();

    await recipes.assignToTeam(recipe.id!, team.team.id!);

    tab.value = 1;
    await tester.pump();
    await tester.pump();

    expect(find.text('Morning V60'), findsOneWidget);
  });

  testWidgets('reloads when TeamsCubit reports a recipe change', (
    tester,
  ) async {
    final tab = ValueNotifier(1);
    addTearDown(tab.dispose);
    await pumpHarness(tester, tab);
    expect(find.text('No recipes on this team yet.'), findsOneWidget);

    await recipes.assignToTeam(recipe.id!, team.team.id!);
    teamsCubit.recipesChanged();
    await tester.pump();
    await tester.pump();

    expect(find.text('Morning V60'), findsOneWidget);
  });
}
