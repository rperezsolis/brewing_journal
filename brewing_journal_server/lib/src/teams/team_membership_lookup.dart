import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Teams [memberId] belongs to. Uses `team_membership_member_idx`.
Future<Set<UuidValue>> teamIdsOf(
  Session session,
  UuidValue memberId, {
  Transaction? transaction,
}) async {
  final memberships = await TeamMembership.db.find(
    session,
    where: (t) => t.memberId.equals(memberId),
    transaction: transaction,
  );
  return memberships.map((membership) => membership.teamId).toSet();
}

/// The membership of [memberId] on [teamId], or null. Uses the unique
/// `(teamId, memberId)` index.
Future<TeamMembership?> membershipOf(
  Session session,
  UuidValue teamId,
  UuidValue memberId, {
  Transaction? transaction,
}) {
  return TeamMembership.db.findFirstRow(
    session,
    where: (t) => t.teamId.equals(teamId) & t.memberId.equals(memberId),
    transaction: transaction,
  );
}
