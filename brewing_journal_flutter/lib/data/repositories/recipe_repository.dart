import 'package:brewing_journal_client/brewing_journal_client.dart';

abstract class RecipeRepository {
  /// Inserts (`draft.id == null`) or updates a recipe, replacing its
  /// instructions and tags in full.
  Future<RecipeDetail> save(RecipeDraft draft);

  Future<RecipeDetail> get(UuidValue id);

  /// The signed-in user's recipes, most recently updated first.
  Future<List<Recipe>> listMine({required int limit, required int offset});

  Future<RecipeAccess> getAccess(UuidValue id);

  Future<void> delete(UuidValue id);
}
