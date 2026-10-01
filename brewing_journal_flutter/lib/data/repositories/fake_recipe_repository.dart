import 'package:brewing_journal_client/brewing_journal_client.dart';

import 'fake_ingredient_repository.dart';
import 'recipe_repository.dart';

/// In-memory [RecipeRepository] for tests and previews. Ingredients are
/// resolved from [ingredients].
class FakeRecipeRepository implements RecipeRepository {
  FakeRecipeRepository(this.ingredients);

  final FakeIngredientRepository ingredients;
  final Map<UuidValue, RecipeDetail> details = {};

  /// Every draft passed to [save], in call order.
  final List<RecipeDraft> savedDrafts = [];

  /// When set, the next call throws it once.
  Object? nextError;

  @override
  Future<RecipeDetail> save(RecipeDraft draft) async {
    _throwIfFailing();
    savedDrafts.add(draft);
    final ingredient = ingredients.ingredients.firstWhere(
      (i) => i.id == draft.ingredientId,
      orElse: () => throw _notFound(),
    );
    final source = draft.id == null ? null : details[draft.id];
    if (draft.id != null && source == null) throw _notFound();
    final id = const Uuid().v7obj();
    final now = DateTime.now().toUtc();
    final recipe = Recipe(
      id: id,
      ownerId: ingredient.ownerId,
      teamId: source?.recipe.teamId ?? draft.teamId,
      ingredientId: ingredient.id!,
      ingredient: ingredient,
      title: draft.title.trim(),
      waterTempC: draft.waterTempC,
      doseGrams: draft.doseGrams,
      grindSize: draft.grindSize.trim(),
      grinderModel: draft.grinderModel.trim(),
      extractionMethod: draft.extractionMethod,
      extractionMethodNote: draft.extractionMethodNote,
      extractionDuration: draft.extractionDuration,
      acidity: draft.acidity,
      sweetness: draft.sweetness,
      body: draft.body,
      bitterness: draft.bitterness,
      createdAt: now,
      updatedAt: now,
      authorName: source?.recipe.authorName,
    );
    final detail = RecipeDetail(
      recipe: recipe,
      ingredient: ingredient,
      instructions: [
        for (final (index, text) in draft.instructions.indexed)
          RecipeInstruction(recipeId: id, sortOrder: index, text: text.trim()),
      ],
      flavorTags: [
        for (final tag in draft.flavorTags)
          RecipeFlavorTag(
            recipeId: id,
            tag: tag.trim(),
            tagKey: tag.trim().toLowerCase(),
          ),
      ],
      photos: [
        for (final photo in source?.photos ?? const <RecipePhoto>[])
          photo.copyWith(id: const Uuid().v7obj(), recipeId: id),
      ],
      access: RecipeAccess(canEdit: true, canDelete: true),
    );
    details[id] = detail;
    return detail;
  }

  @override
  Future<RecipeDetail> get(UuidValue id) async {
    _throwIfFailing();
    return details[id] ?? (throw _notFound());
  }

  @override
  Future<List<Recipe>> listMine({
    required int limit,
    required int offset,
  }) async {
    _throwIfFailing();
    final recipes = details.values.map((d) => d.recipe).toList()
      ..sort(_newestFirst);
    return recipes.skip(offset).take(limit).toList();
  }

  @override
  Future<List<Recipe>> listForTeam(
    UuidValue teamId, {
    required int limit,
    required int offset,
  }) async {
    _throwIfFailing();
    final recipes =
        details.values
            .map((d) => d.recipe)
            .where((r) => r.teamId == teamId)
            .toList()
          ..sort(_newestFirst);
    return recipes.skip(offset).take(limit).toList();
  }

  @override
  Future<Recipe> assignToTeam(UuidValue recipeId, UuidValue teamId) async {
    _throwIfFailing();
    final detail = details[recipeId] ?? (throw _notFound());
    final recipe = detail.recipe.copyWith(teamId: teamId);
    details[recipeId] = RecipeDetail(
      recipe: recipe,
      ingredient: detail.ingredient,
      instructions: detail.instructions,
      flavorTags: detail.flavorTags,
      photos: detail.photos,
      access: detail.access,
    );
    return recipe;
  }

  @override
  Future<Recipe> removeFromTeam(UuidValue recipeId) async {
    _throwIfFailing();
    final detail = details[recipeId] ?? (throw _notFound());
    final recipe = detail.recipe.copyWith(teamId: null);
    details[recipeId] = RecipeDetail(
      recipe: recipe,
      ingredient: detail.ingredient,
      instructions: detail.instructions,
      flavorTags: detail.flavorTags,
      photos: detail.photos,
      access: detail.access,
    );
    return recipe;
  }

  @override
  Future<RecipeAccess> getAccess(UuidValue id) async => (await get(id)).access;

  @override
  Future<void> delete(UuidValue id) async {
    _throwIfFailing();
    if (details.remove(id) == null) throw _notFound();
  }

  static int _newestFirst(Recipe a, Recipe b) {
    final byTime = b.updatedAt.compareTo(a.updatedAt);
    if (byTime != 0) return byTime;
    return (b.id?.uuid ?? '').compareTo(a.id?.uuid ?? '');
  }

  BrewingException _notFound() => BrewingException(
    code: BrewingErrorCode.notFound,
    message: 'Recipe not found',
  );

  void _throwIfFailing() {
    final error = nextError;
    if (error == null) return;
    nextError = null;
    throw error;
  }
}
