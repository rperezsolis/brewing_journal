import 'dart:async';

import 'package:brewing_journal_flutter/ui/core/widgets/flavor_radar_chart.dart';
import 'package:brewing_journal_flutter/ui/features/brew_mode/cubit/brew_timer_state.dart';
import 'package:brewing_journal_flutter/ui/features/brew_mode/view/brew_mode_screen.dart';
import 'package:brewing_journal_flutter/ui/features/recipe_list/view/recipe_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/auth_harness.dart';
import 'support/recipe_harness.dart';

/// Feature 3 against the development server (`serverpod start`).
///
/// US-3.1 parameters and the flavor chart, US-3.2 extra steps in saved order
/// and omitted when empty, US-3.3 count-down and count-up with an in-app
/// alarm, US-3.4 no timer when no extraction time was saved, US-3.5 leaving
/// Brew Mode does not alarm later, US-3.6 no photo section when there are
/// no photos.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final auth = AuthHarness();
  final recipes = RecipeHarness(auth);
  tearDownAll(() async {
    await recipes.close();
    await auth.close();
  });

  group('Feature 3 — Recipe replay and timer', () {
    testWidgets('US-3.1 US-3.2 US-3.3 replays a recipe and alarms at 5s', (
      tester,
    ) async {
      await recipes.signUpFresh(tester);
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final title = 'Five second V60 $stamp';
      final bean = 'Chelbesa $stamp';
      const steps = ['rinse the filter', 'bloom 30g'];

      await _saveRecipe(
        tester,
        recipes,
        title: title,
        bean: bean,
        duration: '0:05',
        instructions: steps,
      );

      await _expectParameters(tester, recipes, title: title, bean: bean);
      await recipes.expectBrewInstructions(tester, steps);
      expect(find.text(recipes.l10n.prepAndExtraSteps), findsOneWidget);
      await recipes.expectNoBrewPhotos(tester);
      await recipes.expectBrewTimer(tester);
      expect(recipes.brewTimerReadout(tester), '00:05.0');
      expect(find.text(recipes.l10n.targetDuration('0:05')), findsOneWidget);
      expect(recipes.brewTimerSelection(tester), {BrewTimerMode.countDown});

      await _withoutAudioErrors(() async {
        await recipes.startBrewTimer(tester);
        final paused = await recipes.pauseBrewTimer(tester);
        await _expectReadoutHolds(tester, recipes, paused);
        await recipes.resumeBrewTimer(tester);
        await _expectReadoutChanges(tester, recipes, paused);
        await recipes.stopBrewTimer(tester);
        expect(recipes.brewTimerReadout(tester), '00:05.0');
        expect(recipes.brewTimerSelection(tester), {BrewTimerMode.countDown});

        await recipes.startBrewTimer(tester);
        await recipes.waitForBrewAlarm(tester);
        recipes.expectBrewFinished(
          tester,
          target: const Duration(seconds: 5),
          countDown: true,
        );
        await recipes.stopBrewAlarm(tester);
        expect(recipes.brewTimerReadout(tester), '00:05.0');

        await recipes.selectBrewMode(tester, BrewTimerMode.countUp);
        expect(recipes.brewTimerReadout(tester), '00:00.0');
        expect(find.text(recipes.l10n.targetDuration('0:05')), findsOneWidget);
        await recipes.startBrewTimer(tester);
        await recipes.waitForBrewAlarm(tester);
        recipes.expectBrewFinished(
          tester,
          target: const Duration(seconds: 5),
          countDown: false,
        );
        await recipes.stopBrewAlarm(tester);
        expect(recipes.brewTimerReadout(tester), '00:00.0');
        expect(recipes.brewTimerSelection(tester), {BrewTimerMode.countUp});
      });

      await recipes.backToJournal(tester);
      await recipes.expectOnList(tester, title);
    }, timeout: const Timeout(Duration(minutes: 6)));

    testWidgets('US-3.2 US-3.4 US-3.6 opens with no timer, steps, or photos', (
      tester,
    ) async {
      await recipes.openJournal(tester);
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final title = 'Untimed V60 $stamp';
      final bean = 'Yirga $stamp';

      await _saveRecipe(tester, recipes, title: title, bean: bean);

      await _expectParameters(tester, recipes, title: title, bean: bean);
      await recipes.expectBrewInstructions(tester, const []);
      expect(find.text(recipes.l10n.prepAndExtraSteps), findsNothing);
      await recipes.expectNoBrewPhotos(tester);
      await recipes.expectNoBrewTimer(tester);
      expect(find.text(recipes.l10n.start), findsNothing);
      expect(find.text(recipes.l10n.extractionTimer), findsNothing);

      await recipes.backToJournal(tester);
      await recipes.expectOnList(tester, title);
    }, timeout: const Timeout(Duration(minutes: 4)));

    testWidgets('US-3.5 leaving before the timer finishes does not alarm', (
      tester,
    ) async {
      await recipes.openJournal(tester);
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final title = 'Long pull $stamp';

      await _saveRecipe(
        tester,
        recipes,
        title: title,
        bean: 'Gesha $stamp',
        duration: '0:08',
      );
      await recipes.expectBrewTimer(tester);
      expect(recipes.brewTimerReadout(tester), '00:08.0');

      await _withoutAudioErrors(() async {
        await recipes.startBrewTimer(tester);
        expect(find.byKey(const Key('brew-pause')), findsOneWidget);
        expect(find.byKey(const Key('brew-stop-alarm')), findsNothing);
        await recipes.backToJournal(tester);

        // Longer than the 8s target. The ticker is cancelled on leave, so
        // the finished alarm never appears on the journal.
        final deadline = DateTime.now().add(const Duration(seconds: 10));
        while (DateTime.now().isBefore(deadline)) {
          await tester.pump(const Duration(milliseconds: 200));
          expect(find.byType(BrewModeScreen), findsNothing);
          expect(find.byType(RecipeListScreen), findsOneWidget);
          expect(find.byKey(const Key('brew-stop-alarm')), findsNothing);
          expect(tester.takeException(), isNull);
        }
      });
    }, timeout: const Timeout(Duration(minutes: 4)));
  });
}

