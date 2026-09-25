/// Signed-in state of the current user.
abstract class AuthRepository {
  /// Emits the new signed-in state whenever it changes.
  Stream<bool> get authStateChanges;

  bool get isAuthenticated;

  /// Restores a persisted session, if any. Call once at app start.
  Future<void> restore();

  Future<void> signOut();
}
