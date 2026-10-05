import 'package:serverpod/serverpod.dart';

import '../common/authenticated_endpoint.dart';
import '../common/session_auth.dart';
import '../generated/protocol.dart';
import '../teams/team_membership_lookup.dart';
import 'recipe_limits.dart';
import 'recipe_validator.dart';

/// The caller's coffee beans, tea leaves, and matcha grades, plus ingredients
/// used by recipes on the caller's teams.
class IngredientEndpoint extends AuthenticatedEndpoint {
  /// Ingredients of [kind] whose name starts with [query] (case-insensitive),
  /// ordered by name. Includes the caller's rows and rows used on their teams.
  /// One row per folded name; the caller's own row wins.
  Future<List<Ingredient>> search(
    Session session,
    BeverageKind kind,
    String query,
    int limit,
  ) async {
    final capped = limit.clamp(1, 30);
    final pattern = '${_escapeLike(nameKeyOf(query))}%';
    final callerId = session.callerId;

    final own = await Ingredient.db.find(
      session,
      where: (t) =>
          t.ownerId.equals(callerId) &
          t.kind.equals(kind) &
          t.nameKey.like(pattern),
      orderBy: (t) => t.nameKey,
      limit: kCatalogScanLimit,
    );

    final sharedIds = await _ingredientIdsOnCallerTeams(session, callerId);
    final shared = sharedIds.isEmpty
        ? const <Ingredient>[]
        : await Ingredient.db.find(
            session,
            where: (t) =>
                t.id.inSet(sharedIds) &
                t.kind.equals(kind) &
                t.nameKey.like(pattern) &
                t.ownerId.notEquals(callerId),
          );

    final chosen = <String, Ingredient>{};
    for (final ingredient in own) {
      chosen.putIfAbsent(ingredient.nameKey, () => ingredient);
    }
    final sharedByAge = [...shared]..sort(_earliestFirst);
    for (final ingredient in sharedByAge) {
      chosen.putIfAbsent(ingredient.nameKey, () => ingredient);
    }
    final merged = chosen.values.toList()
      ..sort((a, b) => a.nameKey.compareTo(b.nameKey));
    return _preferShared(merged, callerId, capped);
  }

  /// Returns the caller's existing ingredient with the same kind and name
  /// (case-insensitive), or inserts a new one.
  Future<Ingredient> register(Session session, IngredientDraft draft) async {
    final name = validateText('name', draft.name, kIngredientNameMaxLength);
    return _findOrInsert(
      session,
      ownerId: session.callerId,
      kind: draft.kind,
      name: name,
      nameKey: nameKeyOf(name),
      origin: _detail('origin', draft.origin),
      roaster: _detail('roaster', draft.roaster),
      roastLevel: draft.roastLevel,
      processing: _detail('processing', draft.processing),
    );
  }

  /// Copies a team ingredient onto the caller, or returns the row they
  /// already have for that kind and name. The caller's own id is returned
  /// unchanged. A private ingredient is [BrewingErrorCode.notFound].
  Future<Ingredient> adopt(Session session, UuidValue id) async {
    final ingredient = await Ingredient.db.findById(session, id);
    final callerId = session.callerId;
    if (ingredient == null) throw _notFound();
    if (ingredient.ownerId == callerId) return ingredient;

    final sharedIds = await _ingredientIdsOnCallerTeams(session, callerId);
    if (!sharedIds.contains(ingredient.id)) throw _notFound();

    return _findOrInsert(
      session,
      ownerId: callerId,
      kind: ingredient.kind,
      name: ingredient.name,
      nameKey: ingredient.nameKey,
      origin: ingredient.origin,
      roaster: ingredient.roaster,
      roastLevel: ingredient.roastLevel,
      processing: ingredient.processing,
    );
  }
}

Future<Set<UuidValue>> _ingredientIdsOnCallerTeams(
  Session session,
  UuidValue callerId,
) async {
  final teamIds = await teamIdsOf(session, callerId);
  if (teamIds.isEmpty) return {};
  final recipes = await Recipe.db.find(
    session,
    where: (t) => t.teamId.inSet(teamIds),
    orderByList: (t) => [t.updatedAt.desc(), t.id.desc()],
    limit: kTeamRecipeScanLimit,
  );
  return recipes.map((recipe) => recipe.ingredientId).toSet();
}

Future<Ingredient> _findOrInsert(
  Session session, {
  required UuidValue ownerId,
  required BeverageKind kind,
  required String name,
  required String nameKey,
  String? origin,
  String? roaster,
  RoastLevel? roastLevel,
  String? processing,
}) async {
  final existing = await Ingredient.db.findFirstRow(
    session,
    where: (t) =>
        t.ownerId.equals(ownerId) &
        t.kind.equals(kind) &
        t.nameKey.equals(nameKey),
  );
  if (existing != null) return existing;

  return Ingredient.db.insertRow(
    session,
    Ingredient(
      ownerId: ownerId,
      kind: kind,
      name: name,
      nameKey: nameKey,
      origin: origin,
      roaster: roaster,
      roastLevel: roastLevel,
      processing: processing,
    ),
  );
}

/// Keeps team ingredients when [rows] is longer than [limit]. [rows] is
/// already ordered by `nameKey`.
List<Ingredient> _preferShared(
  List<Ingredient> rows,
  UuidValue callerId,
  int limit,
) {
  if (rows.length <= limit) return rows;
  final shared = rows.where((row) => row.ownerId != callerId).take(limit);
  final own = rows
      .where((row) => row.ownerId == callerId)
      .take(limit - shared.length);
  return [...shared, ...own]..sort((a, b) => a.nameKey.compareTo(b.nameKey));
}

int _earliestFirst(Ingredient a, Ingredient b) {
  final byTime = a.createdAt.compareTo(b.createdAt);
  if (byTime != 0) return byTime;
  return a.id!.uuid.compareTo(b.id!.uuid);
}

BrewingException _notFound() => BrewingException(
  code: BrewingErrorCode.notFound,
  message: 'Ingredient not found',
);

String nameKeyOf(String name) => name.trim().toLowerCase();

String? _detail(String field, String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  if (trimmed.length > kIngredientDetailMaxLength) {
    throw validationError(
      field,
      'must be at most $kIngredientDetailMaxLength characters',
    );
  }
  return trimmed;
}

/// PostgreSQL's default LIKE escape character is a backslash.
String _escapeLike(String value) =>
    value.replaceAllMapped(RegExp(r'[\\%_]'), (m) => '\\${m[0]}');
