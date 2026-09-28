import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:equatable/equatable.dart';

enum TeamsStatus { initial, loading, success, failure }

class TeamsState extends Equatable {
  const TeamsState({
    this.status = TeamsStatus.initial,
    this.teams = const [],
    this.lastInvite,
    this.creating = false,
    this.creatingInvite = false,
    this.recipeRevision = 0,
    this.error,
  });

  final TeamsStatus status;
  final List<TeamSummary> teams;
  final InviteLink? lastInvite;
  final bool creating;
  final bool creatingInvite;

  /// Bumped when a recipe is added to or removed from a team so mounted
  /// team-detail lists can reload. The personal [RecipeListCubit] is
  /// session-scoped and cannot see those team-scoped cubits.
  final int recipeRevision;
  final Object? error;

  TeamSummary? teamById(UuidValue id) =>
      teams.where((t) => t.team.id == id).firstOrNull;

  TeamsState copyWith({
    TeamsStatus? status,
    List<TeamSummary>? teams,
    InviteLink? lastInvite,
    bool? creating,
    bool? creatingInvite,
    int? recipeRevision,
    Object? error,
    bool clearInvite = false,
  }) {
    return TeamsState(
      status: status ?? this.status,
      teams: teams ?? this.teams,
      lastInvite: clearInvite ? null : lastInvite ?? this.lastInvite,
      creating: creating ?? this.creating,
      creatingInvite: creatingInvite ?? this.creatingInvite,
      recipeRevision: recipeRevision ?? this.recipeRevision,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    status,
    teams,
    lastInvite,
    creating,
    creatingInvite,
    recipeRevision,
    error,
  ];
}
