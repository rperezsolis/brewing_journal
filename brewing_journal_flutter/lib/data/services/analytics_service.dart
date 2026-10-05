/// Amplitude event names sent by [AnalyticsService].
abstract final class AnalyticsEvents {
  static const appOpened = 'App Opened';
  static const screenView = 'screen_view';
  static const buttonTapped = 'button_tapped';
}

/// Property keys for [AnalyticsEvents].
abstract final class AnalyticsProperties {
  static const signedIn = 'signed_in';
  static const screenName = 'screen_name';
  static const navigationSource = 'navigation_source';
  static const buttonLabel = 'button_label';
  static const buttonAction = 'button_action';
  static const currentScreen = 'current_screen';
}

/// Product analytics. Implementations must not throw into the UI.
///
/// Widgets read the app instance with `context.read<AnalyticsService>()`.
/// A Cubit receives the same instance through its constructor and calls these
/// methods directly.
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

  /// Records a `screen_view`.
  ///
  /// [screenName] identifies the screen. [navigationSource] is the screen the
  /// user left, or `app_start` when this is the first screen.
  Future<void> trackScreenView({
    required String screenName,
    required String navigationSource,
  });

  /// Records a `button_tapped` event.
  ///
  /// [buttonLabel] identifies the control, [buttonAction] is what the tap
  /// does, and [currentScreen] is the screen that owns the control.
  Future<void> trackButtonTapped({
    required String buttonLabel,
    required String buttonAction,
    required String currentScreen,
  });
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

  @override
  Future<void> trackScreenView({
    required String screenName,
    required String navigationSource,
  }) async {}

  @override
  Future<void> trackButtonTapped({
    required String buttonLabel,
    required String buttonAction,
    required String currentScreen,
  }) async {}
}
