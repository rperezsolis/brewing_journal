import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:brewing_journal_flutter/l10n/app_localizations.dart';
import 'package:brewing_journal_flutter/ui/core/locale_resolution.dart';
import 'package:brewing_journal_flutter/ui/core/widgets/favorite_icon_button.dart';
import 'package:brewing_journal_flutter/ui/features/brew_mode/cubit/brew_timer_state.dart';
import 'package:brewing_journal_flutter/ui/features/brew_mode/view/brew_mode_screen.dart';
import 'package:brewing_journal_flutter/ui/features/recipe_creation/view/recipe_wizard_screen.dart';
import 'package:brewing_journal_flutter/ui/features/recipe_list/view/recipe_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

import 'auth_harness.dart';

/// Meets the email form's length, case, digit, and symbol rules.
const integrationPassword = 'Brewjournal1!';

/// Drives the 5-step recipe wizard and Brew Mode against the development
/// server.
class RecipeHarness {
  RecipeHarness(this.auth);

  final AuthHarness auth;

  final AppLocalizations l10n = lookupAppLocalizations(
    resolveBrewSyncLocales(
      WidgetsBinding.instance.platformDispatcher.locales,
      AppLocalizations.supportedLocales,
    ),
  );

  static const grind = '18 clicks';
  static const grinder = 'Comandante C40';
  static const temperature = '93';
  static const dose = '15';

  Directory? _photoDirectory;
  File? _oversizedPhoto;

  /// A new account, so the journal list starts empty.
  Future<void> signUpFresh(WidgetTester tester) async {
    await auth.ensureSignedOut(tester);
    await auth.signUp(tester, auth.freshEmail(), integrationPassword);
    await _useDesktopSurface(tester);
  }

  /// The signed-in journal, signing up when this Mac has no session.
  Future<void> openJournal(WidgetTester tester) async {
    await auth.openApp(tester);
    if (find.byType(RecipeListScreen).evaluate().isEmpty) {
      await auth.signUp(tester, auth.freshEmail(), integrationPassword);
    }
    await _useDesktopSurface(tester);
  }

  Future<void> startNewRecipe(WidgetTester tester) async {
    expect(find.byType(BrewModeScreen), findsNothing);
    expect(find.byType(RecipeWizardScreen), findsNothing);
    await tester.tap(find.byKey(const Key('recipe-list-new')));
    await tester.pump();
    await _waitFor(
      tester,
      find.text(l10n.whatAreYouBrewing),
      'the new recipe wizard',
    );
  }

  Future<void> registerBean(WidgetTester tester, String name) async {
    await tester.tap(find.byKey(const Key('ingredient-register-open')));
    await tester.pump();
    await _waitFor(
      tester,
      find.byKey(const Key('ingredient-name')),
      'the register sheet',
    );
    await tester.enterText(find.byKey(const Key('ingredient-name')), name);
    await tester.pump();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    final save = find.byKey(const Key('ingredient-register'));
    await tester.scrollUntilVisible(
      save,
      80,
      scrollable: find.ancestor(of: save, matching: find.byType(Scrollable)),
    );
    await tester.tap(save);
    await tester.pump();
    await _waitUntil(
      tester,
      () => find.byKey(const Key('ingredient-register')).evaluate().isEmpty,
      'the register sheet to close',
    );
    expect(find.text(name), findsWidgets);
  }

  /// Chooses a beverage kind on the ingredient step, before registering.
  Future<void> selectIngredientKind(WidgetTester tester, String label) async {
    final segment = find.descendant(
      of: find.byType(SegmentedButton<BeverageKind>),
      matching: find.text(label),
    );
    await tester.tap(segment);
    await tester.pump();
  }

  Future<void> fillBrewParameters(
    WidgetTester tester, {
    required String title,
    String? method,
  }) async {
    await _enter(tester, const Key('extraction-title'), title);
    await _enter(tester, const Key('extraction-temp'), temperature);
    await _enter(tester, const Key('extraction-dose'), dose);
    await _enter(tester, const Key('extraction-grind'), grind);
    await _enter(tester, const Key('extraction-grinder'), grinder);
    await _selectMethod(tester, method ?? l10n.methodV60);
  }

  /// Replaces the dose on the extraction step. The tile shows it as `N g`.
  Future<void> setDose(WidgetTester tester, String grams) async {
    await _enter(tester, const Key('extraction-dose'), grams);
  }

  /// Types a duration the extraction step accepts (`m:ss` or plain seconds).
  Future<void> setExtractionDuration(
    WidgetTester tester,
    String value,
  ) async {
    await _enter(tester, const Key('extraction-duration'), value);
    expect(
      _fieldText(tester, const Key('extraction-duration')),
      value,
      reason: 'The duration field did not keep "$value".',
    );
    expect(find.text(l10n.timeFormatError), findsNothing);
  }

