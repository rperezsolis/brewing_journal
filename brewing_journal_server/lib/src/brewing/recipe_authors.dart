import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';

/// The name shown for a recipe owner: full name, then username, then email.
String? authorDisplayName(UserProfile profile) {
  for (final raw in [profile.fullName, profile.userName, profile.email]) {
    final value = raw?.trim();
    if (value != null && value.isNotEmpty) return value;
  }
  return null;
}

/// Sets [Recipe.authorName] from each owner's profile. Recipes whose owner
/// has no profile keep a null name.
Future<List<Recipe>> withAuthorNames(
  Session session,
  List<Recipe> recipes,
) async {
  final ownerIds = {for (final recipe in recipes) recipe.ownerId};
  if (ownerIds.isEmpty) return recipes;

  final profiles = await UserProfile.db.find(
    session,
    where: (t) => t.authUserId.inSet(ownerIds),
  );
  final names = <UuidValue, String>{};
  for (final profile in profiles) {
    final name = authorDisplayName(profile);
    if (name != null) names[profile.authUserId] = name;
  }
  return [
    for (final recipe in recipes)
      recipe.copyWith(authorName: names[recipe.ownerId]),
  ];
}
