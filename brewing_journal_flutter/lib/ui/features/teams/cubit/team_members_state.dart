import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:equatable/equatable.dart';

enum TeamMembersStatus { initial, loading, success, failure }

class TeamMembersState extends Equatable {
  const TeamMembersState({
    this.status = TeamMembersStatus.initial,
    this.members = const [],
    this.changingUserId,
    this.revision = 0,
    this.error,
  });

  final TeamMembersStatus status;
  final List<TeamMember> members;

  /// The member whose role change is in flight.
  final UuidValue? changingUserId;

  /// Bumped after a role change so the screen can refresh the signed-in role.
  final int revision;
  final Object? error;

  TeamMembersState copyWith({
    TeamMembersStatus? status,
    List<TeamMember>? members,
    UuidValue? changingUserId,
    int? revision,
    Object? error,
    bool clearChanging = false,
    bool clearError = false,
  }) {
    return TeamMembersState(
      status: status ?? this.status,
      members: members ?? this.members,
      changingUserId: clearChanging
          ? null
          : changingUserId ?? this.changingUserId,
      revision: revision ?? this.revision,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    status,
    members,
    changingUserId,
    revision,
    error,
  ];
}
