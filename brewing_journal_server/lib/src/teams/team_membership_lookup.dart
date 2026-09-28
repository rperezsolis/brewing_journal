import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

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
