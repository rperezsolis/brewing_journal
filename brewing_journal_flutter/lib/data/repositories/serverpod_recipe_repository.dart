import 'package:brewing_journal_client/brewing_journal_client.dart';

import 'recipe_repository.dart';

class ServerpodRecipeRepository implements RecipeRepository {
  ServerpodRecipeRepository(this._endpoint);

  final EndpointRecipe _endpoint;

  @override
  Future<RecipeDetail> save(RecipeDraft draft) => _endpoint.save(draft);

  @override
  Future<RecipeDetail> get(UuidValue id, {UuidValue? teamId}) =>
      _endpoint.get(id, teamId: teamId);

  @override
  Future<List<Recipe>> listMine({
    required int limit,
    required int offset,
    bool favoritesOnly = false,
  }) {
    if (favoritesOnly) return _endpoint.listFavorites(limit, offset);
    return _endpoint.listMine(limit, offset);
  }

  @override
  Future<FavoriteSaveResult> saveFavorite(
    UuidValue id, {
    required bool replace,
  }) => _endpoint.saveFavorite(id, replace);

  @override
  Future<void> removeFavorite(UuidValue id) => _endpoint.removeFavorite(id);

  @override
  Future<List<Recipe>> listForTeam(
    UuidValue teamId, {
    required int limit,
    required int offset,
  }) => _endpoint.listForTeam(teamId, limit, offset);

  @override
  Future<List<Recipe>> listTeamFavorites(
    UuidValue teamId, {
    required int limit,
    required int offset,
  }) => _endpoint.listTeamFavorites(teamId, limit, offset);

  @override
  Future<FavoriteSaveResult> saveTeamFavorite(
    UuidValue teamId,
    UuidValue id, {
    required bool replace,
  }) => _endpoint.saveTeamFavorite(teamId, id, replace);

  @override
  Future<void> removeTeamFavorite(UuidValue teamId, UuidValue id) =>
      _endpoint.removeTeamFavorite(teamId, id);

  @override
  Future<Recipe> assignToTeam(UuidValue recipeId, UuidValue teamId) =>
      _endpoint.assignToTeam(recipeId, teamId);

  @override
  Future<Recipe> removeFromTeam(UuidValue recipeId) =>
      _endpoint.removeFromTeam(recipeId);

  @override
  Future<RecipeAccess> getAccess(UuidValue id) => _endpoint.getAccess(id);

  @override
  Future<void> delete(UuidValue id) => _endpoint.delete(id);

  @override
  Future<List<String>> listGrinderModels(String query, {int limit = 20}) =>
      _endpoint.listGrinderModels(query, limit);
}
