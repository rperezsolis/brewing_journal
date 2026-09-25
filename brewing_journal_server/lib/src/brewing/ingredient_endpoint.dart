import 'package:serverpod/serverpod.dart';

import '../common/authenticated_endpoint.dart';
import '../common/session_auth.dart';
import '../generated/protocol.dart';
import 'recipe_limits.dart';
import 'recipe_validator.dart';

/// The caller's own coffee beans, tea leaves, and matcha grades.
class IngredientEndpoint extends AuthenticatedEndpoint {
  /// The caller's ingredients of [kind] whose name starts with [query]
  /// (case-insensitive), ordered by name.
  Future<List<Ingredient>> search(
    Session session,
    BeverageKind kind,
    String query,
    int limit,
  ) async {
    final pattern = '${_escapeLike(nameKeyOf(query))}%';
    return Ingredient.db.find(
      session,
      where: (t) =>
          t.ownerId.equals(session.callerId) &
          t.kind.equals(kind) &
          t.nameKey.like(pattern),
      orderBy: (t) => t.nameKey,
      limit: limit.clamp(1, 30),
    );
  }

  /// Returns the caller's existing ingredient with the same kind and name
  /// (case-insensitive), or inserts a new one.
  Future<Ingredient> register(Session session, IngredientDraft draft) async {
    final name = validateText('name', draft.name, kIngredientNameMaxLength);
    final nameKey = nameKeyOf(name);
    final callerId = session.callerId;

    final existing = await Ingredient.db.findFirstRow(
      session,
      where: (t) =>
          t.ownerId.equals(callerId) &
          t.kind.equals(draft.kind) &
          t.nameKey.equals(nameKey),
    );
    if (existing != null) return existing;

    return Ingredient.db.insertRow(
      session,
      Ingredient(
        ownerId: callerId,
        kind: draft.kind,
        name: name,
        nameKey: nameKey,
        origin: _optional(draft.origin),
        roaster: _optional(draft.roaster),
        roastLevel: draft.roastLevel,
        processing: _optional(draft.processing),
      ),
    );
  }
}

String nameKeyOf(String name) => name.trim().toLowerCase();

String? _optional(String? value) {
  final trimmed = value?.trim();
  return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
}

/// PostgreSQL's default LIKE escape character is a backslash.
String _escapeLike(String value) =>
    value.replaceAllMapped(RegExp(r'[\\%_]'), (m) => '\\${m[0]}');
