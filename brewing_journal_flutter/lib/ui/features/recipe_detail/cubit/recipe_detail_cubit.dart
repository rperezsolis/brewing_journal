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
}
