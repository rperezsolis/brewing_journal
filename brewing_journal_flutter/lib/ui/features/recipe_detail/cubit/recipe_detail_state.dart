import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:equatable/equatable.dart';

enum RecipeDetailStatus { initial, loading, success, failure }

class RecipeDetailState extends Equatable {
  const RecipeDetailState({
    this.status = RecipeDetailStatus.initial,
    this.recipeId,
    this.detail,
    this.error,
    this.deleting = false,
  });

  final RecipeDetailStatus status;
  final UuidValue? recipeId;
  final RecipeDetail? detail;
  final Object? error;
  final bool deleting;

  RecipeDetailState copyWith({
    RecipeDetailStatus? status,
    UuidValue? recipeId,
    RecipeDetail? detail,
    Object? error,
    bool? deleting,
  }) {
    return RecipeDetailState(
      status: status ?? this.status,
      recipeId: recipeId ?? this.recipeId,
      detail: detail ?? this.detail,
      error: error,
      deleting: deleting ?? this.deleting,
    );
  }

  @override
  List<Object?> get props => [status, recipeId, detail, error, deleting];
}
