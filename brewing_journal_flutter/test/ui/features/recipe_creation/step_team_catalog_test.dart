import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:brewing_journal_flutter/data/repositories/fake_ingredient_repository.dart';
import 'package:brewing_journal_flutter/data/repositories/fake_recipe_media_repository.dart';
import 'package:brewing_journal_flutter/data/repositories/fake_recipe_repository.dart';
import 'package:brewing_journal_flutter/l10n/app_localizations.dart';
import 'package:brewing_journal_flutter/ui/core/locale_resolution.dart';
import 'package:brewing_journal_flutter/ui/features/recipe_creation/cubit/recipe_creation_cubit.dart';
import 'package:brewing_journal_flutter/ui/features/recipe_creation/view/step_extraction.dart';
import 'package:brewing_journal_flutter/ui/features/recipe_creation/view/step_ingredient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeIngredientRepository ingredients;
  late FakeRecipeRepository recipes;
  late RecipeCreationCubit cubit;

  setUp(() {
    ingredients = FakeIngredientRepository();
    recipes = FakeRecipeRepository(ingredients);
    cubit = RecipeCreationCubit(
      recipes: recipes,
      ingredients: ingredients,
      media: FakeRecipeMediaRepository(),
    );
  });

  tearDown(() => cubit.close());

  Future<void> pump(WidgetTester tester, Widget step) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        localeListResolutionCallback: resolveBrewSyncLocales,
        home: Scaffold(
          body: BlocProvider.value(value: cubit, child: step),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('tapping a search result selects the adopted ingredient', (
    tester,
  ) async {
    final foreignId = const Uuid().v7obj();
    ingredients.ingredients.add(
      Ingredient(
        id: foreignId,
        ownerId: const Uuid().v7obj(),
        kind: BeverageKind.coffee,
        name: 'Ethiopia Guji',
        nameKey: 'ethiopia guji',
        origin: 'Yirgacheffe',
      ),
    );

    await pump(tester, const StepIngredient());
    await tester.tap(find.text('Ethiopia Guji'));
    await tester.pumpAndSettle();

    final selected = cubit.state.selectedIngredient!;
    expect(selected.id, isNot(foreignId));
    expect(selected.ownerId, ingredients.selfId);
    expect(selected.origin, 'Yirgacheffe');
    expect(find.byKey(ValueKey(selected.id)), findsOneWidget);
    expect(find.byKey(ValueKey(foreignId)), findsNothing);
  });

  testWidgets('tapping a grinder suggestion fills the field', (tester) async {
    recipes.grinderCatalog.addAll(['Comandante C40', 'Niche Zero']);

    await pump(tester, const StepExtraction());
    expect(
      find.byKey(const ValueKey('grinder-suggestion-Comandante C40')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('grinder-suggestion-Niche Zero')),
      findsOneWidget,
    );

    await tester.tap(find.text('Comandante C40'));
    await tester.pumpAndSettle();

    expect(cubit.state.grinderModel, 'Comandante C40');
    expect(
      find.byKey(const ValueKey('grinder-suggestion-Comandante C40')),
      findsNothing,
    );

    await tester.enterText(find.byKey(const Key('extraction-grinder')), 'ni');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(cubit.state.grinderSuggestions, ['Niche Zero']);
    expect(
      find.byKey(const ValueKey('grinder-suggestion-Niche Zero')),
      findsOneWidget,
    );
  });
}
