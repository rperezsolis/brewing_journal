import 'package:serverpod/serverpod.dart';

import '../common/session_auth.dart';
import '../generated/protocol.dart';

BrewingException recipeNotFound() => BrewingException(
  code: BrewingErrorCode.notFound,
  message: 'Recipe not found',
);

/// The single authorization check for recipe reads and writes.
abstract final class RecipeAccessPolicy {
  /// Returns the caller's access to [recipe], or throws `notFound` when the
  /// caller cannot read it, so other users' recipe ids are never confirmed.
  static Future<RecipeAccess> resolve(
    Session session,
    Recipe recipe, {
    Transaction? transaction,
  }) async {
    if (recipe.ownerId == session.callerId) {
      return RecipeAccess(canEdit: true, canDelete: true);
    }
    throw recipeNotFound();
  }

  /// Loads the recipe [id] and resolves the caller's access to it.
  static Future<(Recipe, RecipeAccess)> load(
    Session session,
    UuidValue id, {
    Transaction? transaction,
  }) async {
    final recipe = await Recipe.db.findById(
      session,
      id,
      transaction: transaction,
    );
    if (recipe == null) throw recipeNotFound();
    final access = await resolve(session, recipe, transaction: transaction);
    return (recipe, access);
  }

  /// Like [load], but throws `forbidden` when the caller can only read.
  static Future<Recipe> loadForEdit(
    Session session,
    UuidValue id, {
    Transaction? transaction,
  }) async {
    final (recipe, access) = await load(session, id, transaction: transaction);
    if (!access.canEdit) {
      throw BrewingException(
        code: BrewingErrorCode.forbidden,
        message: "You can't edit this recipe",
      );
    }
    return recipe;
  }
}
