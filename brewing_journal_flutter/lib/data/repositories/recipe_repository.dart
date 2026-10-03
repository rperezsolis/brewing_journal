import 'package:brewing_journal_client/brewing_journal_client.dart';

abstract class RecipeRepository {
  /// Inserts (`draft.id == null`) or updates a recipe, replacing its
  /// instructions and tags in full.
  Future<RecipeDetail> save(RecipeDraft draft);

  Future<RecipeDetail> get(UuidValue id);

  /// The signed-in user's recipes, most recently updated first.
  ///
  /// When [favoritesOnly] is true, only recipes that user has saved to
  /// favorites are returned.
  Future<List<Recipe>> listMine({
    required int limit,
    required int offset,
    bool favoritesOnly = false,
  });

  /// Saves [id] as the user's favorite for that recipe's name.
  ///
  /// When another favorite already uses the name and [replace] is false,
  /// nothing changes and [FavoriteSaveResult.saved] is false.
  Future<FavoriteSaveResult> saveFavorite(
    UuidValue id, {
    required bool replace,
  });

  /// Removes [id] from the user's favorites.
  Future<void> removeFavorite(UuidValue id);

  Future<List<Recipe>> listForTeam(
    UuidValue teamId, {
    required int limit,
    required int offset,
  });

  Future<Recipe> assignToTeam(UuidValue recipeId, UuidValue teamId);

  Future<Recipe> removeFromTeam(UuidValue recipeId);

  Future<RecipeAccess> getAccess(UuidValue id);

  Future<void> delete(UuidValue id);
}
