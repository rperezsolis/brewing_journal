/// Product analytics. Implementations must not throw into the UI.
abstract class AnalyticsService {
  /// Prepares the client. Safe to call more than once.
  Future<void> start();

  /// Associates later events with the signed-in account.
  ///
  /// [userId] is the Serverpod auth user id, never an email address.
  Future<void> setUserId(String? userId);

  /// Clears the signed-in identity after sign-out.
  Future<void> reset();

  /// Records that the journal finished resolving the session.
  Future<void> trackAppOpened({required bool signedIn});
}

/// Drops every call. Used by tests and previews.
class NoOpAnalyticsService implements AnalyticsService {
  const NoOpAnalyticsService();

  @override
  Future<void> start() async {}

  @override
  Future<void> setUserId(String? userId) async {}

  @override
  Future<void> reset() async {}

  @override
  Future<void> trackAppOpened({required bool signedIn}) async {}
}
