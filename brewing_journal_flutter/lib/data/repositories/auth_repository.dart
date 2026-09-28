import 'package:brewing_journal_client/brewing_journal_client.dart';

/// Signed-in state of the current user.
abstract class AuthRepository {
  /// Emits the new signed-in state whenever it changes.
  Stream<bool> get authStateChanges;

  bool get isAuthenticated;

  /// The signed-in account id, or null when signed out.
  UuidValue? get currentUserId;

  /// Restores a persisted session, if any. Call once at app start.
  Future<void> restore();

  Future<void> signOut();
}
