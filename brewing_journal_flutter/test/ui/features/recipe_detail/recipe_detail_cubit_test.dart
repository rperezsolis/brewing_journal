import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:brewing_journal_flutter/data/repositories/fake_ingredient_repository.dart';
import 'package:brewing_journal_flutter/data/repositories/fake_recipe_repository.dart';
import 'package:brewing_journal_flutter/ui/features/recipe_detail/cubit/recipe_detail_cubit.dart';
import 'package:brewing_journal_flutter/ui/features/recipe_detail/cubit/recipe_detail_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeIngredientRepository ingredients;
  late FakeRecipeRepository recipes;
  late RecipeDetailCubit cubit;

  setUp(() {
    ingredients = FakeIngredientRepository();
    recipes = FakeRecipeRepository(ingredients);
    cubit = RecipeDetailCubit(recipes);
  });

  tearDown(() => cubit.close());

  Future<RecipeDetail> seed() async {
    final bean = await ingredients.register(
      IngredientDraft(kind: BeverageKind.coffee, name: 'Kenya AA'),
    );
    return recipes.save(
      RecipeDraft(
        ingredientId: bean.id!,
        title: 'Morning V60',
        waterTempC: 93,
        doseGrams: 15,
        grindSize: 'fine',
        grinderModel: 'Niche',
        extractionMethod: ExtractionMethod.v60,
        acidity: 2,
        sweetness: 3,
        body: 2,
        bitterness: 1,
        flavorTags: const [],
        instructions: const [],
      ),
    );
  }

  test('load succeeds with the recipe', () async {
    final saved = await seed();
    await cubit.load(saved.recipe.id!);
    expect(cubit.state.status, RecipeDetailStatus.success);
    expect(cubit.state.detail!.recipe.title, 'Morning V60');
  });

  test('load of an unknown id is a failure', () async {
    await cubit.load(const Uuid().v7obj());
    expect(cubit.state.status, RecipeDetailStatus.failure);
    expect(cubit.state.error, isA<BrewingException>());
  });

  test('delete removes the recipe when the caller may', () async {
    final saved = await seed();
    await cubit.load(saved.recipe.id!);
    expect(await cubit.delete(), isTrue);
    expect(recipes.details.containsKey(saved.recipe.id), isFalse);
  });

  test('delete does nothing without canDelete', () async {
    final saved = await seed();
    final id = saved.recipe.id!;
    recipes.details[id] = RecipeDetail(
      recipe: saved.recipe,
      ingredient: saved.ingredient,
      instructions: saved.instructions,
      flavorTags: saved.flavorTags,
      photos: saved.photos,
      access: RecipeAccess(canEdit: true, canDelete: false),
    );
    await cubit.load(id);
    expect(await cubit.delete(), isFalse);
    expect(recipes.details.containsKey(id), isTrue);
  });
}
