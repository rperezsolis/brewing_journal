import 'package:brewing_journal_client/brewing_journal_client.dart';

import 'ingredient_repository.dart';

class ServerpodIngredientRepository implements IngredientRepository {
  ServerpodIngredientRepository(this._endpoint);

  final EndpointIngredient _endpoint;

  @override
  Future<List<Ingredient>> search(
    BeverageKind kind,
    String query, {
    int limit = 20,
  }) => _endpoint.search(kind, query, limit);

  @override
  Future<Ingredient> register(IngredientDraft draft) =>
      _endpoint.register(draft);
}
