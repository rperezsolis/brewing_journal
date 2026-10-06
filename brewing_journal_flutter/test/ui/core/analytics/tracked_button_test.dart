import 'package:brewing_journal_flutter/data/services/analytics_service.dart';
import 'package:brewing_journal_flutter/ui/core/analytics/tracked_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tracks the tap and then runs onPressed', (tester) async {
    final analytics = _RecordingAnalytics();
    var presses = 0;

    await tester.pumpWidget(
      RepositoryProvider<AnalyticsService>.value(
        value: analytics,
        child: MaterialApp(
          home: Scaffold(
            body: TrackedButton(
              buttonLabel: 'go_home',
              buttonAction: 'navigate_home',
              currentScreen: 'not_found',
              onPressed: () => presses += 1,
              builder: (context, onPressed) => FilledButton(
                onPressed: onPressed,
                child: const Text('Go home'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Go home'));
    await tester.pump();

    expect(presses, 1);
    expect(analytics.buttons, [('go_home', 'navigate_home', 'not_found')]);
  });

  testWidgets('a disabled button does not track', (tester) async {
    final analytics = _RecordingAnalytics();

    await tester.pumpWidget(
      RepositoryProvider<AnalyticsService>.value(
        value: analytics,
        child: MaterialApp(
          home: Scaffold(
            body: TrackedButton(
              buttonLabel: 'go_home',
              buttonAction: 'navigate_home',
              currentScreen: 'not_found',
              onPressed: null,
              builder: (context, onPressed) => FilledButton(
                onPressed: onPressed,
                child: const Text('Go home'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Go home'));
    await tester.pump();

    expect(analytics.buttons, isEmpty);
  });

  testWidgets('the button still runs when analytics throws', (tester) async {
    var presses = 0;

    await tester.pumpWidget(
      RepositoryProvider<AnalyticsService>.value(
        value: _ThrowingAnalytics(),
        child: MaterialApp(
          home: Scaffold(
            body: TrackedButton(
              buttonLabel: 'sign_out',
              buttonAction: 'sign_out',
              currentScreen: 'recipe_list',
              onPressed: () => presses += 1,
              builder: (context, onPressed) => FilledButton(
                onPressed: onPressed,
                child: const Text('Sign out'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Sign out'));
    await tester.pump();

    expect(presses, 1);
  });

  testWidgets('the button still runs when analytics is not provided', (
    tester,
  ) async {
    var presses = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TrackedButton(
            buttonLabel: 'retry',
            buttonAction: 'reload',
            currentScreen: 'recipe_list',
            onPressed: () => presses += 1,
            builder: (context, onPressed) => FilledButton(
              onPressed: onPressed,
              child: const Text('Retry'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(presses, 1);
  });
}

class _RecordingAnalytics extends NoOpAnalyticsService {
  final buttons = <(String, String, String)>[];

  @override
  Future<void> trackButtonTapped({
    required String buttonLabel,
    required String buttonAction,
    required String currentScreen,
  }) async {
    buttons.add((buttonLabel, buttonAction, currentScreen));
  }
}

class _ThrowingAnalytics extends NoOpAnalyticsService {
  @override
  Future<void> trackButtonTapped({
    required String buttonLabel,
    required String buttonAction,
    required String currentScreen,
  }) async {
    throw StateError('analytics failed');
  }
}
