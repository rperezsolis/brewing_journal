import 'dart:async';
import 'dart:io';

import 'package:brewing_journal_flutter/data/services/share_service.dart';
import 'package:brewing_journal_flutter/l10n/app_localizations.dart';
import 'package:brewing_journal_flutter/main.dart' as app;
import 'package:brewing_journal_flutter/ui/core/widgets/flavor_radar_chart.dart';
import 'package:brewing_journal_flutter/ui/features/share/share_card_layout.dart';
import 'package:brewing_journal_flutter/ui/features/share/view/recipe_share_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;

import 'recipe_harness.dart';

/// Result strings `share_plus` turns into [ShareResultStatus].
const shareSheetSuccess = 'success';
const shareSheetDismissed = '';
const shareSheetUnavailable = 'dev.fluttercommunity.plus/share/unavailable';

const _shareChannel = MethodChannel('dev.fluttercommunity.plus/share');

/// Drives the share screen against the development server.
///
/// The card, the PNG capture, and the download file are real. The platform
/// share sheet is answered here so the test does not wait on the OS dialog.
class ShareHarness {
  ShareHarness(this.recipes);

  final RecipeHarness recipes;

  AppLocalizations get l10n => recipes.l10n;

  final List<MethodCall> calls = [];

  /// What the stubbed share sheet returns. Read when the sheet is invoked.
  String sheetResult = shareSheetSuccess;

