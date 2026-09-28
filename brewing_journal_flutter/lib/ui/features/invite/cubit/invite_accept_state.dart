import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:equatable/equatable.dart';

enum InviteAcceptStatus { accepting, success, failure }

class InviteAcceptState extends Equatable {
  const InviteAcceptState({
    this.status = InviteAcceptStatus.accepting,
    this.team,
    this.errorCode,
    this.error,
  });

  final InviteAcceptStatus status;
  final TeamSummary? team;
  final BrewingErrorCode? errorCode;
  final Object? error;

  @override
  List<Object?> get props => [status, team, errorCode, error];
}
