import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:brewing_journal_flutter/data/repositories/fake_ingredient_repository.dart';
import 'package:brewing_journal_flutter/data/repositories/fake_recipe_repository.dart';
import 'package:brewing_journal_flutter/ui/features/recipe_list/cubit/recipe_list_cubit.dart';
import 'package:brewing_journal_flutter/ui/features/recipe_list/cubit/recipe_list_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeRecipeRepository recipes;
  late RecipeListCubit cubit;

  setUp(() async {
    final ingredients = FakeIngredientRepository();
    recipes = FakeRecipeRepository(ingredients);
    final bean = await ingredients.register(
      IngredientDraft(kind: BeverageKind.coffee, name: 'Kenya AA'),
    );
    for (var i = 0; i < 5; i++) {
      await recipes.save(
        RecipeDraft(
          ingredientId: bean.id!,
          title: 'recipe $i',
          waterTempC: 93,
          doseGrams: 15,
          waterMl: 250,
          grindSize: 'fine',
          grinderModel: 'Niche',
          extractionMethod: ExtractionMethod.v60,
          acidity: 0,
          sweetness: 0,
          body: 0,
          bitterness: 0,
          flavorTags: [],
          instructions: [],
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 2));
    }
    cubit = RecipeListCubit(recipes, pageSize: 2);
  });

  tearDown(() => cubit.close());

  List<String> titles() => cubit.state.recipes.map((r) => r.title).toList();

  test('load fetches the newest page', () async {
    await cubit.load();
    expect(cubit.state.status, RecipeListStatus.success);
    expect(titles(), ['recipe 4', 'recipe 3']);
    expect(cubit.state.hasMore, isTrue);
  });

  test('loadMore appends the next page until the end', () async {
    await cubit.load();
    await cubit.loadMore();
    expect(titles(), ['recipe 4', 'recipe 3', 'recipe 2', 'recipe 1']);

    await cubit.loadMore();
    expect(titles(), hasLength(5));
    expect(cubit.state.hasMore, isFalse);
  });

  test('reset empties the list', () async {
    await cubit.load();
    cubit.reset();
    expect(cubit.state, const RecipeListState());
  });

  test('a page that arrives after reset is dropped', () async {
    final loading = cubit.load();
    cubit.reset();
    await loading;
    expect(cubit.state.recipes, isEmpty);
  });

  test('a failed load sets failure', () async {
    recipes.nextError = const ServerpodClientNetworkException('down');
    await cubit.load();
    expect(cubit.state.status, RecipeListStatus.failure);
    expect(cubit.state.error, isA<ServerpodClientNetworkException>());
  });

  test('setFavoritesOnly reloads with only favorites', () async {
    await cubit.load();
    final kept = cubit.state.recipes.first;
    await recipes.saveFavorite(kept.id!, replace: false);

    await cubit.setFavoritesOnly(true);

    expect(cubit.state.favoritesOnly, isTrue);
    expect(cubit.state.recipes.map((r) => r.id), [kept.id]);
    expect(cubit.state.recipes.single.isFavorite, isTrue);

    expect(await cubit.removeFavorite(kept.id!), isTrue);
    expect(cubit.state.recipes, isEmpty);
  });

  test('saveFavorite replaces the other recipe with the same name', () async {
    final ingredients = FakeIngredientRepository();
    final store = FakeRecipeRepository(ingredients);
    final bean = await ingredients.register(
      IngredientDraft(kind: BeverageKind.coffee, name: 'Kenya AA'),
    );
    RecipeDraft draft(double dose) => RecipeDraft(
      ingredientId: bean.id!,
      title: 'V60',
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
    final first = await store.save(draft(15));
    await Future<void>.delayed(const Duration(milliseconds: 2));
    final second = await store.save(draft(18));
    final list = RecipeListCubit(store);
    addTearDown(list.close);
    await list.load();

    final saved = await list.saveFavorite(first.recipe.id!);
    expect(saved?.saved, isTrue);

    final blocked = await list.saveFavorite(second.recipe.id!);
    expect(blocked?.saved, isFalse);
    expect(list.state.recipes.map((r) => r.isFavorite), [isFalse, isTrue]);

    final replaced = await list.saveFavorite(second.recipe.id!, replace: true);

    expect(replaced?.saved, isTrue);
    expect(replaced?.replacedRecipeId, first.recipe.id);
    expect(list.state.recipes.map((r) => r.isFavorite), [isTrue, isFalse]);
  });

  test('a team filter and save stay off the personal list', () async {
    final teamId = const Uuid().v7obj();
    final stored = recipes.details.values.toList()
      ..sort((a, b) => b.recipe.updatedAt.compareTo(a.recipe.updatedAt));
    final newest = stored.first.recipe.id!;
    final older = stored[1].recipe.id!;
    await recipes.assignToTeam(newest, teamId);
    await recipes.assignToTeam(older, teamId);

    final teamList = RecipeListCubit(recipes, teamId: teamId, pageSize: 20);
    addTearDown(teamList.close);
    await teamList.load();
    expect(
      teamList.state.recipes.every((recipe) => !recipe.isFavorite),
      isTrue,
    );

    final saved = await teamList.saveFavorite(newest);
    expect(saved?.saved, isTrue);
    expect(recipes.details[newest]!.recipe.isFavorite, isFalse);

    await teamList.setFavoritesOnly(true);
    expect(teamList.state.recipes.map((recipe) => recipe.id), [newest]);

    await cubit.load();
    expect(await cubit.saveFavorite(older), isNotNull);
    final teamView = await recipes.listForTeam(teamId, limit: 10, offset: 0);
    expect(
      teamView.firstWhere((recipe) => recipe.id == older).isFavorite,
      isFalse,
    );
    expect(recipes.details[older]!.recipe.isFavorite, isTrue);
  });
}
