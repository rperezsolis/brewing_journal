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

  /// Team favorites, keyed by team and then by folded title. Separate from
  /// each recipe's personal [Recipe.isFavorite] flag.
  final Map<UuidValue, Map<String, UuidValue>> teamFavorites = {};

  /// When false, team favorite writes throw [BrewingErrorCode.forbidden].
  bool teamEditor = true;

  /// Extra grinder models returned by [listGrinderModels], besides models
  /// already stored on saved recipes.
  final List<String> grinderCatalog = [];

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
  Future<RecipeDetail> get(UuidValue id, {UuidValue? teamId}) async {
    _throwIfFailing();
    final detail = details[id] ?? (throw _notFound());
    if (teamId == null) return detail;
    if (detail.recipe.teamId != teamId) throw _notFound();
    return detail.copyWith(recipe: _withTeamFlag(detail.recipe, teamId));
  }

  @override
  Future<List<Recipe>> listMine({
    required int limit,
    required int offset,
    bool favoritesOnly = false,
  }) async {
    _throwIfFailing();
    final recipes = details.values.map((d) => d.recipe).where((recipe) {
      return !favoritesOnly || recipe.isFavorite;
    }).toList()..sort(_newestFirst);
    return recipes.skip(offset).take(limit).toList();
  }

  @override
  Future<FavoriteSaveResult> saveFavorite(
    UuidValue id, {
    required bool replace,
  }) async {
    _throwIfFailing();
    final detail = details[id] ?? (throw _notFound());
    if (detail.recipe.isFavorite) return FavoriteSaveResult(saved: true);

    final key = _titleKey(detail.recipe.title);
    UuidValue? conflictId;
    for (final entry in details.entries) {
      final recipe = entry.value.recipe;
      if (recipe.isFavorite &&
          entry.key != id &&
          _titleKey(recipe.title) == key) {
        conflictId = entry.key;
        break;
      }
    }
    if (conflictId != null && !replace) {
      return FavoriteSaveResult(saved: false);
    }
    if (conflictId != null) _setFavorite(conflictId, false);
    _setFavorite(id, true);
    return FavoriteSaveResult(saved: true, replacedRecipeId: conflictId);
  }

  @override
  Future<void> removeFavorite(UuidValue id) async {
    _throwIfFailing();
    if (!details.containsKey(id)) throw _notFound();
    _setFavorite(id, false);
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
            .map((d) => _withTeamFlag(d.recipe, teamId))
            .where((r) => r.teamId == teamId)
            .toList()
          ..sort(_newestFirst);
    return recipes.skip(offset).take(limit).toList();
  }

  @override
  Future<List<Recipe>> listTeamFavorites(
    UuidValue teamId, {
    required int limit,
    required int offset,
  }) async {
    _throwIfFailing();
    final ids = teamFavorites[teamId]?.values.toSet() ?? const <UuidValue>{};
    if (ids.isEmpty) return [];
    final recipes =
        details.values
            .map((d) => _withTeamFlag(d.recipe, teamId))
            .where((r) => r.teamId == teamId && ids.contains(r.id))
            .toList()
          ..sort(_newestFirst);
    return recipes.skip(offset).take(limit).toList();
  }

  @override
  Future<FavoriteSaveResult> saveTeamFavorite(
    UuidValue teamId,
    UuidValue id, {
    required bool replace,
  }) async {
    _throwIfFailing();
    _requireTeamEditor();
    final detail = details[id] ?? (throw _notFound());
    if (detail.recipe.teamId != teamId) throw _notFound();
    final key = _titleKey(detail.recipe.title);
    final byTitle = teamFavorites.putIfAbsent(teamId, () => {});
    final current = byTitle[key];
    if (current == id) return FavoriteSaveResult(saved: true);
    if (current != null && !replace) {
      return FavoriteSaveResult(saved: false);
    }
    byTitle[key] = id;
    return FavoriteSaveResult(saved: true, replacedRecipeId: current);
  }

  @override
  Future<void> removeTeamFavorite(UuidValue teamId, UuidValue id) async {
    _throwIfFailing();
    _requireTeamEditor();
    final detail = details[id] ?? (throw _notFound());
    if (detail.recipe.teamId != teamId) throw _notFound();
    final byTitle = teamFavorites[teamId];
    if (byTitle == null) return;
    final key = _titleKey(detail.recipe.title);
    if (byTitle[key] == id) byTitle.remove(key);
  }

  @override
  Future<Recipe> assignToTeam(UuidValue recipeId, UuidValue teamId) async {
    _throwIfFailing();
    final detail = details[recipeId] ?? (throw _notFound());
    _dropTeamFavorite(recipeId);
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
    _dropTeamFavorite(recipeId);
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
  Future<List<String>> listGrinderModels(
    String query, {
    int limit = 20,
  }) async {
    _throwIfFailing();
    final prefix = query.trim().toLowerCase();
    final spelling = <String, String>{};
    final fromRecipes = details.values.map((detail) => detail.recipe).toList()
      ..sort(_newestFirst);
    for (final model in [
      ...fromRecipes.map((recipe) => recipe.grinderModel),
      ...grinderCatalog,
    ]) {
      final trimmed = model.trim();
      final key = trimmed.toLowerCase();
      if (!key.startsWith(prefix)) continue;
      spelling.putIfAbsent(key, () => trimmed);
    }
    final models = spelling.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return [for (final entry in models.take(limit)) entry.value];
  }

  @override
  Future<void> delete(UuidValue id) async {
    _throwIfFailing();
    if (details.remove(id) == null) throw _notFound();
    _dropTeamFavorite(id);
  }

  Recipe _withTeamFlag(Recipe recipe, UuidValue teamId) {
    final winner = teamFavorites[teamId]?[_titleKey(recipe.title)];
    return recipe.copyWith(isFavorite: winner != null && winner == recipe.id);
  }

  void _dropTeamFavorite(UuidValue recipeId) {
    for (final byTitle in teamFavorites.values) {
      byTitle.removeWhere((_, id) => id == recipeId);
    }
  }

  void _requireTeamEditor() {
    if (teamEditor) return;
    throw BrewingException(
      code: BrewingErrorCode.forbidden,
      message: "Viewers can't change team favorites",
    );
  }

  void _setFavorite(UuidValue id, bool isFavorite) {
    final detail = details[id];
    if (detail == null || detail.recipe.isFavorite == isFavorite) return;
    details[id] = detail.copyWith(
      recipe: detail.recipe.copyWith(isFavorite: isFavorite),
    );
  }

  static String _titleKey(String title) => title.trim().toLowerCase();

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
