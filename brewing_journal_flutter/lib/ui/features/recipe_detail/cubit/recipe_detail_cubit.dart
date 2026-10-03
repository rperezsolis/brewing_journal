import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/recipe_repository.dart';
import 'recipe_detail_state.dart';

/// Loads one recipe for Brew Mode. Does not mutate the recipe except [delete].
class RecipeDetailCubit extends Cubit<RecipeDetailState> {
  RecipeDetailCubit(this._recipes) : super(const RecipeDetailState());

  final RecipeRepository _recipes;

  Future<void> load(UuidValue id) async {
    emit(
      state.copyWith(
        status: RecipeDetailStatus.loading,
        recipeId: id,
        deleting: false,
      ),
    );
    try {
      final detail = await _recipes.get(id);
      if (isClosed) return;
      emit(
        RecipeDetailState(
          status: RecipeDetailStatus.success,
          recipeId: id,
          detail: detail,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(status: RecipeDetailStatus.failure, error: error),
      );
    }
  }

  /// Reloads the last [id], used after returning from the editor.
  Future<void> reload() async {
    final id = state.recipeId;
    if (id == null) return;
    await load(id);
  }

  /// Deletes the loaded recipe when the caller may. Returns `true` on success.
  Future<bool> delete() async {
    final detail = state.detail;
    final id = detail?.recipe.id;
    if (detail == null || id == null || !detail.access.canDelete) {
      return false;
    }
    emit(state.copyWith(deleting: true, error: null));
    try {
      await _recipes.delete(id);
      if (isClosed) return false;
      emit(state.copyWith(deleting: false));
      return true;
    } catch (error) {
      if (isClosed) return false;
      emit(state.copyWith(deleting: false, error: error));
      return false;
    }
  }

  Future<bool> assignToTeam(UuidValue teamId) async {
    final id = state.recipeId;
    if (id == null || state.assigning) return false;
    emit(state.copyWith(assigning: true, error: null));
    try {
      await _recipes.assignToTeam(id, teamId);
      if (isClosed) return false;
      await load(id);
      return true;
    } catch (error) {
      if (isClosed) return false;
      emit(state.copyWith(assigning: false, error: error));
      return false;
    }
  }

  Future<bool> removeFromTeam() async {
    final id = state.recipeId;
    if (id == null || state.assigning) return false;
    emit(state.copyWith(assigning: true, error: null));
    try {
      await _recipes.removeFromTeam(id);
      if (isClosed) return false;
      await load(id);
      return true;
    } catch (error) {
      if (isClosed) return false;
      emit(state.copyWith(assigning: false, error: error));
      return false;
    }
  }

  /// Saves the loaded recipe as a favorite for its name.
  ///
  /// When another favorite already uses that name and [replace] is false,
  /// nothing changes and [FavoriteSaveResult.saved] is false.
  Future<FavoriteSaveResult?> saveFavorite({bool replace = false}) async {
    final id = state.recipeId;
    final detail = state.detail;
    if (id == null || detail == null || state.favoriteBusy) return null;
    emit(state.copyWith(favoriteBusy: true));
    try {
      final result = await _recipes.saveFavorite(id, replace: replace);
      if (isClosed) return null;
      emit(
        state.copyWith(
          favoriteBusy: false,
          detail: result.saved ? _withFavorite(detail, true) : state.detail,
        ),
      );
      return result;
    } catch (error) {
      if (isClosed) return null;
      emit(state.copyWith(favoriteBusy: false, error: error));
      return null;
    }
  }

  /// Removes the loaded recipe from favorites. Returns false on failure.
  Future<bool> removeFavorite() async {
    final id = state.recipeId;
    final detail = state.detail;
    if (id == null || detail == null || state.favoriteBusy) return false;
    emit(state.copyWith(favoriteBusy: true));
    try {
      await _recipes.removeFavorite(id);
      if (isClosed) return false;
      emit(
        state.copyWith(
          favoriteBusy: false,
          detail: _withFavorite(detail, false),
        ),
      );
      return true;
    } catch (error) {
      if (isClosed) return false;
      emit(state.copyWith(favoriteBusy: false, error: error));
      return false;
    }
  }
}

RecipeDetail _withFavorite(RecipeDetail detail, bool isFavorite) {
  return detail.copyWith(
    recipe: detail.recipe.copyWith(isFavorite: isFavorite),
  );
}
