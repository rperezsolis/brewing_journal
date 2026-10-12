import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/team_repository.dart';
import 'team_members_state.dart';

class TeamMembersCubit extends Cubit<TeamMembersState> {
  TeamMembersCubit(this._teams, {required this.teamId})
    : super(const TeamMembersState());

  final TeamRepository _teams;
  final UuidValue teamId;

  Future<void> load() async {
    emit(state.copyWith(status: TeamMembersStatus.loading, clearError: true));
    try {
      final members = await _teams.listMembers(teamId);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: TeamMembersStatus.success,
          members: members,
          clearError: true,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(state.copyWith(status: TeamMembersStatus.failure, error: error));
    }
  }

  /// Updates [member] to [role] and emails them in [locale].
  ///
  /// Returns false when a change is already in flight or the call fails.
  Future<bool> changeRole(
    TeamMember member,
    TeamRole role,
    String locale,
  ) async {
    final userId = member.userId;
    if (state.changingUserId != null) return false;
    emit(state.copyWith(changingUserId: userId, clearError: true));
    try {
      final updated = await _teams.changeMemberRole(
        teamId,
        userId,
        role,
        locale,
      );
      if (isClosed) return true;
      emit(
        state.copyWith(
          status: TeamMembersStatus.success,
          members: [
            for (final current in state.members)
              if (current.userId == updated.userId) updated else current,
          ],
          clearChanging: true,
          revision: state.revision + 1,
          clearError: true,
        ),
      );
      return true;
    } catch (error) {
      if (isClosed) return false;
      emit(state.copyWith(clearChanging: true, error: error));
      return false;
    }
  }
}
