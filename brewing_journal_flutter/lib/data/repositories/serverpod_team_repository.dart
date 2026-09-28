import 'package:brewing_journal_client/brewing_journal_client.dart';

import 'team_repository.dart';

class ServerpodTeamRepository implements TeamRepository {
  ServerpodTeamRepository(this._endpoint);

  final EndpointTeam _endpoint;

  @override
  Future<TeamSummary> create(String name) => _endpoint.create(name);

  @override
  Future<List<TeamSummary>> listMine() => _endpoint.listMine();

  @override
  Future<InviteLink> createInvite(
    UuidValue teamId,
    TeamRole role,
    Duration ttl,
  ) => _endpoint.createInvite(teamId, role, ttl);

  @override
  Future<TeamSummary> acceptInvite(String token) =>
      _endpoint.acceptInvite(token);
}
