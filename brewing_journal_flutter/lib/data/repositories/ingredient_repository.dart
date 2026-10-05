import 'package:brewing_journal_client/brewing_journal_client.dart';

/// The signed-in user's beans, leaves, and matcha grades.
abstract class IngredientRepository {
  /// Ingredients of [kind] whose name starts with [query] (case-insensitive).
  Future<List<Ingredient>> search(
    BeverageKind kind,
    String query, {
    int limit = 20,
  });

  /// Returns the existing ingredient with the same kind and name, or a new one.
  Future<Ingredient> register(IngredientDraft draft);

  /// Copies [id] onto the signed-in user's account when it belongs to a
  /// teammate, or returns the user's existing ingredient of that kind and name.
  /// The user's own id is returned unchanged.
  Future<Ingredient> adopt(UuidValue id);
}
