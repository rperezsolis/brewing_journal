import 'package:brewing_journal_client/brewing_journal_client.dart';

import 'ingredient_repository.dart';

/// In-memory [IngredientRepository] for tests and previews.
class FakeIngredientRepository implements IngredientRepository {
  FakeIngredientRepository([List<Ingredient> initial = const []])
    : ingredients = [...initial];

  final List<Ingredient> ingredients;

  /// Owner id used for [register] and for copies made by [adopt].
  final UuidValue selfId = const Uuid().v7obj();

  /// When set, the next call throws it once.
  Object? nextError;

  /// When set, [adopt] waits for it before copying. Tests use this to pause
  /// a tap that is still in flight.
  Future<void>? pendingAdopt;

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
      ownerId: selfId,
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

  @override
  Future<Ingredient> adopt(UuidValue id) async {
    _throwIfFailing();
    final gate = pendingAdopt;
    if (gate != null) await gate;
    Ingredient? source;
    for (final ingredient in ingredients) {
      if (ingredient.id == id) source = ingredient;
    }
    if (source == null) {
      throw BrewingException(
        code: BrewingErrorCode.notFound,
        message: 'Ingredient not found',
      );
    }
    if (source.ownerId == selfId) return source;
    for (final existing in ingredients) {
      if (existing.ownerId == selfId &&
          existing.kind == source.kind &&
          existing.nameKey == source.nameKey) {
        return existing;
      }
    }
    final copy = Ingredient(
      id: const Uuid().v7obj(),
      ownerId: selfId,
      kind: source.kind,
      name: source.name,
      nameKey: source.nameKey,
      origin: source.origin,
      roaster: source.roaster,
      roastLevel: source.roastLevel,
      processing: source.processing,
    );
    ingredients.add(copy);
    return copy;
  }

  void _throwIfFailing() {
    final error = nextError;
    if (error == null) return;
    nextError = null;
    throw error;
  }
}