  /// Starts the stopwatch, stops it, and checks the reading was kept.
  Future<void> timeWithStopwatch(WidgetTester tester) async {
    final start = find.byKey(const Key('stopwatch-start'));
    await _reveal(tester, _wizardScrollable(), start);
    await tester.tap(start);
    await tester.pump();
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    await tester.pump();
    await tester.tap(find.byKey(const Key('stopwatch-stop')));
    await tester.pump();

    final readout = tester
        .widget<Text>(find.byKey(const Key('stopwatch-readout')))
        .data;
    expect(readout, isNot('00:00.0'));
    final typed = tester
        .widget<TextField>(find.byKey(const Key('extraction-duration')))
        .controller!
        .text;
    expect(typed, matches(RegExp(r'^\d+:\d{2}(\.\d)?$')));
  }

  Future<void> nudgeAcidity(WidgetTester tester) async {
    final slider = find.byType(Slider).first;
    await _reveal(tester, _wizardScrollable(), slider);
    await tester.drag(slider, const Offset(70, 0));
    await tester.pump();
  }

  Future<void> addTag(WidgetTester tester, String tag) async {
    final field = find.byKey(const Key('flavor-tag'));
    await _reveal(tester, _wizardScrollable(), field);
    await tester.enterText(field, tag);
    await tester.pump();
    await tester.tap(find.byTooltip(l10n.addTag));
    await tester.pump();
  }

  Future<void> rejectBlankInstruction(WidgetTester tester) async {
    final before = instructionLines(tester);
    await _enter(tester, const Key('instruction-input'), '   ');
    await tester.tap(find.byKey(const Key('instruction-add')));
    await tester.pump();
    await _waitFor(
      tester,
      find.text(l10n.validationEmptyInstruction),
      'the empty-instruction error',
    );
    expect(instructionLines(tester), before);
  }

  /// 281 characters cannot be saved. The field caps input at 280; a longer
  /// value that still gets through must show the validation error.
  Future<void> rejectOverlongInstruction(WidgetTester tester) async {
    final field = find.byKey(const Key('instruction-input'));
    await _reveal(tester, _wizardScrollable(), field);
    await tester.enterText(field, 'b' * 281);
    await tester.pump();
    final text = tester.widget<TextField>(field).controller!.text;
    if (text.trim().length > 280) {
      await tester.tap(find.byKey(const Key('instruction-add')));
      await tester.pump();
      await _waitFor(
        tester,
        find.text(l10n.validationInstructionTooLong(280)),
        'the long-instruction error',
      );
      expect(find.text(l10n.noExtraSteps), findsOneWidget);
    } else {
      expect(text.length, 280);
    }
    await tester.enterText(field, '');
    await tester.pump();
  }

  /// An instruction of exactly 280 characters is accepted, then removed.
  Future<void> acceptBoundaryInstruction(WidgetTester tester) async {
    final text = 'a' * 280;
    await addInstruction(tester, text);
    expect(instructionLines(tester), ['1. $text']);
    await tester.tap(find.byTooltip(l10n.removeStep));
    await tester.pump();
    await _waitFor(
      tester,
      find.text(l10n.noExtraSteps),
      'the empty instruction list',
    );
    // clear() after the 280-character step can leave the macOS IME holding
    // the old value. Drop that composing text before the next entry.
    _setFieldText(tester, const Key('instruction-input'), '');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
  }

  Future<void> addInstruction(WidgetTester tester, String text) async {
    _dismissSnackBars(tester);
    final field = find.byKey(const Key('instruction-input'));
    await _reveal(tester, _wizardScrollable(), field);
    await tester.enterText(field, text);
    await tester.pump();
    // Integration tests talk to the real IME. After a max-length value,
    // enterText can be ignored, so commit the string on the controller
    // immediately before Add reads it.
    _setFieldText(tester, const Key('instruction-input'), text);
    await tester.tap(find.byKey(const Key('instruction-add')));
    final trimmed = text.trim();
    await _waitUntil(
      tester,
      () => instructionLines(tester).any((line) => line.endsWith(trimmed)),
      'the instruction "$trimmed". '
      'Field: "${_fieldText(tester, const Key('instruction-input'))}". '
      'Lines: ${instructionLines(tester)}',
    );
  }

  List<String> instructionLines(WidgetTester tester) {
    return tester
        .widgetList<Text>(
          find.descendant(
            of: find.byType(RecipeWizardScreen),
            matching: find.byWidgetPredicate((widget) {
              final data = widget is Text ? widget.data : null;
              return data != null && RegExp(r'^\d+\. ').hasMatch(data);
            }),
          ),
        )
        .map((text) => text.data!)
        .toList();
  }

  /// Drags the first extra step downward until the list order changes.
  Future<void> reorderFirstInstruction(WidgetTester tester) async {
    final before = instructionLines(tester);
    await _dragFirstInstruction(tester, 1.6);
    if (_sameLines(instructionLines(tester), before)) {
      await _dragFirstInstruction(tester, 2.6);
    }
    expect(
      instructionLines(tester),
      isNot(before),
      reason: 'Reordering left the steps unchanged: $before',
    );
  }

