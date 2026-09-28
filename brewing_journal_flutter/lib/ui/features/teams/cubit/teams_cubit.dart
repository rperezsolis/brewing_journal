import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/team_repository.dart';
import 'teams_state.dart';

class TeamsCubit extends Cubit<TeamsState> {
  TeamsCubit(this._teams) : super(const TeamsState());

  final TeamRepository _teams;

  Future<void> load() async {
    emit(state.copyWith(status: TeamsStatus.loading));
    try {
      final teams = await _teams.listMine();
      if (isClosed) return;
      emit(
        TeamsState(
          status: TeamsStatus.success,
          teams: teams,
          recipeRevision: state.recipeRevision,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(state.copyWith(status: TeamsStatus.failure, error: error));
    }
  }

  void reset() => emit(const TeamsState());

  /// Tells mounted team-detail recipe lists to refetch.
  void recipesChanged() {
    emit(state.copyWith(recipeRevision: state.recipeRevision + 1));
  }

  Future<bool> create(String name) async {
    if (state.creating) return false;
    emit(state.copyWith(creating: true));
    try {
      final summary = await _teams.create(name);
      if (isClosed) return true;
      emit(
        state.copyWith(
          status: TeamsStatus.success,
          teams: [...state.teams, summary],
          creating: false,
        ),
      );
      return true;
    } catch (error) {
      if (isClosed) return false;
      emit(state.copyWith(creating: false, error: error));
      return false;
    }
  }

  Future<InviteLink?> createInvite(
    UuidValue teamId,
    TeamRole role,
    Duration ttl,
  ) async {
    if (state.creatingInvite) return null;
    emit(state.copyWith(creatingInvite: true, clearInvite: true));
    try {
      final invite = await _teams.createInvite(teamId, role, ttl);
      if (isClosed) return invite;
      emit(state.copyWith(creatingInvite: false, lastInvite: invite));
      return invite;
    } catch (error) {
      if (isClosed) return null;
      emit(state.copyWith(creatingInvite: false, error: error));
      return null;
    }
  }
}
