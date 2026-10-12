import 'package:brewing_journal_client/brewing_journal_client.dart';

abstract class TeamRepository {
  Future<TeamSummary> create(String name);

  Future<List<TeamSummary>> listMine();

  Future<InviteLink> createInvite(
    UuidValue teamId,
    TeamRole role,
    Duration ttl,
  );

  Future<TeamSummary> acceptInvite(String token);

  Future<List<TeamMember>> listMembers(UuidValue teamId);

  Future<TeamMember> changeMemberRole(
    UuidValue teamId,
    UuidValue memberId,
    TeamRole role,
    String locale,
  );
}
