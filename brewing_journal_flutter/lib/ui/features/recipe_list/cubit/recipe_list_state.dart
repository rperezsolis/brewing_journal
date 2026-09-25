import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:equatable/equatable.dart';

enum RecipeListStatus { initial, loading, success, failure }

class RecipeListState extends Equatable {
  const RecipeListState({
    this.status = RecipeListStatus.initial,
    this.recipes = const [],
    this.hasMore = false,
    this.loadingMore = false,
    this.error,
  });

  final RecipeListStatus status;
  final List<Recipe> recipes;
  final bool hasMore;
  final bool loadingMore;
  final Object? error;

  RecipeListState copyWith({
    RecipeListStatus? status,
    List<Recipe>? recipes,
    bool? hasMore,
    bool? loadingMore,
    Object? error,
  }) {
    return RecipeListState(
      status: status ?? this.status,
      recipes: recipes ?? this.recipes,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, recipes, hasMore, loadingMore, error];
}
