import 'package:brewing_journal_client/brewing_journal_client.dart';

import 'team_repository.dart';

class _Invite {
  _Invite(this.link, this.teamId);

  final InviteLink link;
  final UuidValue teamId;
  DateTime? usedAt;
}

/// In-memory [TeamRepository] for tests and previews.
class FakeTeamRepository implements TeamRepository {
  final List<TeamSummary> teams = [];
  final Map<String, _Invite> _invites = {};

  /// When set, the next call throws it once.
  Object? nextError;

  /// The caller id recorded as `team.ownerId` on [create].
  UuidValue ownerId = const Uuid().v7obj();

  @override
  Future<TeamSummary> create(String name) async {
    _throwIfFailing();
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.length > 80) {
      throw BrewingException(
        code: BrewingErrorCode.validation,
        message: 'name: must be 1 to 80 characters',
      );
    }
    final summary = TeamSummary(
      team: Team(
        id: const Uuid().v7obj(),
        ownerId: ownerId,
        name: trimmed,
      ),
      role: TeamRole.editor,
    );
    teams.add(summary);
    return summary;
  }

  @override
  Future<List<TeamSummary>> listMine() async {
    _throwIfFailing();
    return [...teams];
  }

  @override
  Future<InviteLink> createInvite(
    UuidValue teamId,
    TeamRole role,
    Duration ttl,
  ) async {
    _throwIfFailing();
    final team = teams.where((t) => t.team.id == teamId).firstOrNull;
    if (team == null) {
      throw BrewingException(
        code: BrewingErrorCode.notFound,
        message: 'Team not found',
      );
    }
    if (team.team.ownerId != ownerId) {
      throw BrewingException(
        code: BrewingErrorCode.forbidden,
        message: "You can't invite people to this team",
      );
    }
    final clamped = ttl < const Duration(minutes: 15)
        ? const Duration(minutes: 15)
        : ttl > const Duration(days: 7)
        ? const Duration(days: 7)
        : ttl;
    final token = const Uuid().v4();
    final link = InviteLink(
      token: token,
      role: role,
      expiresAt: DateTime.now().toUtc().add(clamped),
      url: 'http://localhost:8082/invite/$token',
    );
    _invites[token] = _Invite(link, teamId);
    return link;
  }

  @override
  Future<TeamSummary> acceptInvite(String token) async {
    _throwIfFailing();
    final invite = _invites[token];
    if (invite == null) {
      throw BrewingException(
        code: BrewingErrorCode.notFound,
        message: 'Invite not found',
      );
    }
    final existing = teams.where((t) => t.team.id == invite.teamId).firstOrNull;
    if (existing != null) {
      throw BrewingException(
        code: BrewingErrorCode.alreadyMember,
        message: invite.teamId.uuid,
      );
    }
    if (invite.usedAt != null) {
      throw BrewingException(
        code: BrewingErrorCode.inviteUsed,
        message: 'This invite has already been used.',
      );
    }
    if (invite.link.expiresAt.isBefore(DateTime.now().toUtc())) {
      throw BrewingException(
        code: BrewingErrorCode.inviteExpired,
        message: 'This invite has expired.',
      );
    }
    invite.usedAt = DateTime.now().toUtc();
    final team = Team(
      id: invite.teamId,
      ownerId: ownerId,
      name: 'Joined team',
    );
    final summary = TeamSummary(team: team, role: invite.link.role);
    teams.add(summary);
    return summary;
  }

  void _throwIfFailing() {
    final error = nextError;
    if (error == null) return;
    nextError = null;
    throw error;
  }
}
