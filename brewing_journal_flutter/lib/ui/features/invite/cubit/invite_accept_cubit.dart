import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/team_repository.dart';
import 'invite_accept_state.dart';

class InviteAcceptCubit extends Cubit<InviteAcceptState> {
  InviteAcceptCubit(this._teams) : super(const InviteAcceptState());

  final TeamRepository _teams;

  Future<void> accept(String token) async {
    emit(const InviteAcceptState());
    try {
      final team = await _teams.acceptInvite(token);
      if (isClosed) return;
      emit(
        InviteAcceptState(status: InviteAcceptStatus.success, team: team),
      );
    } on BrewingException catch (error) {
      if (isClosed) return;
      emit(
        InviteAcceptState(
          status: InviteAcceptStatus.failure,
          errorCode: error.code,
          error: error,
          team: error.code == BrewingErrorCode.alreadyMember
              ? await _teamFromAlreadyMember(error.message)
              : null,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        InviteAcceptState(status: InviteAcceptStatus.failure, error: error),
      );
    }
  }

  Future<TeamSummary?> _teamFromAlreadyMember(String message) async {
    try {
      final id = UuidValue.withValidation(message);
      final teams = await _teams.listMine();
      return teams.where((t) => t.team.id == id).firstOrNull;
    } catch (_) {
      return null;
    }
  }
}
