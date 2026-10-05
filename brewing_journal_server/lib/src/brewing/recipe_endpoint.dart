import 'package:serverpod/serverpod.dart';

import '../common/authenticated_endpoint.dart';
import '../common/session_auth.dart';
import '../generated/protocol.dart';
import '../teams/team_membership_lookup.dart';
import 'recipe_access_policy.dart';
import 'recipe_limits.dart';
import 'recipe_authors.dart';
import 'recipe_favorites.dart';
import 'recipe_storage.dart';
import 'recipe_validator.dart';
import 'team_recipe_favorites.dart';

class RecipeEndpoint extends AuthenticatedEndpoint {
  /// Inserts a recipe. When [draft.id] is set, that recipe is the source of a
  /// new version: the caller must be allowed to edit it, the new row keeps
  /// its team and photos, and the source row is left unchanged.
  Future<RecipeDetail> save(Session session, RecipeDraft draft) async {
    final callerId = session.callerId;
    final sourceId = draft.id;
    final source = sourceId == null
        ? null
        : await RecipeAccessPolicy.loadForEdit(session, sourceId);

    final newId = source == null ? null : const Uuid().v7obj();
    final photoCopies = source == null
        ? const <RecipePhoto>[]
        : await copyRecipePhotos(
            session,
            fromRecipeId: source.id!,
            toRecipeId: newId!,
          );

    final UuidValue recipeId;
    try {
      recipeId = await session.db.transaction((tx) async {
        if (sourceId != null) {
          await RecipeAccessPolicy.loadForEdit(
            session,
            sourceId,
            transaction: tx,
          );
        }

        final ingredient = await Ingredient.db.findById(
          session,
          draft.ingredientId,
          transaction: tx,
        );
        final canUseIngredient =
            ingredient != null &&
            (ingredient.ownerId == callerId ||
                source?.ingredientId == ingredient.id);
        if (!canUseIngredient) {
          throw BrewingException(
            code: BrewingErrorCode.notFound,
            message: 'Ingredient not found',
          );
        }

        final valid = validateRecipeDraft(draft);

        final UuidValue? teamId;
        if (source == null) {
          teamId = draft.teamId;
          if (teamId != null) {
            final membership = await membershipOf(
              session,
              teamId,
              callerId,
              transaction: tx,
            );
            if (membership?.role != TeamRole.editor) {
              throw recipeForbidden("You can't add a recipe to this team");
            }
          }
        } else {
          teamId = source.teamId;
        }

        final saved = await Recipe.db.insertRow(
          session,
          Recipe(
            id: newId,
            ownerId: callerId,
            teamId: teamId,
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
        final id = saved.id!;

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
        if (photoCopies.isNotEmpty) {
          await RecipePhoto.db.insert(
            session,
            photoCopies,
            transaction: tx,
          );
        }
        return id;
      });
    } catch (error) {
      await deletePhotoFiles(session, [
        for (final photo in photoCopies) photo.storagePath,
      ]);
      rethrow;
    }

    return get(session, recipeId);
  }

  /// The recipe with its ingredient, ordered instructions, tags, photos (with
  /// `publicUrl`), and the caller's access.
  ///
  /// [teamId] null fills [Recipe.isFavorite] from the caller's personal rows.
  /// Set fills it from that team's rows. The caller must be a member and the
  /// recipe must be on that team.
  Future<RecipeDetail> get(
    Session session,
    UuidValue id, {
    UuidValue? teamId,
  }) async {
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
    if (teamId != null) {
      if (recipe.teamId != teamId) throw recipeNotFound();
      final membership = await membershipOf(session, teamId, session.callerId);
      if (membership == null) throw recipeNotFound();
    }

    final named = (await withAuthorNames(session, [recipe])).single;
    final flagged = teamId == null
        ? (await withFavoriteFlags(session, [named])).single
        : (await withTeamFavoriteFlags(session, teamId, [named])).single;
    final detail = RecipeDetail(
      recipe: flagged,
      ingredient: recipe.ingredient!,
      instructions: recipe.instructions ?? [],
      flavorTags: recipe.flavorTags ?? [],
      photos: await withPublicUrls(session, recipe.photos ?? []),
      access: access,
    );
    flagged
      ..ingredient = null
      ..instructions = null
      ..flavorTags = null
      ..photos = null;
    return detail;
  }

  /// The caller's own recipes, most recently updated first.
  Future<List<Recipe>> listMine(Session session, int limit, int offset) async {
    final recipes = await Recipe.db.find(
      session,
      where: (t) => t.ownerId.equals(session.callerId),
      orderByList: (t) => [t.updatedAt.desc(), t.id.desc()],
      limit: limit.clamp(1, 50),
      offset: offset < 0 ? 0 : offset,
      include: Recipe.include(ingredient: Ingredient.include()),
    );
    return _withPersonalFields(session, recipes);
  }

  /// The caller's own recipes that are in favorites, most recently updated first.
  Future<List<Recipe>> listFavorites(
    Session session,
    int limit,
    int offset,
  ) async {
    final callerId = session.callerId;
    final marks = await RecipeFavorite.db.find(
      session,
      where: (t) => t.userId.equals(callerId),
    );
    if (marks.isEmpty) return [];
    final recipes = await Recipe.db.find(
      session,
      where: (t) =>
          t.ownerId.equals(callerId) &
          t.id.inSet(marks.map((mark) => mark.recipeId).toSet()),
      orderByList: (t) => [t.updatedAt.desc(), t.id.desc()],
      limit: limit.clamp(1, 50),
      offset: offset < 0 ? 0 : offset,
      include: Recipe.include(ingredient: Ingredient.include()),
    );
    return _withPersonalFields(session, recipes);
  }

  /// Team recipes the team has saved, most recently updated first.
  /// Membership required.
  Future<List<Recipe>> listTeamFavorites(
    Session session,
    UuidValue teamId,
    int limit,
    int offset,
  ) async {
    final membership = await membershipOf(session, teamId, session.callerId);
    if (membership == null) throw recipeNotFound();
    final marks = await TeamRecipeFavorite.db.find(
      session,
      where: (t) => t.teamId.equals(teamId),
    );
    if (marks.isEmpty) return [];
    final recipes = await Recipe.db.find(
      session,
      where: (t) =>
          t.teamId.equals(teamId) &
          t.id.inSet(marks.map((mark) => mark.recipeId).toSet()),
      orderByList: (t) => [t.updatedAt.desc(), t.id.desc()],
      limit: limit.clamp(1, 50),
      offset: offset < 0 ? 0 : offset,
      include: Recipe.include(ingredient: Ingredient.include()),
    );
    return _withTeamFields(session, teamId, recipes);
  }

  /// Saves [recipeId] as the caller's favorite for its title.
  ///
  /// When another favorite already uses that title and [replace] is false,
  /// nothing changes and [FavoriteSaveResult.saved] is false.
  Future<FavoriteSaveResult> saveFavorite(
    Session session,
    UuidValue recipeId,
    bool replace,
  ) => saveRecipeFavorite(session, recipeId, replace);

  /// Removes [recipeId] from the caller's favorites.
  Future<void> removeFavorite(Session session, UuidValue recipeId) =>
      removeRecipeFavorite(session, recipeId);

  /// Saves [recipeId] as [teamId]'s favorite for its title.
  Future<FavoriteSaveResult> saveTeamFavorite(
    Session session,
    UuidValue teamId,
    UuidValue recipeId,
    bool replace,
  ) => saveTeamRecipeFavorite(session, teamId, recipeId, replace);

  /// Removes [recipeId] from [teamId]'s favorites.
  Future<void> removeTeamFavorite(
    Session session,
    UuidValue teamId,
    UuidValue recipeId,
  ) => removeTeamRecipeFavorite(session, teamId, recipeId);

  Future<RecipeAccess> getAccess(Session session, UuidValue id) async {
    final (_, access) = await RecipeAccessPolicy.load(session, id);
    return access;
  }

  /// Grinder models from the caller's recipes and from recipes on the
  /// caller's teams. One spelling per folded name, from the newest recipe.
  Future<List<String>> listGrinderModels(
    Session session,
    String query,
    int limit,
  ) async {
    final capped = limit.clamp(1, 30);
    final pattern = '${_escapeLike(query.trim().toLowerCase())}%';
    final callerId = session.callerId;
    final teamIds = await teamIdsOf(session, callerId);

    final recipes = await Recipe.db.find(
      session,
      where: (t) {
        final name = t.grinderModel.ilike(pattern);
        final mine = t.ownerId.equals(callerId);
        if (teamIds.isEmpty) return mine & name;
        return (mine | t.teamId.inSet(teamIds)) & name;
      },
      orderByList: (t) => [t.updatedAt.desc(), t.id.desc()],
      limit: kCatalogScanLimit,
    );

    final spelling = <String, String>{};
    final onTeam = <String>{};
    for (final recipe in recipes) {
      final model = recipe.grinderModel.trim();
      final key = model.toLowerCase();
      spelling.putIfAbsent(key, () => model);
      if (recipe.teamId != null && teamIds.contains(recipe.teamId)) {
        onTeam.add(key);
      }
    }
    final ordered = spelling.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final shared = [
      for (final entry in ordered)
        if (onTeam.contains(entry.key)) entry,
    ];
    final personal = [
      for (final entry in ordered)
        if (!onTeam.contains(entry.key)) entry,
    ];
    final sharedKept = shared.take(capped).toList();
    final kept = [
      ...sharedKept,
      ...personal.take(capped - sharedKept.length),
    ]..sort((a, b) => a.key.compareTo(b.key));
    return [for (final entry in kept) entry.value];
  }

  /// Team recipes, most recently updated first. Membership required.
  Future<List<Recipe>> listForTeam(
    Session session,
    UuidValue teamId,
    int limit,
    int offset,
  ) async {
    final membership = await membershipOf(session, teamId, session.callerId);
    if (membership == null) throw recipeNotFound();
    final recipes = await Recipe.db.find(
      session,
      where: (t) => t.teamId.equals(teamId),
      orderByList: (t) => [t.updatedAt.desc(), t.id.desc()],
      limit: limit.clamp(1, 50),
      offset: offset < 0 ? 0 : offset,
      include: Recipe.include(ingredient: Ingredient.include()),
    );
    return _withTeamFields(session, teamId, recipes);
  }

  /// Moves a personal recipe the caller owns onto a team they edit.
  Future<Recipe> assignToTeam(
    Session session,
    UuidValue recipeId,
    UuidValue teamId,
  ) async {
    final (recipe, _) = await RecipeAccessPolicy.load(session, recipeId);
    if (recipe.ownerId != session.callerId) throw recipeNotFound();
    final membership = await membershipOf(session, teamId, session.callerId);
    if (membership?.role != TeamRole.editor) {
      throw recipeForbidden("You can't add a recipe to this team");
    }
    final updated = await session.db.transaction((transaction) async {
      await deleteTeamFavoritesForRecipe(
        session,
        recipeId,
        transaction: transaction,
      );
      return Recipe.db.updateRow(
        session,
        recipe.copyWith(teamId: teamId, updatedAt: DateTime.now().toUtc()),
        transaction: transaction,
      );
    });
    return (await withFavoriteFlags(session, [updated])).single;
  }

  /// Clears `teamId`. The recipe owner or a team editor may do this.
  Future<Recipe> removeFromTeam(Session session, UuidValue recipeId) async {
    final (recipe, access) = await RecipeAccessPolicy.load(session, recipeId);
    final isOwner = recipe.ownerId == session.callerId;
    final isTeamEditor = access.role == TeamRole.editor;
    if (!isOwner && !isTeamEditor) {
      throw recipeForbidden("You can't remove this recipe from the team");
    }
    final updated = await session.db.transaction((transaction) async {
      await deleteTeamFavoritesForRecipe(
        session,
        recipeId,
        transaction: transaction,
      );
      return Recipe.db.updateRow(
        session,
        recipe.copyWith(teamId: null, updatedAt: DateTime.now().toUtc()),
        transaction: transaction,
      );
    });
    return (await withFavoriteFlags(session, [updated])).single;
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

  Future<List<Recipe>> _withPersonalFields(
    Session session,
    List<Recipe> recipes,
  ) async {
    final named = await withAuthorNames(session, recipes);
    return withFavoriteFlags(session, named);
  }

  Future<List<Recipe>> _withTeamFields(
    Session session,
    UuidValue teamId,
    List<Recipe> recipes,
  ) async {
    final named = await withAuthorNames(session, recipes);
    return withTeamFavoriteFlags(session, teamId, named);
  }
}

/// PostgreSQL's default LIKE escape character is a backslash.
String _escapeLike(String value) =>
    value.replaceAllMapped(RegExp(r'[\\%_]'), (m) => '\\${m[0]}');
