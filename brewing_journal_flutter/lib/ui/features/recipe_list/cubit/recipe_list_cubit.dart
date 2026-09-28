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
    emit(state.copyWith(status: RecipeListStatus.loading, loadingMore: false));
    try {
      final page = await _page(limit: pageSize, offset: 0);
      if (isClosed || generation != _generation) return;
      emit(
        RecipeListState(
          status: RecipeListStatus.success,
          recipes: page,
          hasMore: page.length == pageSize,
        ),
      );
    } catch (error) {
      if (isClosed || generation != _generation) return;
      emit(state.copyWith(status: RecipeListStatus.failure, error: error));
    }
  }

  /// Appends the next page.
  Future<void> loadMore() async {
    if (!state.hasMore ||
        state.loadingMore ||
        state.status != RecipeListStatus.success) {
      return;
    }
    final generation = _generation;
    emit(state.copyWith(loadingMore: true));
    try {
      final page = await _page(
        limit: pageSize,
        offset: state.recipes.length,
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

  Future<List<Recipe>> _page({required int limit, required int offset}) {
    final id = teamId;
    if (id != null) {
      return _recipes.listForTeam(id, limit: limit, offset: offset);
    }
    return _recipes.listMine(limit: limit, offset: offset);
  }
}
