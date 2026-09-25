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
}
