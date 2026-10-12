import 'package:serverpod/serverpod.dart';

import '../brewing/recipe_access_policy.dart';
import '../common/authenticated_endpoint.dart';
import '../common/session_auth.dart';
import '../generated/protocol.dart';
import 'invite_token.dart';
import 'role_change_email.dart';
import 'team_member_directory.dart';
import 'team_membership_lookup.dart';
import 'web_base_url.dart';

const _minTeamNameLength = 1;
const _maxTeamNameLength = 80;
const _minInviteTtl = Duration(minutes: 15);
const _maxInviteTtl = Duration(days: 7);

class TeamEndpoint extends AuthenticatedEndpoint {
  /// Creates a team and an editor membership for the caller.
  Future<TeamSummary> create(Session session, String name) async {
    final trimmed = name.trim();
    if (trimmed.length < _minTeamNameLength ||
        trimmed.length > _maxTeamNameLength) {
      throw BrewingException(
        code: BrewingErrorCode.validation,
        message: 'name: must be 1 to 80 characters',
      );
    }

    final callerId = session.callerId;
    return session.db.transaction((tx) async {
      final team = await Team.db.insertRow(
        session,
        Team(ownerId: callerId, name: trimmed),
        transaction: tx,
      );
      await TeamMembership.db.insertRow(
        session,
        TeamMembership(
          teamId: team.id!,
          memberId: callerId,
          role: TeamRole.editor,
        ),
        transaction: tx,
      );
      return TeamSummary(team: team, role: TeamRole.editor);
    });
  }

  /// Teams the caller belongs to, with their role on each.
  Future<List<TeamSummary>> listMine(Session session) async {
    final memberships = await TeamMembership.db.find(
      session,
      where: (t) => t.memberId.equals(session.callerId),
      include: TeamMembership.include(team: Team.include()),
    );
    return [
      for (final membership in memberships)
        if (membership.team != null)
          TeamSummary(team: membership.team!, role: membership.role),
    ];
  }

  /// Issues a single-use invite URL. Only the team owner may create invites.
  Future<InviteLink> createInvite(
    Session session,
    UuidValue teamId,
    TeamRole role,
    Duration ttl,
  ) async {
    final membership = await membershipOf(session, teamId, session.callerId);
    if (membership == null) {
      throw BrewingException(
        code: BrewingErrorCode.notFound,
        message: 'Team not found',
      );
    }
    final team = await Team.db.findById(session, teamId);
    if (team == null || team.ownerId != session.callerId) {
      throw recipeForbidden("You can't invite people to this team");
    }

    final clamped = _clampTtl(ttl);
    final token = generateInviteToken();
    final expiresAt = DateTime.now().toUtc().add(clamped);
    await TeamInvite.db.insertRow(
      session,
      TeamInvite(
        teamId: teamId,
        createdById: session.callerId,
        token: token,
        role: role,
        expiresAt: expiresAt,
      ),
    );
    return InviteLink(
      token: token,
      role: role,
      expiresAt: expiresAt,
      url: '${webBaseUrl(session)}/invite/$token',
    );
  }

  /// Claims an unused, unexpired invite and inserts a membership.
  ///
  /// Already a member → `alreadyMember` (invite stays unused). A lost race
  /// on the claim → `inviteUsed` or `inviteExpired`, with no write.
  Future<TeamSummary> acceptInvite(Session session, String token) async {
    final invite = await TeamInvite.db.findFirstRow(
      session,
      where: (t) => t.token.equals(token),
    );
    if (invite == null) {
      throw BrewingException(
        code: BrewingErrorCode.notFound,
        message: 'Invite not found',
      );
    }

    final existing = await membershipOf(
      session,
      invite.teamId,
      session.callerId,
    );
    if (existing != null) {
      throw BrewingException(
        code: BrewingErrorCode.alreadyMember,
        message: invite.teamId.uuid,
      );
    }

    final now = DateTime.now().toUtc();
    final callerId = session.callerId;
    return session.db.transaction((tx) async {
      final updated = await session.db.unsafeExecute(
        'UPDATE team_invite SET "usedAt" = @now, "usedById" = @caller::uuid '
        'WHERE token = @token AND "usedAt" IS NULL AND "expiresAt" > @now',
        parameters: QueryParameters.named({
          'now': now,
          'caller': callerId.uuid,
          'token': token,
        }),
        transaction: tx,
      );
      if (updated == 1) {
        await TeamMembership.db.insertRow(
          session,
          TeamMembership(
            teamId: invite.teamId,
            memberId: callerId,
            role: invite.role,
          ),
          transaction: tx,
        );
        final team = await Team.db.findById(
          session,
          invite.teamId,
          transaction: tx,
        );
        return TeamSummary(team: team!, role: invite.role);
      }

      final claimed = await TeamInvite.db.findFirstRow(
        session,
        where: (t) => t.token.equals(token),
        transaction: tx,
      );
      if (claimed?.usedAt != null) {
        throw BrewingException(
          code: BrewingErrorCode.inviteUsed,
          message: 'This invite has already been used.',
        );
      }
      throw BrewingException(
        code: BrewingErrorCode.inviteExpired,
        message: 'This invite has expired.',
      );
    });
  }

