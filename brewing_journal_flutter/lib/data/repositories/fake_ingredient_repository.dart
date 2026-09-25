import 'package:brewing_journal_client/brewing_journal_client.dart';

import 'ingredient_repository.dart';

/// In-memory [IngredientRepository] for tests and previews.
class FakeIngredientRepository implements IngredientRepository {
  FakeIngredientRepository([List<Ingredient> initial = const []])
    : ingredients = [...initial];

  final List<Ingredient> ingredients;

  /// When set, the next call throws it once.
  Object? nextError;

  @override
  Future<List<Ingredient>> search(
    BeverageKind kind,
    String query, {
    int limit = 20,
  }) async {
    _throwIfFailing();
    final key = query.trim().toLowerCase();
    return (ingredients
            .where((i) => i.kind == kind && i.nameKey.startsWith(key))
            .toList()
          ..sort((a, b) => a.nameKey.compareTo(b.nameKey)))
        .take(limit)
        .toList();
  }

  @override
  Future<Ingredient> register(IngredientDraft draft) async {
    _throwIfFailing();
    final name = draft.name.trim();
    if (name.isEmpty) {
      throw BrewingException(
        code: BrewingErrorCode.validation,
        message: 'name: must not be empty',
      );
    }
    final key = name.toLowerCase();
    for (final existing in ingredients) {
      if (existing.kind == draft.kind && existing.nameKey == key) {
        return existing;
      }
    }
    final ingredient = Ingredient(
      id: const Uuid().v7obj(),
      ownerId: const Uuid().v7obj(),
      kind: draft.kind,
      name: name,
      nameKey: key,
      origin: draft.origin,
      roaster: draft.roaster,
      roastLevel: draft.roastLevel,
      processing: draft.processing,
    );
    ingredients.add(ingredient);
    return ingredient;
  }

  void _throwIfFailing() {
    final error = nextError;
    if (error == null) return;
    nextError = null;
    throw error;
  }
}
