import 'package:brewing_journal_flutter/ui/core/widgets/flavor_radar_chart.dart';
import 'package:brewing_journal_flutter/ui/features/brew_mode/view/brew_mode_screen.dart';
import 'package:brewing_journal_flutter/ui/features/recipe_creation/view/recipe_wizard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/auth_harness.dart';
import 'support/recipe_harness.dart';

/// Feature 2 against the development server (`serverpod start`).
///
/// US-2.1 grind and grinder, US-2.2 stopwatch, US-2.3 flavor chart and tags,
/// US-2.4 reorder and remove every step, US-2.5 skip, US-2.6 photos,
/// US-2.7 blank steps, US-2.8 duplicate steps, US-2.9 saved order, US-2.10
/// free-text amounts, US-2.11 length, US-2.12 save with no photo and with one.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final auth = AuthHarness();
  final recipes = RecipeHarness(auth);
  tearDownAll(() async {
    await recipes.close();
    await auth.close();
  });

  group('Feature 2 — 5-step recipe creation', () {
    testWidgets('creates a V60, edits its steps, and attaches a photo', (
      tester,
    ) async {
      final photo = await recipes.oversizedPhoto();
      expect(await photo.length(), greaterThan(512 * 1024));

      await recipes.signUpFresh(tester);
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final title = 'Morning V60 $stamp';
      final bean = 'Chelbesa $stamp';

      await recipes.startNewRecipe(tester);
      await recipes.registerBean(tester, bean);
      await recipes.next(tester, find.text(recipes.l10n.brewParameters));
      await recipes.fillBrewParameters(tester, title: title);
      await recipes.timeWithStopwatch(tester);
      await recipes.next(tester, find.text(recipes.l10n.flavorMap));

      expect(find.byKey(FlavorRadarChart.plotKey), findsOneWidget);
      await recipes.nudgeAcidity(tester);
      await recipes.addTag(tester, 'Fruity');
      await recipes.addTag(tester, ' fruity ');
      expect(find.widgetWithText(InputChip, 'Fruity'), findsOneWidget);
      await recipes.addTag(tester, 'Chocolate');
      await recipes.addTag(tester, 'Floral');
      expect(find.widgetWithText(InputChip, 'Chocolate'), findsOneWidget);
      expect(find.widgetWithText(InputChip, 'Floral'), findsOneWidget);
      await recipes.next(tester, find.text(recipes.l10n.extraSteps));

      await recipes.rejectBlankInstruction(tester);
      await recipes.rejectOverlongInstruction(tester);
      await recipes.acceptBoundaryInstruction(tester);
      await recipes.addInstruction(tester, '  use 150ml of whole milk ');
      await recipes.addInstruction(tester, 'stir');
      await recipes.addInstruction(tester, 'stir');
      expect(recipes.instructionLines(tester), [
        '1. use 150ml of whole milk',
        '2. stir',
        '3. stir',
      ]);

      await recipes.next(tester, find.byKey(const Key('media-add')));
      await recipes.finish(tester);

      await recipes.expectBrewText(tester, title);
      await recipes.expectBrewText(tester, bean);
      await recipes.expectBrewText(tester, recipes.l10n.methodV60);
      await recipes.expectBrewText(tester, RecipeHarness.grind);
      await recipes.expectBrewText(tester, RecipeHarness.grinder);
      await recipes.expectBrewText(tester, '${RecipeHarness.dose} g');
      await recipes.expectBrewText(tester, '${RecipeHarness.temperature} °C');
      await recipes.expectBrewText(tester, 'Fruity');
      await recipes.expectBrewText(tester, 'Chocolate');
      await recipes.expectBrewText(tester, 'Floral');
      expect(find.byKey(FlavorRadarChart.plotKey), findsOneWidget);
      await recipes.expectBrewTimer(tester);
      await recipes.expectBrewInstructions(tester, [
        'use 150ml of whole milk',
        'stir',
        'stir',
      ]);

      await recipes.backToJournal(tester);
      await recipes.expectOnList(tester, title);

      await recipes.openRecipe(tester, title);
      await recipes.editRecipe(tester);
      await recipes.openStep(
        tester,
        recipes.l10n.stepSteps,
        find.byKey(const Key('instruction-input')),
      );
      expect(recipes.instructionLines(tester), [
        '1. use 150ml of whole milk',
        '2. stir',
        '3. stir',
      ]);
      await recipes.reorderFirstInstruction(tester);
      expect(recipes.instructionLines(tester).first, isNot(contains('150ml')));
      await recipes.removeAllInstructions(tester);
      await recipes.next(tester, find.byKey(const Key('media-add')));
      await recipes.finish(tester);
      await recipes.expectBrewInstructions(tester, const []);

      await recipes.backToJournal(tester);
      await recipes.openRecipe(tester, title);
      await recipes.expectBrewInstructions(tester, const []);

      await recipes.editRecipe(tester);
      await recipes.openStep(
        tester,
        recipes.l10n.stepPhotos,
        find.byKey(const Key('media-add')),
      );
      await recipes.addOversizedPhoto(tester);
      await recipes.expectPhotoLoads(tester, RecipeWizardScreen);
      await recipes.finish(tester);
      await recipes.expectPhotoLoads(tester, BrewModeScreen);

      await recipes.editRecipe(tester);
      await recipes.openStep(
        tester,
        recipes.l10n.stepPhotos,
        find.byTooltip(recipes.l10n.removePhoto),
      );
      await recipes.removePhoto(tester);
      await recipes.finish(tester);
      await recipes.expectBrewInstructions(tester, const []);
      await recipes.expectNoBrewPhotos(tester);
    }, timeout: const Timeout(Duration(minutes: 6)));

    testWidgets('US-2.5 skip drops extra steps and still saves', (
      tester,
    ) async {
      await recipes.openJournal(tester);
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final title = 'Quick V60 $stamp';

      await recipes.startNewRecipe(tester);
      await recipes.registerBean(tester, 'Yirga $stamp');
      await recipes.next(tester, find.text(recipes.l10n.brewParameters));
      await recipes.fillBrewParameters(tester, title: title);
      await recipes.next(tester, find.text(recipes.l10n.flavorMap));
      await recipes.next(tester, find.text(recipes.l10n.extraSteps));
      await recipes.addInstruction(tester, 'stir once');
      await recipes.skipInstructions(tester);
      expect(find.text(recipes.l10n.extraSteps), findsNothing);
      await recipes.finish(tester);

      await recipes.expectBrewText(tester, title);
      await recipes.expectBrewInstructions(tester, const []);
      await recipes.backToJournal(tester);
      await recipes.expectOnList(tester, title);
    }, timeout: const Timeout(Duration(minutes: 4)));
  });
}
