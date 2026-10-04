import 'package:serverpod/serverpod.dart';

import '../common/session_auth.dart';
import '../generated/protocol.dart';
import '../teams/team_membership_lookup.dart';
import 'recipe_access_policy.dart';
import 'recipe_favorites.dart';

/// Sets [Recipe.isFavorite] from [teamId]'s favorites.
Future<List<Recipe>> withTeamFavoriteFlags(
  Session session,
  UuidValue teamId,
  List<Recipe> recipes,
) async {
  final ids = recipes.map((recipe) => recipe.id).whereType<UuidValue>().toSet();
  if (ids.isEmpty) return recipes;

  final rows = await TeamRecipeFavorite.db.find(
    session,
    where: (t) => t.teamId.equals(teamId) & t.recipeId.inSet(ids),
  );
  final favoriteIds = rows.map((row) => row.recipeId).toSet();
  return [
    for (final recipe in recipes)
      recipe.copyWith(isFavorite: favoriteIds.contains(recipe.id)),
  ];
}

/// Deletes every team favorite for [recipeId]. Personal rows are left alone.
Future<void> deleteTeamFavoritesForRecipe(
  Session session,
  UuidValue recipeId, {
  Transaction? transaction,
}) async {
  final rows = await TeamRecipeFavorite.db.find(
    session,
    where: (t) => t.recipeId.equals(recipeId),
    transaction: transaction,
  );
  if (rows.isEmpty) return;
  await TeamRecipeFavorite.db.delete(
    session,
    rows,
    transaction: transaction,
  );
}

/// Saves [recipeId] as [teamId]'s favorite for its title.
///
/// When another team favorite already uses that title and [replace] is false,
/// nothing is written and [FavoriteSaveResult.saved] is false. The caller must
/// be an editor of [teamId], and the recipe must belong to that team.
Future<FavoriteSaveResult> saveTeamRecipeFavorite(
  Session session,
  UuidValue teamId,
  UuidValue recipeId,
  bool replace,
) async {
  try {
    return await session.db.transaction((transaction) async {
      final recipe = await _editableTeamRecipe(
        session,
        teamId,
        recipeId,
        transaction: transaction,
      );
      final titleKey = recipeTitleKey(recipe.title);
      final already = await TeamRecipeFavorite.db.findFirstRow(
        session,
        where: (t) => t.teamId.equals(teamId) & t.recipeId.equals(recipeId),
        transaction: transaction,
      );
      if (already != null) return FavoriteSaveResult(saved: true);

      final conflict = await TeamRecipeFavorite.db.findFirstRow(
        session,
        where: (t) => t.teamId.equals(teamId) & t.titleKey.equals(titleKey),
        transaction: transaction,
      );
      if (conflict != null && !replace) {
        return FavoriteSaveResult(saved: false);
      }
      if (conflict != null) {
        await TeamRecipeFavorite.db.deleteRow(
          session,
          conflict,
          transaction: transaction,
        );
      }
      await TeamRecipeFavorite.db.insertRow(
        session,
        TeamRecipeFavorite(
          teamId: teamId,
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
    final existing = await TeamRecipeFavorite.db.findFirstRow(
      session,
      where: (t) => t.teamId.equals(teamId) & t.recipeId.equals(recipeId),
    );
    if (existing != null) return FavoriteSaveResult(saved: true);
    return FavoriteSaveResult(saved: false);
  }
}

/// Removes [teamId]'s favorite for [recipeId]. Missing rows are a no-op.
Future<void> removeTeamRecipeFavorite(
  Session session,
  UuidValue teamId,
  UuidValue recipeId,
) async {
  await session.db.transaction((transaction) async {
    await _editableTeamRecipe(
      session,
      teamId,
      recipeId,
      transaction: transaction,
    );
    final existing = await TeamRecipeFavorite.db.findFirstRow(
      session,
      where: (t) => t.teamId.equals(teamId) & t.recipeId.equals(recipeId),
      transaction: transaction,
    );
    if (existing == null) return;
    await TeamRecipeFavorite.db.deleteRow(
      session,
      existing,
      transaction: transaction,
    );
  });
}

Future<Recipe> _editableTeamRecipe(
  Session session,
  UuidValue teamId,
  UuidValue recipeId, {
  Transaction? transaction,
}) async {
  final (recipe, _) = await RecipeAccessPolicy.load(
    session,
    recipeId,
    transaction: transaction,
  );
  final membership = await membershipOf(
    session,
    teamId,
    session.callerId,
    transaction: transaction,
  );
  if (membership == null || recipe.teamId != teamId) {
    throw recipeNotFound();
  }
  if (membership.role != TeamRole.editor) {
    throw recipeForbidden("Viewers can't change team favorites");
  }
  return recipe;
}
