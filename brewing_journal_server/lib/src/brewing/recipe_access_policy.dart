import 'package:serverpod/serverpod.dart';

import '../common/session_auth.dart';
import '../generated/protocol.dart';
import '../teams/team_membership_lookup.dart';

BrewingException recipeNotFound() => BrewingException(
  code: BrewingErrorCode.notFound,
  message: 'Recipe not found',
);

BrewingException recipeForbidden([String? message]) => BrewingException(
  code: BrewingErrorCode.forbidden,
  message: message ?? "You can't edit this recipe",
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
    final callerId = session.callerId;
    final isOwner = recipe.ownerId == callerId;
    final teamId = recipe.teamId;
    final membership = teamId == null
        ? null
        : await membershipOf(
            session,
            teamId,
            callerId,
            transaction: transaction,
          );

    if (isOwner) {
      return RecipeAccess(
        role: membership?.role,
        canEdit: true,
        canDelete: true,
      );
    }
    if (membership == null) throw recipeNotFound();
    return RecipeAccess(
      role: membership.role,
      canEdit: membership.role == TeamRole.editor,
      canDelete: false,
    );
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
      throw recipeForbidden();
    }
    return recipe;
  }
}
