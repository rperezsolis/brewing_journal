import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:brewing_journal_flutter/data/repositories/fake_ingredient_repository.dart';
import 'package:brewing_journal_flutter/data/repositories/fake_recipe_repository.dart';
import 'package:brewing_journal_flutter/l10n/app_localizations.dart';
import 'package:brewing_journal_flutter/ui/core/locale_resolution.dart';
import 'package:brewing_journal_flutter/ui/features/recipe_list/cubit/recipe_list_cubit.dart';
import 'package:brewing_journal_flutter/ui/features/recipe_list/view/recipe_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeRecipeRepository recipes;
  late RecipeListCubit cubit;
  late UuidValue firstId;
  late UuidValue secondId;

  setUp(() async {
    final ingredients = FakeIngredientRepository();
    recipes = FakeRecipeRepository(ingredients);
    final bean = await ingredients.register(
      IngredientDraft(kind: BeverageKind.coffee, name: 'Kenya AA'),
    );
    RecipeDraft draft(String title, double dose) => RecipeDraft(
      ingredientId: bean.id!,
      title: title,
      waterTempC: 93,
      doseGrams: dose,
      waterMl: 250,
      grindSize: 'fine',
      grinderModel: 'Niche',
      extractionMethod: ExtractionMethod.v60,
      acidity: 0,
      sweetness: 0,
      body: 0,
      bitterness: 0,
      flavorTags: const [],
      instructions: const [],
    );
    firstId = (await recipes.save(draft('V60', 15))).recipe.id!;
    await Future<void>.delayed(const Duration(milliseconds: 2));
    secondId = (await recipes.save(draft('V60', 18))).recipe.id!;
    cubit = RecipeListCubit(recipes);
    await cubit.load();
  });

  tearDown(() => cubit.close());

  Future<void> pumpList(WidgetTester tester) async {
    await tester.pumpWidget(
      BlocProvider<RecipeListCubit>.value(
        value: cubit,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          localeListResolutionCallback: resolveBrewSyncLocales,
          locale: const Locale('en'),
          home: const RecipeListScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  Finder favoriteOf(UuidValue id) =>
      find.byKey(ValueKey('recipe-favorite-${id.uuid}'));

  testWidgets('the app bar filter shows only favorites', (tester) async {
    await recipes.saveFavorite(firstId, replace: false);
    await cubit.load();
    await pumpList(tester);

    expect(find.text('V60'), findsNWidgets(2));
    await tester.tap(find.byKey(const Key('recipe-list-favorites')));
    await tester.pump();
    await tester.pump();

    expect(find.text('V60'), findsOneWidget);
    expect(favoriteOf(firstId), findsOneWidget);
    expect(favoriteOf(secondId), findsNothing);

    await tester.tap(find.byKey(const Key('recipe-list-favorites')));
    await tester.pump();
    await tester.pump();
    expect(find.text('V60'), findsNWidgets(2));
  });

  testWidgets('accept replaces the favorite with the same name', (
    tester,
  ) async {
    await recipes.saveFavorite(firstId, replace: false);
    await cubit.load();
    await pumpList(tester);

    await tester.tap(favoriteOf(secondId));
    await tester.pumpAndSettle();
    expect(find.text('Already in favorites'), findsOneWidget);

    await tester.tap(find.byKey(const Key('favorite-conflict-accept')));
    await tester.pump();

    expect(recipes.details[secondId]!.recipe.isFavorite, isTrue);
    expect(recipes.details[firstId]!.recipe.isFavorite, isFalse);
  });

  testWidgets('cancel leaves the existing favorite in place', (tester) async {
    await recipes.saveFavorite(firstId, replace: false);
    await cubit.load();
    await pumpList(tester);

    await tester.tap(favoriteOf(secondId));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('favorite-conflict-cancel')));
    await tester.pumpAndSettle();

    expect(recipes.details[firstId]!.recipe.isFavorite, isTrue);
    expect(recipes.details[secondId]!.recipe.isFavorite, isFalse);
  });
}
