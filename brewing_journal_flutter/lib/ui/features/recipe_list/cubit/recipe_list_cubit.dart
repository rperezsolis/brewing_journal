import 'dart:async';

import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/recipe_repository.dart';
import 'recipe_list_state.dart';

/// A paged list of recipes, most recently updated first.
class RecipeListCubit extends Cubit<RecipeListState> {
  RecipeListCubit(this._recipes, {this.teamId, this.pageSize = 20})
    : super(const RecipeListState());

  final RecipeRepository _recipes;
  final UuidValue? teamId;
  final int pageSize;

  /// Bumped by [load] and [reset], so a page requested before either of them
  /// is dropped when it arrives.
  int _generation = 0;

  /// Loads the first page, replacing the list.
  Future<void> load() async {
    final generation = ++_generation;
    final favoritesOnly = state.favoritesOnly;
    emit(state.copyWith(status: RecipeListStatus.loading, loadingMore: false));
    try {
      final page = await _page(
        limit: pageSize,
        offset: 0,
        favoritesOnly: favoritesOnly,
      );
      if (isClosed || generation != _generation) return;
      emit(
        state.copyWith(
          status: RecipeListStatus.success,
          recipes: page,
          hasMore: page.length == pageSize,
          loadingMore: false,
          favoritesOnly: favoritesOnly,
        ),
      );
    } catch (error) {
      if (isClosed || generation != _generation) return;
      emit(state.copyWith(status: RecipeListStatus.failure, error: error));
    }
  }

  /// Reloads from the first page, showing only favorites or every recipe.
  Future<void> setFavoritesOnly(bool value) async {
    if (state.favoritesOnly == value) return;
    emit(
      state.copyWith(
        favoritesOnly: value,
        status: RecipeListStatus.loading,
        recipes: const [],
        hasMore: false,
        loadingMore: false,
      ),
    );
    await load();
  }

  /// Appends the next page.
  Future<void> loadMore() async {
    if (!state.hasMore ||
        state.loadingMore ||
        state.status != RecipeListStatus.success) {
      return;
    }
    final generation = _generation;
    final favoritesOnly = state.favoritesOnly;
    emit(state.copyWith(loadingMore: true));
    try {
      final page = await _page(
        limit: pageSize,
        offset: state.recipes.length,
        favoritesOnly: favoritesOnly,
      );
      if (isClosed || generation != _generation) return;
      emit(
        state.copyWith(
          recipes: [...state.recipes, ...page],
          hasMore: page.length == pageSize,
          loadingMore: false,
        ),
      );
    } catch (error) {
      if (isClosed || generation != _generation) return;
      emit(state.copyWith(loadingMore: false, error: error));
    }
  }

  /// Empties the list, e.g. on sign-out, so the next account never sees it.
  void reset() {
    _generation++;
    emit(const RecipeListState());
  }

  /// Saves [id] as a favorite. A name conflict leaves the list unchanged and
  /// returns [FavoriteSaveResult.saved] false.
  Future<FavoriteSaveResult?> saveFavorite(
    UuidValue id, {
    bool replace = false,
  }) async {
    if (state.favoriteBusyIds.contains(id)) return null;
    emit(state.copyWith(favoriteBusyIds: {...state.favoriteBusyIds, id}));
    try {
      final result = teamId == null
          ? await _recipes.saveFavorite(id, replace: replace)
          : await _recipes.saveTeamFavorite(teamId!, id, replace: replace);
      if (isClosed) return null;
      if (result.saved) {
        _emitFavorite(
          id,
          isFavorite: true,
          replacedRecipeId: result.replacedRecipeId,
          reloadWhenMissing: true,
        );
      } else {
        _emitFavorite(id, isFavorite: false, apply: false);
      }
      return result;
    } catch (error) {
      if (isClosed) return null;
      _emitFavorite(id, isFavorite: false, error: error, apply: false);
      return null;
    }
  }

  /// Removes [id] from favorites. Returns false when the request fails.
  Future<bool> removeFavorite(UuidValue id) async {
    if (state.favoriteBusyIds.contains(id)) return false;
    emit(state.copyWith(favoriteBusyIds: {...state.favoriteBusyIds, id}));
    try {
      final team = teamId;
      if (team == null) {
        await _recipes.removeFavorite(id);
      } else {
        await _recipes.removeTeamFavorite(team, id);
      }
      if (isClosed) return false;
      _emitFavorite(id, isFavorite: false);
      return true;
    } catch (error) {
      if (isClosed) return false;
      _emitFavorite(id, isFavorite: false, error: error, apply: false);
      return false;
    }
  }

  /// Updates flags already stored by another cubit, without calling the server.
  void noteFavorite({
    required UuidValue recipeId,
    required bool isFavorite,
    UuidValue? replacedRecipeId,
  }) {
    _emitFavorite(
      recipeId,
      isFavorite: isFavorite,
      replacedRecipeId: replacedRecipeId,
      reloadWhenMissing: isFavorite,
      busy: false,
    );
  }

  Future<List<Recipe>> _page({
    required int limit,
    required int offset,
    required bool favoritesOnly,
  }) {
    final id = teamId;
    if (id != null) {
      if (favoritesOnly) {
        return _recipes.listTeamFavorites(id, limit: limit, offset: offset);
      }
      return _recipes.listForTeam(id, limit: limit, offset: offset);
    }
    return _recipes.listMine(
      limit: limit,
      offset: offset,
      favoritesOnly: favoritesOnly,
    );
  }

  void _emitFavorite(
    UuidValue id, {
    required bool isFavorite,
    UuidValue? replacedRecipeId,
    bool reloadWhenMissing = false,
    bool busy = true,
    Object? error,
    bool apply = true,
  }) {
    final busyIds = {...state.favoriteBusyIds};
    if (busy) busyIds.remove(id);
    final missing =
        apply &&
        reloadWhenMissing &&
        state.favoritesOnly &&
        !state.recipes.any((recipe) => recipe.id == id);
    emit(
      state.copyWith(
        favoriteBusyIds: busyIds,
        recipes: !apply || missing
            ? state.recipes
            : _withFavoriteFlag(
                state.recipes,
                recipeId: id,
                isFavorite: isFavorite,
                replacedRecipeId: replacedRecipeId,
                dropUnfavorited: state.favoritesOnly,
              ),
        error: error,
      ),
    );
    if (missing) unawaited(load());
  }
}

List<Recipe> _withFavoriteFlag(
  List<Recipe> recipes, {
  required UuidValue recipeId,
  required bool isFavorite,
  UuidValue? replacedRecipeId,
  required bool dropUnfavorited,
}) {
  final next = <Recipe>[];
  for (final recipe in recipes) {
    if (recipe.id == recipeId) {
      if (dropUnfavorited && !isFavorite) continue;
      next.add(recipe.copyWith(isFavorite: isFavorite));
    } else if (recipe.id == replacedRecipeId) {
      if (dropUnfavorited) continue;
      next.add(recipe.copyWith(isFavorite: false));
    } else {
      next.add(recipe);
    }
  }
  return next;
}