  void prepare(WidgetTester tester) {
    calls.clear();
    sheetResult = shareSheetSuccess;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      _shareChannel,
      (call) async {
        calls.add(call);
        return sheetResult;
      },
    );
  }

  Future<void> saveRecipe(
    WidgetTester tester, {
    required String title,
    required String bean,
    String? kind,
    String? method,
    String? duration,
    String? tag,
    List<String> instructions = const [],
  }) async {
    await recipes.startNewRecipe(tester);
    if (kind != null) await recipes.selectIngredientKind(tester, kind);
    await recipes.registerBean(tester, bean);
    await recipes.next(tester, find.text(l10n.brewParameters));
    await recipes.fillBrewParameters(tester, title: title, method: method);
    if (duration != null) {
      await recipes.setExtractionDuration(tester, duration);
    }
    await recipes.next(tester, find.text(l10n.flavorMap));
    if (tag != null) await recipes.addTag(tester, tag);
    await recipes.next(tester, find.text(l10n.extraSteps));
    for (final step in instructions) {
      await recipes.addInstruction(tester, step);
    }
    await recipes.next(tester, find.byKey(const Key('media-add')));
    await recipes.finish(tester);
  }

  Future<void> openFromBrew(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('brew-share')));
    await tester.pump();
    await _waitForCard(tester, 'the share card');
    expect(find.byKey(const Key('share-download')), findsNothing);
    expect(find.text(l10n.sharingNotSupported), findsNothing);
  }

  /// Opens `/recipes/:id/share` with no Brew Mode extra, as a refresh would.
  Future<void> openFromRecipeUrl(WidgetTester tester) async {
    final location = _uri(tester);
    expect(location.path, matches(RegExp(r'^/recipes/[^/]+$')));
    // push completes when the route is popped, so the test must not await it.
    unawaited(_router(tester).push('${location.path}/share'));
    await tester.pump();
    await _waitForCard(tester, 'the share card loaded by id');
  }

  Future<void> close(WidgetTester tester) async {
    await tester.tap(find.byType(BackButton).hitTestable());
    await tester.pump();
    await recipes.waitFor(
      tester,
      find.byKey(const Key('brew-share')),
      'brew mode',
    );
    expect(find.byType(RecipeShareCard), findsNothing);
  }

  void expectCard(
    WidgetTester tester, {
    required String title,
    required String kind,
    required String ingredient,
    required String method,
    required List<String> instructions,
    String? tag,
    String? timer,
  }) {
    final card = find.byType(RecipeShareCard);
    expect(card, findsOneWidget);
    expect(_onCard(title), findsOneWidget);
    expect(_onCard(l10n.kindAndName(kind, ingredient)), findsOneWidget);
    expect(
      _onCard(
        l10n.brewingSummaryWithWater(
          method,
          RecipeHarness.dose,
          RecipeHarness.water,
          RecipeHarness.temperature,
        ),
      ),
      findsOneWidget,
    );
    expect(
      _onCard(l10n.grindingSummary(RecipeHarness.grind, RecipeHarness.grinder)),
      findsOneWidget,
    );
    if (timer == null) {
      expect(
        find.descendant(of: card, matching: find.textContaining('Timer:')),
        findsNothing,
      );
    } else {
      expect(_onCard(timer), findsOneWidget);
    }
    if (tag == null) {
      expect(
        find.descendant(of: card, matching: find.byType(Chip)),
        findsNothing,
      );
    } else {
      expect(_onCard(tag), findsOneWidget);
    }

    final preview = visibleInstructions(instructions);
    expect(
      find.descendant(
        of: card,
        matching: find.byKey(const Key('share-instructions')),
      ),
      preview.rows.isEmpty ? findsNothing : findsOneWidget,
    );
    for (final row in preview.rows) {
      expect(_onCard(row), findsOneWidget);
    }
    for (final row in instructions.skip(preview.rows.length)) {
      expect(_onCard(row), findsNothing);
    }
    if (preview.moreCount == 0) {
      expect(
        find.descendant(of: card, matching: find.textContaining(' more')),
        findsNothing,
      );
    } else {
      expect(_onCard(l10n.moreCount(preview.moreCount)), findsOneWidget);
    }

    expect(_onCard(l10n.madeWithBrewSync), findsOneWidget);
    expect(
      find.descendant(
        of: card,
        matching: find.byKey(const Key('share-footer')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: card,
        matching: find.byKey(FlavorRadarChart.plotKey),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: card, matching: find.byType(Image)),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  }

  /// Taps Share and waits until the sheet has answered and the button is idle.
  Future<MethodCall> submit(
    WidgetTester tester, {
    required bool showsDownload,
  }) async {
    calls.clear();
    final button = _submitButton();
    expect(
      tester.widget<FilledButton>(button).onPressed,
      isNotNull,
      reason: 'Share is disabled.',
    );
    await tester.tap(button);
    await tester.pump();
    await recipes.waitUntil(
      tester,
      () {
        if (calls.isEmpty) return false;
        final enabled =
            tester.widget<FilledButton>(_submitButton()).onPressed != null;
        final download = find
            .byKey(const Key('share-download'))
            .evaluate()
            .isNotEmpty;
        return enabled && download == showsDownload;
      },
      'the share sheet to finish',
      timeout: const Duration(seconds: 30),
    );
    expect(calls, hasLength(1));
    expect(tester.takeException(), isNull);
    return calls.single;
  }

  /// The sheet received one PNG and no caption. The file is 1080×1350.
  void expectImageOnly(MethodCall call, {required String title}) {
    expect(call.method, 'share');
    final args = Map<Object?, Object?>.from(call.arguments as Map);
    expect(args.containsKey('text'), isFalse);
    expect(args.containsKey('uri'), isFalse);
    expect(args['subject'], title);
    final paths = (args['paths'] as List).cast<String>();
    expect(paths, hasLength(1));
    expect(paths.single, endsWith(shareImageName));
    expect((args['mimeTypes'] as List).cast<String>(), ['image/png']);
    expect(args['originWidth'], greaterThan(0));
    expect(args['originHeight'], greaterThan(0));
    expectPng(File(paths.single).readAsBytesSync());
  }

  Future<void> downloadAndExpectPng(WidgetTester tester) async {
    final file = File(shareImageName);
    if (file.existsSync()) file.deleteSync();
    expect(find.text(l10n.sharingNotSupported), findsOneWidget);
    await tester.tap(find.byKey(const Key('share-download')));
    await tester.pump();
    await recipes.waitUntil(
      tester,
      () =>
          file.existsSync() &&
          find.byKey(const Key('share-download')).evaluate().isEmpty,
      'the downloaded image',
      timeout: const Duration(seconds: 20),
    );
    expectPng(file.readAsBytesSync());
    file.deleteSync();
    expect(find.text(l10n.couldNotSaveImage), findsNothing);
    expect(find.text(l10n.sharingNotSupported), findsNothing);
  }

  void expectPng(Uint8List bytes) {
    final decoded = img.decodePng(bytes);
    expect(decoded, isNotNull, reason: 'Share image is not a PNG.');
    expect(decoded!.width, RecipeShareCard.width * 3);
    expect(decoded.height, RecipeShareCard.height * 3);
  }

  void deleteDownload() {
    final file = File(shareImageName);
    if (file.existsSync()) file.deleteSync();
  }

  Future<void> _waitForCard(WidgetTester tester, String description) {
    return recipes.waitFor(
      tester,
      find.byType(RecipeShareCard),
      description,
      timeout: const Duration(seconds: 30),
    );
  }

  Finder _onCard(String text) {
    return find.descendant(
      of: find.byType(RecipeShareCard),
      matching: find.text(text),
    );
  }

  Finder _submitButton() {
    return find.descendant(
      of: find.byKey(const Key('share-submit')),
      matching: find.byType(FilledButton),
    );
  }

  GoRouter _router(WidgetTester tester) {
    return tester.widget<app.BrewSyncApp>(find.byType(app.BrewSyncApp)).router;
  }

  Uri _uri(WidgetTester tester) => _router(tester).state.uri;
}
