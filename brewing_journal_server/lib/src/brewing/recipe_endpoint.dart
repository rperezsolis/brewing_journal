import 'package:serverpod/serverpod.dart';

import '../common/authenticated_endpoint.dart';
import '../common/session_auth.dart';
import '../generated/protocol.dart';
import 'recipe_access_policy.dart';
import 'recipe_storage.dart';
import 'recipe_validator.dart';

class RecipeEndpoint extends AuthenticatedEndpoint {
  /// Inserts (`draft.id == null`) or updates a recipe. Instructions and flavor
  /// tags are replaced in full, in the same transaction as the recipe row.
  Future<RecipeDetail> save(Session session, RecipeDraft draft) async {
    final callerId = session.callerId;

    final recipeId = await session.db.transaction((tx) async {
      final draftId = draft.id;
      final existing = draftId == null
          ? null
          : await RecipeAccessPolicy.loadForEdit(
              session,
              draftId,
              transaction: tx,
            );

      final ingredient = await Ingredient.db.findById(
        session,
        draft.ingredientId,
        transaction: tx,
      );
      final canUseIngredient =
          ingredient != null &&
          (ingredient.ownerId == callerId ||
              existing?.ingredientId == ingredient.id);
      if (!canUseIngredient) {
        throw BrewingException(
          code: BrewingErrorCode.notFound,
          message: 'Ingredient not found',
        );
      }

      final valid = validateRecipeDraft(draft);

      final Recipe saved;
      if (existing == null) {
        saved = await Recipe.db.insertRow(
          session,
          Recipe(
            ownerId: callerId,
            ingredientId: ingredient.id!,
            title: valid.title,
            waterTempC: draft.waterTempC,
            doseGrams: draft.doseGrams,
            grindSize: valid.grindSize,
            grinderModel: valid.grinderModel,
            extractionMethod: draft.extractionMethod,
            extractionMethodNote: valid.extractionMethodNote,
            extractionDuration: draft.extractionDuration,
            acidity: draft.acidity,
            sweetness: draft.sweetness,
            body: draft.body,
            bitterness: draft.bitterness,
          ),
          transaction: tx,
        );
      } else {
        saved = await Recipe.db.updateRow(
          session,
          existing.copyWith(
            ingredientId: ingredient.id!,
            title: valid.title,
            waterTempC: draft.waterTempC,
            doseGrams: draft.doseGrams,
            grindSize: valid.grindSize,
            grinderModel: valid.grinderModel,
            extractionMethod: draft.extractionMethod,
            extractionMethodNote: valid.extractionMethodNote,
            extractionDuration: draft.extractionDuration,
            acidity: draft.acidity,
            sweetness: draft.sweetness,
            body: draft.body,
            bitterness: draft.bitterness,
            updatedAt: DateTime.now().toUtc(),
          ),
          transaction: tx,
        );
      }
      final id = saved.id!;

      await RecipeInstruction.db.deleteWhere(
        session,
        where: (t) => t.recipeId.equals(id),
        transaction: tx,
      );
      await RecipeFlavorTag.db.deleteWhere(
        session,
        where: (t) => t.recipeId.equals(id),
        transaction: tx,
      );
      if (valid.instructions.isNotEmpty) {
        await RecipeInstruction.db.insert(session, [
          for (final (index, text) in valid.instructions.indexed)
            RecipeInstruction(recipeId: id, sortOrder: index, text: text),
        ], transaction: tx);
      }
      if (valid.tags.isNotEmpty) {
        await RecipeFlavorTag.db.insert(session, [
          for (final tag in valid.tags)
            RecipeFlavorTag(recipeId: id, tag: tag, tagKey: tagKeyOf(tag)),
        ], transaction: tx);
      }
      return id;
    });

    return get(session, recipeId);
  }

  /// The recipe with its ingredient, ordered instructions, tags, photos (with
  /// `publicUrl`), and the caller's access.
  Future<RecipeDetail> get(Session session, UuidValue id) async {
    final recipe = await Recipe.db.findById(
      session,
      id,
      include: Recipe.include(
        ingredient: Ingredient.include(),
        instructions: RecipeInstruction.includeList(
          orderBy: (t) => t.sortOrder,
        ),
        flavorTags: RecipeFlavorTag.includeList(orderBy: (t) => t.tagKey),
        photos: RecipePhoto.includeList(orderBy: (t) => t.sortOrder),
      ),
    );
    if (recipe == null) throw recipeNotFound();
    final access = await RecipeAccessPolicy.resolve(session, recipe);

    final detail = RecipeDetail(
      recipe: recipe,
      ingredient: recipe.ingredient!,
      instructions: recipe.instructions ?? [],
      flavorTags: recipe.flavorTags ?? [],
      photos: await withPublicUrls(session, recipe.photos ?? []),
      access: access,
    );
    recipe
      ..ingredient = null
      ..instructions = null
      ..flavorTags = null
      ..photos = null;
    return detail;
  }

  /// The caller's own recipes, most recently updated first.
  Future<List<Recipe>> listMine(Session session, int limit, int offset) {
    return Recipe.db.find(
      session,
      where: (t) => t.ownerId.equals(session.callerId),
      orderByList: (t) => [t.updatedAt.desc(), t.id.desc()],
      limit: limit.clamp(1, 50),
      offset: offset < 0 ? 0 : offset,
      include: Recipe.include(ingredient: Ingredient.include()),
    );
  }

  Future<RecipeAccess> getAccess(Session session, UuidValue id) async {
    final (_, access) = await RecipeAccessPolicy.load(session, id);
    return access;
  }

  /// Deletes the recipe and its child rows; photo files are removed
  /// best-effort after the delete commits.
  Future<void> delete(Session session, UuidValue id) async {
    final paths = await session.db.transaction((tx) async {
      final (recipe, access) = await RecipeAccessPolicy.load(
        session,
        id,
        transaction: tx,
      );
      if (!access.canDelete) {
        throw BrewingException(
          code: BrewingErrorCode.forbidden,
          message: "You can't delete this recipe",
        );
      }
      final photos = await RecipePhoto.db.find(
        session,
        where: (t) => t.recipeId.equals(id),
        transaction: tx,
      );
      await Recipe.db.deleteRow(session, recipe, transaction: tx);
      return [for (final photo in photos) photo.storagePath];
    });
    await deletePhotoFiles(session, paths);
  }
}
