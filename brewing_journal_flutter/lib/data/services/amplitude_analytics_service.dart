import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/autocapture/autocapture.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:amplitude_flutter/constants.dart';
import 'package:amplitude_flutter/events/base_event.dart';

import 'analytics_service.dart';

/// Public ingestion key for Amplitude project `default` (id 872977), US.
///
/// This key is meant to ship in the client. Override it with
/// `--dart-define=AMPLITUDE_API_KEY=...` for another project.
const amplitudeApiKey = String.fromEnvironment(
  'AMPLITUDE_API_KEY',
  defaultValue: '1f4eb116e3a53c36d3f876048bc9c146',
);

/// [AnalyticsService] backed by the Amplitude Flutter SDK.
///
/// Autocapture stays off. The sign-in form contains an email address, and
/// element or form capture would send that text. The app sends `App Opened`
/// itself once the session is known.
class AmplitudeAnalyticsService implements AnalyticsService {
  AmplitudeAnalyticsService({this.apiKey = amplitudeApiKey});

  final String apiKey;

  Amplitude? _amplitude;
  Future<void>? _starting;

  @override
  Future<void> start() {
    return _starting ??= _start();
  }

  Future<void> _start() async {
    if (apiKey.isEmpty) return;
    try {
      final amplitude = Amplitude(
        Configuration(
          apiKey: apiKey,
          serverZone: ServerZone.us,
          autocapture: const AutocaptureDisabled(),
          // The journal does not use device location.
          locationListening: false,
        ),
      );
      final built = await amplitude.isBuilt;
      if (built) _amplitude = amplitude;
    } catch (_) {
      // A missing plugin or a rejected init must not block startup.
      _amplitude = null;
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    final amplitude = await _ready();
    if (amplitude == null || userId == null || userId.length < 5) return;
    try {
      await amplitude.setUserId(userId);
    } catch (_) {
      // Ignore plugin failures. The journal keeps working without analytics.
    }
  }

  @override
  Future<void> reset() async {
    final amplitude = await _ready();
    if (amplitude == null) return;
    try {
      await amplitude.reset();
    } catch (_) {
      // Ignore plugin failures. The journal keeps working without analytics.
    }
  }

  @override
  Future<void> trackAppOpened({required bool signedIn}) {
    return _track(
      AnalyticsEvents.appOpened,
      {AnalyticsProperties.signedIn: signedIn},
      flush: true,
    );
  }

  @override
  Future<void> trackScreenView({
    required String screenName,
    required String navigationSource,
  }) {
    return _track(AnalyticsEvents.screenView, {
      AnalyticsProperties.screenName: screenName,
      AnalyticsProperties.navigationSource: navigationSource,
    });
  }

  @override
  Future<void> trackButtonTapped({
    required String buttonLabel,
    required String buttonAction,
    required String currentScreen,
  }) {
    return _track(AnalyticsEvents.buttonTapped, {
      AnalyticsProperties.buttonLabel: buttonLabel,
      AnalyticsProperties.buttonAction: buttonAction,
      AnalyticsProperties.currentScreen: currentScreen,
    });
  }

  Future<void> _track(
    String eventType,
    Map<String, Object> properties, {
    bool flush = false,
  }) async {
    final amplitude = await _ready();
    if (amplitude == null) return;
    try {
      await amplitude.track(
        BaseEvent(eventType, eventProperties: properties),
      );
      if (flush) await amplitude.flush();
    } catch (_) {
      // Ignore plugin failures. The journal keeps working without analytics.
    }
  }

  Future<Amplitude?> _ready() async {
    await start();
    return _amplitude;
  }
}
