import 'package:brewing_journal_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

import '../test_tools/serverpod_test_tools.dart';
import 'recipe_fixtures.dart';
import 'test_users.dart';

Future<TeamSummary> createTeam(
  TestEndpoints endpoints,
  TestUser owner, {
  String name = 'Shop Recipes',
}) => endpoints.team.create(owner.sessionBuilder, name);

/// Owner creates an invite; [member] accepts it and becomes that role.
Future<InviteLink> inviteMember(
  TestEndpoints endpoints,
  TestUser owner,
  TestUser member,
  UuidValue teamId, {
  TeamRole role = TeamRole.editor,
  Duration ttl = const Duration(days: 1),
}) async {
  final invite = await endpoints.team.createInvite(
    owner.sessionBuilder,
    teamId,
    role,
    ttl,
  );
  await endpoints.team.acceptInvite(member.sessionBuilder, invite.token);
  return invite;
}

Future<RecipeDetail> createTeamRecipe(
  TestEndpoints endpoints,
  TestUser owner,
  UuidValue teamId, {
  List<String> instructions = const [],
  String title = 'Shop V60',
}) async {
  final ingredient = await registerIngredient(endpoints, owner);
  return endpoints.recipe.save(
    owner.sessionBuilder,
    sampleDraft(
      ingredient.id!,
      instructions: instructions,
    ).copyWith(teamId: teamId, title: title),
  );
}
