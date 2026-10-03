import 'package:serverpod/serverpod.dart';

import '../common/session_auth.dart';
import '../generated/protocol.dart';
import 'recipe_access_policy.dart';

/// Title identity for favorites: trimmed and case-insensitive.
String recipeTitleKey(String title) => title.trim().toLowerCase();

/// Sets [Recipe.isFavorite] for the signed-in caller.
Future<List<Recipe>> withFavoriteFlags(
  Session session,
  List<Recipe> recipes,
) async {
  final ids = recipes.map((recipe) => recipe.id).whereType<UuidValue>().toSet();
  if (ids.isEmpty) return recipes;

  final rows = await RecipeFavorite.db.find(
    session,
    where: (t) => t.userId.equals(session.callerId) & t.recipeId.inSet(ids),
  );
  final favoriteIds = rows.map((row) => row.recipeId).toSet();
  return [
    for (final recipe in recipes)
      recipe.copyWith(isFavorite: favoriteIds.contains(recipe.id)),
  ];
}

/// Saves [recipeId] as the caller's favorite for its title.
///
/// When another favorite already uses that title and [replace] is false, nothing
/// is written and [FavoriteSaveResult.saved] is false. The caller must be able
/// to read the recipe.
Future<FavoriteSaveResult> saveRecipeFavorite(
  Session session,
  UuidValue recipeId,
  bool replace,
) async {
  final callerId = session.callerId;
  try {
    return await session.db.transaction((transaction) async {
      final (recipe, _) = await RecipeAccessPolicy.load(
        session,
        recipeId,
        transaction: transaction,
      );
      final titleKey = recipeTitleKey(recipe.title);
      final already = await RecipeFavorite.db.findFirstRow(
        session,
        where: (t) => t.userId.equals(callerId) & t.recipeId.equals(recipeId),
        transaction: transaction,
      );
      if (already != null) return FavoriteSaveResult(saved: true);

      final conflict = await RecipeFavorite.db.findFirstRow(
        session,
        where: (t) => t.userId.equals(callerId) & t.titleKey.equals(titleKey),
        transaction: transaction,
      );
      if (conflict != null && !replace) {
        return FavoriteSaveResult(saved: false);
      }
      if (conflict != null) {
        await RecipeFavorite.db.deleteRow(
          session,
          conflict,
          transaction: transaction,
        );
      }
      await RecipeFavorite.db.insertRow(
        session,
        RecipeFavorite(
          userId: callerId,
          recipeId: recipeId,
          titleKey: titleKey,
        ),
        transaction: transaction,
      );
      return FavoriteSaveResult(
        saved: true,
        replacedRecipeId: conflict?.recipeId,
      );
    });
  } on DatabaseUniqueViolationException {
    final existing = await RecipeFavorite.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(callerId) & t.recipeId.equals(recipeId),
    );
    if (existing != null) return FavoriteSaveResult(saved: true);
    return FavoriteSaveResult(saved: false);
  }
}

/// Removes the caller's favorite for [recipeId]. Missing rows are a no-op.
/// The caller must be able to read the recipe.
Future<void> removeRecipeFavorite(Session session, UuidValue recipeId) async {
  final callerId = session.callerId;
  await session.db.transaction((transaction) async {
    await RecipeAccessPolicy.load(session, recipeId, transaction: transaction);
    final existing = await RecipeFavorite.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(callerId) & t.recipeId.equals(recipeId),
      transaction: transaction,
    );
    if (existing == null) return;
    await RecipeFavorite.db.deleteRow(
      session,
      existing,
      transaction: transaction,
    );
  });
}
