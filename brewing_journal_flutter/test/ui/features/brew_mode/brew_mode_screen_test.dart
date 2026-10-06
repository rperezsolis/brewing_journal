import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:brewing_journal_flutter/data/repositories/fake_ingredient_repository.dart';
import 'package:brewing_journal_flutter/data/repositories/fake_recipe_repository.dart';
import 'package:brewing_journal_flutter/data/repositories/recipe_repository.dart';
import 'package:brewing_journal_flutter/data/services/alarm_player.dart';
import 'package:brewing_journal_flutter/l10n/app_localizations.dart';
import 'package:brewing_journal_flutter/ui/core/locale_resolution.dart';
import 'package:brewing_journal_flutter/ui/features/brew_mode/view/brew_mode_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeIngredientRepository ingredients;
  late FakeRecipeRepository recipes;

  setUp(() {
    ingredients = FakeIngredientRepository();
    recipes = FakeRecipeRepository(ingredients);
  });

  Future<RecipeDetail> seed({
    Duration? extractionDuration = const Duration(minutes: 3),
    List<String> instructions = const [],
    List<RecipePhoto>? photos,
  }) async {
    final bean = await ingredients.register(
      IngredientDraft(kind: BeverageKind.coffee, name: 'Ethiopia Guji'),
    );
    final saved = await recipes.save(
      RecipeDraft(
        ingredientId: bean.id!,
        title: 'Morning V60',
        waterTempC: 93,
        doseGrams: 15,
        waterMl: 250,
        grindSize: 'Medium-fine',
        grinderModel: 'Comandante C40',
        extractionMethod: ExtractionMethod.v60,
        extractionDuration: extractionDuration,
        acidity: 3,
        sweetness: 4,
        body: 2,
        bitterness: 1,
        flavorTags: const ['Fruity'],
        instructions: instructions,
      ),
    );
    if (photos == null) return saved;
    final id = saved.recipe.id!;
    final detail = RecipeDetail(
      recipe: saved.recipe,
      ingredient: saved.ingredient,
      instructions: saved.instructions,
      flavorTags: saved.flavorTags,
      photos: photos,
      access: saved.access,
    );
    recipes.details[id] = detail;
    return detail;
  }

  Future<void> pumpBrew(
    WidgetTester tester,
    UuidValue id, {
    UuidValue? teamId,
  }) async {
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<RecipeRepository>.value(value: recipes),
          RepositoryProvider<AlarmPlayer>.value(value: FakeAlarmPlayer()),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          localeListResolutionCallback: resolveBrewSyncLocales,
          home: BrewModeScreen(recipeId: id, teamId: teamId),
        ),
      ),
    );
    // Two pumps: the first frame is loading, the second is the loaded recipe.
    // Avoid pumpAndSettle — Image.network keeps frames pending.
    await tester.pump();
    await tester.pump();
  }

  testWidgets('omits the instructions section when the list is empty', (
    tester,
  ) async {
    final saved = await seed(instructions: const []);
    await pumpBrew(tester, saved.recipe.id!);

    expect(find.text('Ethiopia Guji'), findsOneWidget);
    expect(find.text('Prep & extra steps'), findsNothing);
    expect(find.byKey(const Key('brew-instructions')), findsNothing);
    expect(find.byKey(const Key('brew-favorite')), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
  });

  testWidgets('omits the photos section when there are no photos', (
    tester,
  ) async {
    final saved = await seed();
    await pumpBrew(tester, saved.recipe.id!);

    expect(find.byKey(const Key('brew-photos')), findsNothing);
  });

  testWidgets('omits the timer panel when there is no target', (tester) async {
    final saved = await seed(extractionDuration: null);
    await pumpBrew(tester, saved.recipe.id!);

    expect(find.text('No extraction time recorded'), findsOneWidget);
    expect(find.byKey(const Key('brew-timer')), findsNothing);
    expect(find.text('Start'), findsNothing);
  });

  testWidgets('shows instructions, photos, and the timer when they exist', (
    tester,
  ) async {
    final saved = await seed(instructions: const ['bloom', 'pour']);
    final id = saved.recipe.id!;
    await seedPhotos(recipes, saved);
    await pumpBrew(tester, id);

    expect(find.text('Prep & extra steps'), findsOneWidget);
    expect(find.text('bloom'), findsOneWidget);
    expect(find.text('pour'), findsOneWidget);
    expect(find.byKey(const Key('brew-photos')), findsOneWidget);
    expect(find.byKey(const Key('brew-timer')), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
  });

  testWidgets('with teamId the heart is present', (tester) async {
    final saved = await seed();
    final teamId = const Uuid().v7obj();
    await recipes.assignToTeam(saved.recipe.id!, teamId);
    final id = saved.recipe.id!;
    recipes.details[id] = recipes.details[id]!.copyWith(
      access: RecipeAccess(
        canEdit: true,
        canDelete: false,
        role: TeamRole.editor,
      ),
    );
    await pumpBrew(tester, id, teamId: teamId);

    expect(find.byKey(const Key('brew-favorite')), findsOneWidget);
    final button = tester.widget<IconButton>(
      find.descendant(
        of: find.byKey(const Key('brew-favorite')),
        matching: find.byType(IconButton),
      ),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('a viewer who can still edit cannot change the team heart', (
    tester,
  ) async {
    final saved = await seed();
    final teamId = const Uuid().v7obj();
    await recipes.assignToTeam(saved.recipe.id!, teamId);
    final id = saved.recipe.id!;
    recipes.details[id] = recipes.details[id]!.copyWith(
      access: RecipeAccess(
        canEdit: true,
        canDelete: true,
        role: TeamRole.viewer,
      ),
    );
    await pumpBrew(tester, id, teamId: teamId);

    final button = tester.widget<IconButton>(
      find.descendant(
        of: find.byKey(const Key('brew-favorite')),
        matching: find.byType(IconButton),
      ),
    );
    expect(button.onPressed, isNull);
  });
}

Future<void> seedPhotos(
  FakeRecipeRepository recipes,
  RecipeDetail saved,
) async {
  final id = saved.recipe.id!;
  recipes.details[id] = RecipeDetail(
    recipe: saved.recipe,
    ingredient: saved.ingredient,
    instructions: saved.instructions,
    flavorTags: saved.flavorTags,
    photos: [
      RecipePhoto(
        id: const Uuid().v7obj(),
        recipeId: id,
        storagePath: 'recipes/${id.uuid}/a.jpg',
        sortOrder: 0,
        publicUrl: Uri.parse('https://example.invalid/a.jpg'),
      ),
    ],
    access: saved.access,
  );
}