  Future<void> removeAllInstructions(WidgetTester tester) async {
    var guard = 0;
    while (find.byTooltip(l10n.removeStep).evaluate().isNotEmpty) {
      await tester.tap(find.byTooltip(l10n.removeStep).first);
      await tester.pump();
      guard += 1;
      expect(guard, lessThan(40), reason: 'Instructions did not clear.');
    }
    expect(find.text(l10n.noExtraSteps), findsOneWidget);
  }

  Future<void> skipInstructions(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('instructions-skip')));
    await tester.pump();
    await _waitFor(
      tester,
      find.byKey(const Key('media-add')),
      'the photo step',
    );
  }

  Future<void> openStep(
    WidgetTester tester,
    String label,
    Finder landmark,
  ) async {
    await tester.tap(find.text(label).first);
    await tester.pump();
    await _waitFor(tester, landmark, label);
  }

  Future<void> next(WidgetTester tester, Finder landmark) async {
    _dismissSnackBars(tester);
    await tester.pump();
    final button = find.byKey(const Key('wizard-next'));
    expect(
      tester.widget<ButtonStyleButton>(button).onPressed,
      isNotNull,
      reason: 'Next is disabled.',
    );
    await tester.tap(button);
    await tester.pump();
    await _waitFor(tester, landmark, 'the next wizard step');
  }

  Future<void> finish(WidgetTester tester) async {
    _dismissSnackBars(tester);
    await tester.pump();
    final button = find.byKey(const Key('wizard-finish'));
    expect(
      tester.widget<ButtonStyleButton>(button).onPressed,
      isNotNull,
      reason: 'Finish is disabled.',
    );
    await tester.tap(button);
    await tester.pump();
    await _waitUntil(
      tester,
      () => find.byType(RecipeWizardScreen).evaluate().isEmpty,
      'the wizard to close',
      timeout: const Duration(seconds: 40),
    );
  }

  Future<void> backToJournal(WidgetTester tester) async {
    await tester.tap(find.byType(BackButton));
    await tester.pump();
    await _waitUntil(
      tester,
      () =>
          find.byType(BrewModeScreen).evaluate().isEmpty &&
          find.byType(RecipeWizardScreen).evaluate().isEmpty,
      'the journal',
    );
  }

  Future<void> openRecipe(WidgetTester tester, String title) async {
    final tile = find.descendant(
      of: find.byType(RecipeListScreen),
      matching: find.text(title),
    );
    await _waitFor(tester, tile, title);
    // Versions share a title. The list is newest first.
    await tester.ensureVisible(tile.first);
    await tester.tap(tile.first);
    await tester.pump();
    await _waitForBrew(tester);
  }

  Future<void> editRecipe(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('brew-edit')));
    await tester.pump();
    await _waitFor(
      tester,
      find.byKey(const Key('ingredient-search')),
      'the recipe editor',
    );
  }

  Future<void> expectOnList(WidgetTester tester, String title) async {
    await _waitFor(
      tester,
      find.descendant(
        of: find.byType(RecipeListScreen),
        matching: find.text(title),
      ),
      title,
    );
  }

  /// [marker] is text that appears on one tile only, such as the bean name.
  Future<void> tapTileFavorite(
    WidgetTester tester, {
    required Type scope,
    required String marker,
  }) async {
    final heart = _tileFavorite(scope, marker);
    await _waitFor(tester, heart, 'the favorite heart for $marker');
    await _waitUntil(
      tester,
      () => _heartEnabled(tester, heart),
      'the favorite heart for $marker to accept a tap',
    );
    await tester.ensureVisible(heart);
    await tester.tap(heart);
    await tester.pump();
  }

  Future<void> expectTileFavorite(
    WidgetTester tester, {
    required Type scope,
    required String marker,
    required bool selected,
  }) async {
    await _waitUntil(
      tester,
      () {
        final heart = _tileFavorite(scope, marker);
        if (heart.evaluate().isEmpty) return false;
        return tester.widget<FavoriteIconButton>(heart).selected == selected;
      },
      selected ? '$marker to be a favorite' : '$marker to be off the favorites',
    );
  }

  Future<void> expectReplaceFavoriteDialog(
    WidgetTester tester, {
    bool team = false,
  }) async {
    final title = team
        ? l10n.favoriteNameTakenTitleTeam
        : l10n.favoriteNameTakenTitle;
    final body = team
        ? l10n.favoriteNameTakenBodyTeam
        : l10n.favoriteNameTakenBody;
    await _waitFor(
      tester,
      find.text(title).hitTestable(),
      'the replace-favorite dialog',
    );
    expect(find.text(body).hitTestable(), findsOneWidget);
    expect(
      find.byKey(const Key('favorite-conflict-close')).hitTestable(),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('favorite-conflict-cancel')).hitTestable(),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('favorite-conflict-accept')).hitTestable(),
      findsOneWidget,
    );
  }

  Future<void> closeReplaceFavoriteDialog(
    WidgetTester tester, {
    bool team = false,
  }) {
    return _dismissReplaceFavoriteDialog(
      tester,
      const Key('favorite-conflict-close'),
      team: team,
    );
  }

  Future<void> cancelReplaceFavoriteDialog(
    WidgetTester tester, {
    bool team = false,
  }) {
    return _dismissReplaceFavoriteDialog(
      tester,
      const Key('favorite-conflict-cancel'),
      team: team,
    );
  }

  Future<void> acceptReplaceFavoriteDialog(
    WidgetTester tester, {
    bool team = false,
  }) {
    return _dismissReplaceFavoriteDialog(
      tester,
      const Key('favorite-conflict-accept'),
      team: team,
    );
  }

  /// The home app-bar heart. On shows only this account's favorite recipes.
  Future<void> setHomeFavoritesOnly(WidgetTester tester, bool only) async {
    final button = find.byKey(const Key('recipe-list-favorites')).hitTestable();
    await _waitFor(tester, button, 'the home favorites filter');
    if (tester.widget<FavoriteIconButton>(button).selected == only) return;
    await tester.tap(button);
    await tester.pump();
    await _waitUntil(
      tester,
      () =>
          find
              .byKey(const Key('recipe-list-favorites'))
              .hitTestable()
              .evaluate()
              .isNotEmpty &&
          tester
                  .widget<FavoriteIconButton>(
                    find
                        .byKey(const Key('recipe-list-favorites'))
                        .hitTestable(),
                  )
                  .selected ==
              only,
      only
          ? 'the home list to show favorites'
          : 'the home list to show every recipe',
    );
  }

  /// The team app-bar heart. On shows only that team's favorite recipes.
  Future<void> setTeamFavoritesOnly(WidgetTester tester, bool only) async {
    final button = find.byKey(const Key('team-list-favorites')).hitTestable();
    await _waitFor(tester, button, 'the team favorites filter');
    if (tester.widget<FavoriteIconButton>(button).selected == only) return;
    await tester.tap(button);
    await tester.pump();
    await _waitUntil(
      tester,
      () =>
          find
              .byKey(const Key('team-list-favorites'))
              .hitTestable()
              .evaluate()
              .isNotEmpty &&
          tester
                  .widget<FavoriteIconButton>(
                    find.byKey(const Key('team-list-favorites')).hitTestable(),
                  )
                  .selected ==
              only,
      only
          ? 'the team list to show favorites'
          : 'the team list to show every recipe',
    );
  }

  /// A team heart that stays visible and selected, and does not accept a tap.
  Future<void> expectTileFavoriteLocked(
    WidgetTester tester, {
    required Type scope,
    required String marker,
    required bool selected,
  }) async {
    await _waitUntil(
      tester,
      () {
        final heart = _tileFavorite(scope, marker, hitTestable: false);
        if (heart.evaluate().isEmpty) return false;
        if (tester.widget<FavoriteIconButton>(heart).selected != selected) {
          return false;
        }
        return !_heartEnabled(tester, heart);
      },
      selected
          ? '$marker to stay a locked team favorite'
          : '$marker to stay a locked empty heart',
    );
  }

  Future<void> expectHomeMessage(WidgetTester tester, String message) async {
    await _waitFor(
      tester,
      find.text(message).hitTestable(),
      message,
    );
  }

  Future<void> expectBrewFavorite(
    WidgetTester tester, {
    required bool selected,
  }) async {
    await _waitForBrew(tester);
    await _waitUntil(
      tester,
      () {
        final heart = find.byKey(const Key('brew-favorite')).hitTestable();
        if (heart.evaluate().isEmpty) return false;
        return tester.widget<FavoriteIconButton>(heart).selected == selected;
      },
      selected
          ? 'the brew-mode heart to be filled'
          : 'the brew-mode heart to be an outline',
    );
  }

  /// The brew heart stays visible and does not accept a tap.
  Future<void> expectBrewFavoriteLocked(
    WidgetTester tester, {
    required bool selected,
  }) async {
    await _waitForBrew(tester);
    await _waitUntil(
      tester,
      () {
        final heart = find.byKey(const Key('brew-favorite'));
        if (heart.evaluate().isEmpty) return false;
        if (tester.widget<FavoriteIconButton>(heart).selected != selected) {
          return false;
        }
        return !_heartEnabled(tester, heart);
      },
      selected
          ? 'the brew-mode heart to stay filled and locked'
          : 'the brew-mode heart to stay empty and locked',
    );
  }

  /// Taps the brew heart without waiting for it to flip.
  ///
  /// A same-name save opens the replace dialog and leaves the heart as it was.
  Future<void> tapBrewFavorite(WidgetTester tester) async {
    final heart = find.byKey(const Key('brew-favorite')).hitTestable();
    await _waitFor(tester, heart, 'the brew-mode favorite heart');
    await _waitUntil(
      tester,
      () => _heartEnabled(tester, heart),
      'the brew-mode heart to accept a tap',
    );
    await tester.tap(heart);
    await tester.pump();
  }

  Future<void> toggleBrewFavorite(WidgetTester tester) async {
    final heart = find.byKey(const Key('brew-favorite')).hitTestable();
    await _waitFor(tester, heart, 'the brew-mode favorite heart');
    final wasSelected = tester.widget<FavoriteIconButton>(heart).selected;
    await tapBrewFavorite(tester);
    await expectBrewFavorite(tester, selected: !wasSelected);
  }

  Future<void> expectBrewText(WidgetTester tester, String text) async {
    await _waitUntil(
      tester,
      () =>
          find.byKey(const Key('brew-share')).evaluate().isNotEmpty &&
          find
              .descendant(
                of: find.byType(BrewModeScreen),
                matching: find.text(text),
              )
              .evaluate()
              .isNotEmpty,
      text,
    );
  }

  Future<void> expectBrewTimer(WidgetTester tester) async {
    await _waitForBrew(tester);
    final timer = find.descendant(
      of: find.byType(BrewModeScreen),
      matching: find.byKey(const Key('brew-timer')),
    );
    expect(
      await _scan(tester, _brewScrollable(), timer),
      isTrue,
      reason: 'Brew mode has no extraction timer.',
    );
  }

  /// A recipe with no extraction time: parameters can still render, and the
  /// timer controls are absent.
  Future<void> expectNoBrewTimer(WidgetTester tester) async {
    await _waitForBrew(tester);
    final timer = find.descendant(
      of: find.byType(BrewModeScreen),
      matching: find.byKey(const Key('brew-timer')),
    );
    final scrollable = _brewScrollable();
    expect(
      await _scan(tester, scrollable, timer),
      isFalse,
      reason: 'A recipe with no extraction time still shows the timer.',
    );
    expect(find.byKey(const Key('brew-start')), findsNothing);
    expect(find.byKey(const Key('brew-pause')), findsNothing);
    expect(find.byKey(const Key('brew-stop-alarm')), findsNothing);
    expect(
      await _scan(tester, scrollable, find.text(l10n.noExtractionTime)),
      isTrue,
      reason: 'Brew mode did not say that no extraction time was recorded.',
    );
  }

  String brewTimerReadout(WidgetTester tester) {
    return tester
        .widget<Text>(find.byKey(const Key('brew-timer-readout')))
        .data!;
  }

  Future<void> selectBrewMode(
    WidgetTester tester,
    BrewTimerMode mode,
  ) async {
    final label = find.text(
      mode == BrewTimerMode.countUp ? l10n.countUp : l10n.countDown,
    );
    await _reveal(tester, _brewScrollable(), label);
    await tester.tap(label);
    await tester.pump();
    expect(brewTimerSelection(tester), {mode});
  }

  Set<BrewTimerMode> brewTimerSelection(WidgetTester tester) {
    return tester
        .widget<SegmentedButton<BrewTimerMode>>(
          find.byType(SegmentedButton<BrewTimerMode>),
        )
        .selected;
  }

  /// Waits until Start has prepared the alarm and the ticker is running.
  Future<void> startBrewTimer(WidgetTester tester) async {
    final start = find.byKey(const Key('brew-start'));
    await _reveal(tester, _brewScrollable(), start);
    await tester.tap(start);
    await tester.pump();
    await _waitFor(
      tester,
      find.byKey(const Key('brew-pause')),
      'the running timer',
      timeout: const Duration(seconds: 15),
    );
    expect(find.byType(SegmentedButton<BrewTimerMode>), findsNothing);
    expect(find.byKey(const Key('brew-stop-alarm')), findsNothing);
  }

  /// Pauses and returns the readout, which must stay put while paused.
  Future<String> pauseBrewTimer(WidgetTester tester) async {
    final pause = find.byKey(const Key('brew-pause'));
    await _reveal(tester, _brewScrollable(), pause);
    await tester.tap(pause);
    await tester.pump();
    await _waitFor(
      tester,
      find.byKey(const Key('brew-resume')),
      'the paused timer',
    );
    expect(find.byKey(const Key('brew-pause')), findsNothing);
    return brewTimerReadout(tester);
  }

  Future<void> resumeBrewTimer(WidgetTester tester) async {
    final resume = find.byKey(const Key('brew-resume'));
    await _reveal(tester, _brewScrollable(), resume);
    await tester.tap(resume);
    await tester.pump();
    await _waitFor(
      tester,
      find.byKey(const Key('brew-pause')),
      'the resumed timer',
    );
  }

  Future<void> stopBrewTimer(WidgetTester tester) async {
    final stop = find.byKey(const Key('brew-stop'));
    await _reveal(tester, _brewScrollable(), stop);
    await tester.tap(stop);
    await tester.pump();
    await _waitFor(
      tester,
      find.byKey(const Key('brew-start')),
      'the idle timer',
    );
    expect(find.byKey(const Key('brew-stop-alarm')), findsNothing);
  }

  Future<void> waitForBrewAlarm(
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 20),
  }) {
    return _waitFor(
      tester,
      find.byKey(const Key('brew-stop-alarm')),
      'the finished alarm',
      timeout: timeout,
    );
  }

  /// The highlighted finished readout. Count-down clamps at zero; count-up
  /// shows the elapsed time, which has reached [target].
  void expectBrewFinished(
    WidgetTester tester, {
    required Duration target,
    required bool countDown,
  }) {
    final timer = find.byKey(const Key('brew-timer'));
    final card = tester.widget<Card>(timer);
    final theme = Theme.of(tester.element(timer));
    expect(card.color, theme.colorScheme.tertiaryContainer);
    final readout = tester.widget<Text>(
      find.byKey(const Key('brew-timer-readout')),
    );
    expect(readout.style?.fontWeight, FontWeight.bold);
    expect(readout.style?.color, theme.colorScheme.onTertiaryContainer);
    expect(find.byKey(const Key('brew-stop-alarm')), findsOneWidget);
    expect(find.byKey(const Key('brew-start')), findsNothing);
    expect(find.byType(SegmentedButton<BrewTimerMode>), findsNothing);
    final shown = _parseStopwatch(readout.data!);
    if (countDown) {
      expect(shown, Duration.zero);
    } else {
      expect(shown, greaterThanOrEqualTo(target));
    }
  }

  Future<void> stopBrewAlarm(WidgetTester tester) async {
    final button = find.byKey(const Key('brew-stop-alarm'));
    await _reveal(tester, _brewScrollable(), button);
    await tester.tap(button);
    await tester.pump();
    await _waitFor(
      tester,
      find.byKey(const Key('brew-start')),
      'the timer after the alarm stops',
    );
    expect(
      tester.widget<Card>(find.byKey(const Key('brew-timer'))).color,
      isNull,
    );
    expect(find.byKey(const Key('brew-stop-alarm')), findsNothing);
    expect(find.byType(SegmentedButton<BrewTimerMode>), findsOneWidget);
  }

  /// Polls until Brew Mode is showing [steps], including while a reload
  /// replaces the previous detail.
  Future<void> expectBrewInstructions(
    WidgetTester tester,
    List<String> steps,
  ) async {
    List<String>? latest;
    final deadline = DateTime.now().add(const Duration(seconds: 25));
    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 100));
      latest = await _readBrewInstructions(tester);
      if (latest != null && _sameLines(latest, steps)) return;
    }
    fail(
      'Brew instructions were ${latest ?? 'still loading'}. '
      'Visible text: ${_visibleText(tester)}',
    );
  }

  /// JPEG bytes larger than 512 KB, the previous API request cap.
  Future<File> oversizedPhoto() async {
    final existing = _oversizedPhoto;
    if (existing != null && existing.existsSync()) return existing;

    final bytes = _jpegLargerThan(512 * 1024);
    expect(bytes.length, greaterThan(512 * 1024));
    expect(
      img.decodeJpg(bytes),
      isNotNull,
      reason: 'Test photo is not a JPEG.',
    );

    final directory = await Directory.systemTemp.createTemp('brewsync-photo');
    final file = File('${directory.path}/cup.jpg');
    await file.writeAsBytes(bytes, flush: true);
    _photoDirectory = directory;
    _oversizedPhoto = file;
    return file;
  }

  Future<void> addOversizedPhoto(WidgetTester tester) async {
    final photo = await oversizedPhoto();
    final previous = ImagePickerPlatform.instance;
    ImagePickerPlatform.instance = _GalleryPicker(XFile(photo.path));
    try {
      final add = find.byKey(const Key('media-add'));
      await _reveal(tester, _wizardScrollable(), add);
      await tester.tap(add);
      await tester.pump();
      await _waitFor(
        tester,
        find.byTooltip(l10n.removePhoto),
        'the uploaded photo',
        timeout: const Duration(seconds: 40),
      );
    } finally {
      ImagePickerPlatform.instance = previous;
    }
  }

  Future<void> expectPhotoLoads(WidgetTester tester, Type screen) async {
    final finder = find.descendant(
      of: find.byType(screen),
      matching: find.byWidgetPredicate(
        (widget) => widget is Image && widget.image is NetworkImage,
      ),
    );
    final scrollable = screen == BrewModeScreen
        ? _brewScrollable()
        : _wizardScrollable();
    final deadline = DateTime.now().add(const Duration(seconds: 30));
    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 100));
      if (scrollable.evaluate().isEmpty) continue;
      if (await _scan(tester, scrollable, finder)) {
        await _expectNetworkImageLoads(tester, finder);
        return;
      }
    }
    fail(
      'No photo loaded from its public URL. '
      'Visible text: ${_visibleText(tester)}',
    );
  }

  /// Brew Mode has finished reloading without a photo carousel.
  Future<void> expectNoBrewPhotos(WidgetTester tester) async {
    final photos = find.descendant(
      of: find.byType(BrewModeScreen),
      matching: find.byKey(const Key('brew-photos')),
    );
    final deadline = DateTime.now().add(const Duration(seconds: 25));
    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byKey(const Key('brew-share')).evaluate().isEmpty) continue;
      final scrollable = _brewScrollable();
      if (scrollable.evaluate().isEmpty) continue;
      if (!await _scan(tester, scrollable, photos)) return;
    }
    fail(
      'The photo is still on the brew screen. Visible text: ${_visibleText(tester)}',
    );
  }

  Future<void> removePhoto(WidgetTester tester) async {
    await tester.tap(find.byTooltip(l10n.removePhoto));
    await tester.pump();
    await _waitUntil(
      tester,
      () => find.byTooltip(l10n.removePhoto).evaluate().isEmpty,
      'the photo to be removed',
      timeout: const Duration(seconds: 30),
    );
  }

  Future<void> close() async {
    final directory = _photoDirectory;
    if (directory != null && directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
  }

  Future<void> _useDesktopSurface(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1100));
    await tester.pump();
  }

  Future<void> _enter(WidgetTester tester, Key key, String value) async {
    final field = find.byKey(key);
    await _reveal(tester, _wizardScrollable(), field);
    await tester.enterText(field, value);
    await tester.pump();
  }

  void _setFieldText(WidgetTester tester, Key key, String value) {
    tester
        .widget<TextField>(find.byKey(key))
        .controller!
        .value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  String _fieldText(WidgetTester tester, Key key) {
    return tester.widget<TextField>(find.byKey(key)).controller?.text ?? '';
  }

  Future<void> _selectMethod(WidgetTester tester, String label) async {
    final field = find.byKey(const Key('extraction-method'));
    await _reveal(tester, _wizardScrollable(), field);
    await tester.tap(field);
    await tester.pump();
    await _waitFor(tester, find.text(label), label);
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.text(label).last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> _dragFirstInstruction(WidgetTester tester, double rows) async {
    final handle = find.descendant(
      of: find.byType(RecipeWizardScreen),
      matching: find.byIcon(Icons.drag_handle),
    );
    final tile = find.descendant(
      of: find.byType(RecipeWizardScreen),
      matching: find.byType(ListTile),
    );
    await _reveal(tester, _wizardScrollable(), handle.first);
    final rowHeight = tester.getSize(tile.first).height;
    final gesture = await tester.startGesture(tester.getCenter(handle.first));
    await tester.pump();
    final steps = 10;
    for (var i = 0; i < steps; i++) {
      await gesture.moveBy(Offset(0, rowHeight * rows / steps));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Finder _tileFavorite(
    Type scope,
    String marker, {
    bool hitTestable = true,
  }) {
    final markerFinder = find.descendant(
      of: find.byType(scope),
      matching: find.textContaining(marker),
    );
    final tile = find.ancestor(
      of: hitTestable ? markerFinder.hitTestable() : markerFinder,
      matching: find.byType(ListTile),
    );
    final heart = find.descendant(
      of: tile,
      matching: find.byType(FavoriteIconButton),
    );
    return hitTestable ? heart.hitTestable() : heart;
  }

  bool _heartEnabled(WidgetTester tester, Finder heart) {
    if (heart.evaluate().isEmpty) return false;
    final icon = find.descendant(of: heart, matching: find.byType(IconButton));
    if (icon.evaluate().isEmpty) return false;
    return tester.widget<IconButton>(icon).onPressed != null;
  }

  Future<void> _dismissReplaceFavoriteDialog(
    WidgetTester tester,
    Key key, {
    bool team = false,
  }) async {
    final title = team
        ? l10n.favoriteNameTakenTitleTeam
        : l10n.favoriteNameTakenTitle;
    await tester.tap(find.byKey(key).hitTestable());
    await tester.pump();
    await _waitUntil(
      tester,
      () => find.text(title).hitTestable().evaluate().isEmpty,
      'the replace-favorite dialog to close',
    );
  }

  /// Share is on every loaded recipe, including one a viewer cannot edit.
  Future<void> _waitForBrew(WidgetTester tester) {
    return _waitFor(
      tester,
      find.byKey(const Key('brew-share')),
      'brew mode',
      timeout: const Duration(seconds: 30),
    );
  }

  /// The saved steps once a detail is on screen, or null while Brew Mode
  /// is still loading its first detail.
  Future<List<String>?> _readBrewInstructions(WidgetTester tester) async {
    if (find.byKey(const Key('brew-share')).evaluate().isEmpty) return null;
    final scrollable = _brewScrollable();
    if (scrollable.evaluate().isEmpty) return null;
    final card = find.descendant(
      of: find.byType(BrewModeScreen),
      matching: find.byKey(const Key('brew-instructions')),
    );
    if (!await _scan(tester, scrollable, card)) return const [];
    return tester
        .widgetList<ListTile>(
          find.descendant(of: card, matching: find.byType(ListTile)),
        )
        .map((tile) => (tile.title! as Text).data!)
        .toList();
  }

  Future<void> _reveal(
    WidgetTester tester,
    Finder scrollable,
    Finder target,
  ) async {
    if (scrollable.evaluate().isEmpty) {
      await tester.ensureVisible(target);
      return;
    }
    final position = tester.state<ScrollableState>(scrollable).position;
    position.jumpTo(0);
    await tester.pump();
    await tester.scrollUntilVisible(target, 280, scrollable: scrollable);
    await tester.pump();
  }

  Future<bool> _scan(
    WidgetTester tester,
    Finder scrollable,
    Finder target,
  ) async {
    if (target.evaluate().isNotEmpty) return true;
    final position = tester.state<ScrollableState>(scrollable).position;
    position.jumpTo(0);
    await tester.pump();
    if (target.evaluate().isNotEmpty) return true;
    var offset = 0.0;
    final extent = position.maxScrollExtent;
    while (offset < extent) {
      offset = math.min(offset + 160, extent);
      position.jumpTo(offset);
      await tester.pump();
      if (target.evaluate().isNotEmpty) return true;
    }
    return target.evaluate().isNotEmpty;
  }

  Finder _wizardScrollable() =>
      _verticalScrollable(find.byType(RecipeWizardScreen));

  Finder _brewScrollable() => _verticalScrollable(find.byType(BrewModeScreen));

  Finder _verticalScrollable(Finder scope) {
    return find.descendant(
      of: scope,
      matching: find.byWidgetPredicate(
        (widget) => widget is Scrollable && widget.axis == Axis.vertical,
      ),
    );
  }

  Future<void> _expectNetworkImageLoads(
    WidgetTester tester,
    Finder finder,
  ) async {
    final image = tester.widget<Image>(finder.first);
    final provider = image.image as NetworkImage;
    expect(provider.url, startsWith('http'), reason: provider.url);
    final completer = Completer<void>();
    final stream = provider.resolve(
      createLocalImageConfiguration(tester.element(finder.first)),
    );
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        stream.removeListener(listener);
        if (!completer.isCompleted) {
          expect(info.image.width, greaterThan(0));
          completer.complete();
        }
      },
      onError: (error, stackTrace) {
        stream.removeListener(listener);
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      },
    );
    stream.addListener(listener);
    await tester.runAsync(
      () => completer.future.timeout(const Duration(seconds: 20)),
    );
  }

  void _dismissSnackBars(WidgetTester tester) {
    for (final messenger in tester.stateList<ScaffoldMessengerState>(
      find.byType(ScaffoldMessenger),
    )) {
      messenger.clearSnackBars();
    }
  }

  bool _sameLines(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<void> waitFor(
    WidgetTester tester,
    Finder finder,
    String description, {
    Duration timeout = const Duration(seconds: 20),
  }) {
    return _waitFor(tester, finder, description, timeout: timeout);
  }

  Future<void> waitUntil(
    WidgetTester tester,
    bool Function() condition,
    String description, {
    Duration timeout = const Duration(seconds: 20),
  }) {
    return _waitUntil(tester, condition, description, timeout: timeout);
  }

  void dismissSnackBars(WidgetTester tester) => _dismissSnackBars(tester);

  Future<void> _waitFor(
    WidgetTester tester,
    Finder finder,
    String description, {
    Duration timeout = const Duration(seconds: 20),
  }) {
    return _waitUntil(
      tester,
      () => finder.evaluate().isNotEmpty,
      description,
      timeout: timeout,
    );
  }

  Future<void> _waitUntil(
    WidgetTester tester,
    bool Function() condition,
    String description, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 100));
      if (condition()) return;
    }
    fail(
      'Timed out waiting for $description. Visible text: ${_visibleText(tester)}',
    );
  }

  String _visibleText(WidgetTester tester) {
    return find
        .byType(Text)
        .evaluate()
        .map((element) {
          final widget = element.widget as Text;
          final text = widget.data ?? widget.textSpan?.toPlainText() ?? '';
          final trimmed = text.trim();
          if (trimmed.length <= 80) return trimmed;
          return '${trimmed.substring(0, 80)}…';
        })
        .where((text) => text.isNotEmpty)
        .join(' | ');
  }
}

