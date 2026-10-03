import 'package:brewing_journal_flutter/l10n/app_localizations.dart';
import 'package:brewing_journal_flutter/ui/core/locale_resolution.dart';
import 'package:brewing_journal_flutter/ui/features/recipe_list/view/replace_favorite_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        localeListResolutionCallback: resolveBrewSyncLocales,
        locale: const Locale('en'),
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () => showReplaceFavoriteDialog(context),
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('explains that the name is already a favorite', (tester) async {
    await open(tester);

    expect(find.text('Already in favorites'), findsOneWidget);
    expect(
      find.text(
        'A recipe with this name is already in your favorites. Replace it with this one?',
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('favorite-conflict-close')), findsOneWidget);
    expect(find.text('Accept'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('close and cancel dismiss without replacing', (tester) async {
    await open(tester);
    await tester.tap(find.byKey(const Key('favorite-conflict-close')));
    await tester.pumpAndSettle();
    expect(find.text('Already in favorites'), findsNothing);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('favorite-conflict-cancel')));
    await tester.pumpAndSettle();
    expect(find.text('Already in favorites'), findsNothing);
  });

  testWidgets('accept dismisses the dialog', (tester) async {
    await open(tester);
    await tester.tap(find.byKey(const Key('favorite-conflict-accept')));
    await tester.pumpAndSettle();
    expect(find.text('Already in favorites'), findsNothing);
  });
}
