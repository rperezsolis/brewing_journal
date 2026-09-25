import 'package:brewing_journal_client/brewing_journal_client.dart';

import 'recipe_repository.dart';

class ServerpodRecipeRepository implements RecipeRepository {
  ServerpodRecipeRepository(this._endpoint);

  final EndpointRecipe _endpoint;

  @override
  Future<RecipeDetail> save(RecipeDraft draft) => _endpoint.save(draft);

  @override
  Future<RecipeDetail> get(UuidValue id) => _endpoint.get(id);

  @override
  Future<List<Recipe>> listMine({required int limit, required int offset}) =>
      _endpoint.listMine(limit, offset);

  @override
  Future<RecipeAccess> getAccess(UuidValue id) => _endpoint.getAccess(id);

  @override
  Future<void> delete(UuidValue id) => _endpoint.delete(id);
}