  /// Members of [teamId], oldest membership first.
  ///
  /// A caller who is not a member gets `notFound`.
  Future<List<TeamMember>> listMembers(
    Session session,
    UuidValue teamId,
  ) async {
    await _requireMember(session, teamId);
    final memberships = await TeamMembership.db.find(
      session,
      where: (t) => t.teamId.equals(teamId),
      orderByList: (t) => [t.createdAt, t.id],
    );
    final identities = await memberIdentities(
      session,
      memberships.map((membership) => membership.memberId).toSet(),
    );
    return [
      for (final membership in memberships)
        _memberView(
          membership,
          identities[membership.memberId] ??
              const MemberIdentity(preferredName: '', email: ''),
        ),
    ];
  }

  /// Sets [memberId]'s role on [teamId] and emails them when it changes.
  ///
  /// Only `team.ownerId` may call this. A caller who is not a member gets
  /// `notFound`. A member who is not the owner gets `forbidden`. The same
  /// role is a no-op and sends no email.
  Future<TeamMember> changeMemberRole(
    Session session,
    UuidValue teamId,
    UuidValue memberId,
    TeamRole role,
    String locale,
  ) async {
    await _requireMember(session, teamId);
    final team = await Team.db.findById(session, teamId);
    if (team == null || team.ownerId != session.callerId) {
      throw recipeForbidden("You can't change roles on this team");
    }

    final membership = await membershipOf(session, teamId, memberId);
    if (membership == null) {
      throw BrewingException(
        code: BrewingErrorCode.notFound,
        message: 'Member not found',
      );
    }

    final identities = await memberIdentities(session, {memberId});
    final identity =
        identities[memberId] ??
        const MemberIdentity(preferredName: '', email: '');
    if (membership.role == role) {
      return _memberView(membership, identity);
    }

    final updated = await TeamMembership.db.updateRow(
      session,
      membership.copyWith(role: role),
    );
    final notice = composeRoleChangeEmail(
      recipient: identity.email,
      locale: locale,
      preferredName: identity.preferredName,
      teamName: team.name,
      from: membership.role,
      to: role,
    );
    if (notice == null) {
      session.log(
        'Role change for ${memberId.uuid} on ${team.name} has no email address.',
        level: LogLevel.warning,
      );
    } else {
      await deliverRoleChangeEmail(session, notice);
    }
    return _memberView(updated, identity);
  }

  Future<void> _requireMember(Session session, UuidValue teamId) async {
    final membership = await membershipOf(session, teamId, session.callerId);
    if (membership == null) {
      throw BrewingException(
        code: BrewingErrorCode.notFound,
        message: 'Team not found',
      );
    }
  }

  TeamMember _memberView(TeamMembership membership, MemberIdentity identity) {
    return TeamMember(
      membershipId: membership.id!,
      userId: membership.memberId,
      preferredName: identity.preferredName,
      email: identity.email,
      role: membership.role,
    );
  }

  Duration _clampTtl(Duration ttl) {
    if (ttl < _minInviteTtl) return _minInviteTtl;
    if (ttl > _maxInviteTtl) return _maxInviteTtl;
    return ttl;
  }
}