Future<void> _saveRecipe(
  WidgetTester tester,
  RecipeHarness recipes, {
  required String title,
  required String bean,
  String? duration,
  List<String> instructions = const [],
}) async {
  await recipes.startNewRecipe(tester);
  await recipes.registerBean(tester, bean);
  await recipes.next(tester, find.text(recipes.l10n.brewParameters));
  await recipes.fillBrewParameters(tester, title: title);
  if (duration != null) {
    await recipes.setExtractionDuration(tester, duration);
  }
  await recipes.next(tester, find.text(recipes.l10n.flavorMap));
  await recipes.next(tester, find.text(recipes.l10n.extraSteps));
  for (final step in instructions) {
    await recipes.addInstruction(tester, step);
  }
  await recipes.next(tester, find.byKey(const Key('media-add')));
  await recipes.finish(tester);
}

Future<void> _expectParameters(
  WidgetTester tester,
  RecipeHarness recipes, {
  required String title,
  required String bean,
}) async {
  await recipes.expectBrewText(tester, title);
  await recipes.expectBrewText(tester, bean);
  await recipes.expectBrewText(tester, recipes.l10n.methodV60);
  await recipes.expectBrewText(tester, RecipeHarness.grind);
  await recipes.expectBrewText(tester, RecipeHarness.grinder);
  await recipes.expectBrewText(tester, '${RecipeHarness.dose} g');
  await recipes.expectBrewText(tester, '${RecipeHarness.temperature} °C');
  expect(find.byKey(FlavorRadarChart.plotKey), findsOneWidget);
}

/// Fails when audioplayers prints an error while [body] runs.
Future<void> _withoutAudioErrors(Future<void> Function() body) async {
  final lines = <String>[];
  await runZoned(
    body,
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        lines.add(line);
        parent.print(zone, line);
      },
    ),
  );
  final audio = lines.where((line) => line.contains('AudioPlayers'));
  expect(audio, isEmpty, reason: audio.join('\n'));
}

Future<void> _expectReadoutHolds(
  WidgetTester tester,
  RecipeHarness recipes,
  String readout,
) async {
  final deadline = DateTime.now().add(const Duration(milliseconds: 1200));
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 200));
    expect(recipes.brewTimerReadout(tester), readout);
  }
}

Future<void> _expectReadoutChanges(
  WidgetTester tester,
  RecipeHarness recipes,
  String readout,
) async {
  final deadline = DateTime.now().add(const Duration(seconds: 3));
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (recipes.brewTimerReadout(tester) != readout) return;
  }
  fail('The timer readout stayed at $readout after resume.');
}
