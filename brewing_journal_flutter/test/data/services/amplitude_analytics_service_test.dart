import 'package:brewing_journal_flutter/data/services/amplitude_analytics_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('an empty api key drops screen and button events', () async {
    final analytics = AmplitudeAnalyticsService(apiKey: '');

    await analytics.trackScreenView(
      screenName: 'recipe_list',
      navigationSource: 'app_start',
    );
    await analytics.trackButtonTapped(
      buttonLabel: 'new_recipe',
      buttonAction: 'open_recipe_wizard',
      currentScreen: 'recipe_list',
    );
  });
}