Duration _parseStopwatch(String text) {
  final match = RegExp(r'^(\d+):(\d{2})\.(\d)$').firstMatch(text);
  expect(match, isNotNull, reason: 'Not a timer readout: $text');
  return Duration(
    minutes: int.parse(match![1]!),
    seconds: int.parse(match[2]!),
    milliseconds: int.parse(match[3]!) * 100,
  );
}

/// Returns a real JPEG whose file is larger than [minBytes].
Uint8List _jpegLargerThan(int minBytes) {
  final image = img.Image(width: 48, height: 48);
  for (final pixel in image) {
    pixel
      ..r = 176
      ..g = 92
      ..b = 42;
  }
  final encoded = img.encodeJpg(image, quality: 85);
  if (encoded.length > minBytes) return encoded;
  return _withCommentPadding(encoded, minBytes + 2048);
}

/// Inserts JPEG comment segments so the file exceeds [minLength] without
/// changing the picture. Decoders skip comment markers.
Uint8List _withCommentPadding(Uint8List jpeg, int minLength) {
  final builder = BytesBuilder(copy: false);
  builder.add(jpeg.sublist(0, 2));
  var guard = 0;
  while (builder.length + jpeg.length - 2 <= minLength && guard < 40) {
    const payload = 20000;
    final length = payload + 2;
    builder
      ..add([0xFF, 0xFE, (length >> 8) & 0xFF, length & 0xFF])
      ..add(Uint8List(payload));
    guard += 1;
  }
  builder.add(jpeg.sublist(2));
  return builder.toBytes();
}

class _GalleryPicker extends ImagePickerPlatform {
  _GalleryPicker(this.file);

  final XFile file;

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    return file;
  }
}
