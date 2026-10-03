import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:equatable/equatable.dart';

enum RecipeListStatus { initial, loading, success, failure }

class RecipeListState extends Equatable {
  const RecipeListState({
    this.status = RecipeListStatus.initial,
    this.recipes = const [],
    this.hasMore = false,
    this.loadingMore = false,
    this.favoritesOnly = false,
    this.favoriteBusyIds = const <UuidValue>{},
    this.error,
  });

  final RecipeListStatus status;
  final List<Recipe> recipes;
  final bool hasMore;
  final bool loadingMore;

  /// When true, [recipes] is the caller's favorite recipes only.
  final bool favoritesOnly;

  /// Recipes whose favorite toggle is waiting on the server.
  final Set<UuidValue> favoriteBusyIds;
  final Object? error;

  RecipeListState copyWith({
    RecipeListStatus? status,
    List<Recipe>? recipes,
    bool? hasMore,
    bool? loadingMore,
    bool? favoritesOnly,
    Set<UuidValue>? favoriteBusyIds,
    Object? error,
  }) {
    return RecipeListState(
      status: status ?? this.status,
      recipes: recipes ?? this.recipes,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      favoriteBusyIds: favoriteBusyIds ?? this.favoriteBusyIds,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    status,
    recipes,
    hasMore,
    loadingMore,
    favoritesOnly,
    favoriteBusyIds,
    error,
  ];
}
