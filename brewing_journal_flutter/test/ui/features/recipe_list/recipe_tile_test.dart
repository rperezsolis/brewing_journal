import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:brewing_journal_flutter/l10n/app_localizations.dart';
import 'package:brewing_journal_flutter/ui/core/analytics/screen_names.dart';
import 'package:brewing_journal_flutter/ui/core/locale_resolution.dart';
import 'package:brewing_journal_flutter/ui/features/recipe_list/view/recipe_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  final updatedAt = DateTime.utc(2026, 9, 30, 18, 19);

  Recipe recipe({String? authorName}) {
    final ownerId = const Uuid().v7obj();
    final ingredientId = const Uuid().v7obj();
    return Recipe(
      id: const Uuid().v7obj(),
      ownerId: ownerId,
      ingredientId: ingredientId,
      ingredient: Ingredient(
        id: ingredientId,
        ownerId: ownerId,
        kind: BeverageKind.coffee,
        name: 'Kenya AA',
        nameKey: 'kenya aa',
      ),
      title: 'Morning V60',
      waterTempC: 93,
      doseGrams: 15,
      grindSize: 'fine',
      grinderModel: 'Niche',
      extractionMethod: ExtractionMethod.v60,
      acidity: 0,
      sweetness: 0,
      body: 0,
      bitterness: 0,
      authorName: authorName,
      updatedAt: updatedAt,
      createdAt: updatedAt,
    );
  }

  Future<void> pump(WidgetTester tester, Recipe recipe) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        localeListResolutionCallback: resolveBrewSyncLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: ListView(
            children: [
              RecipeTile(
                recipe: recipe,
                currentScreen: ScreenNames.recipeList,
                onTap: () {},
                onFavorite: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('shows the author and the update time', (tester) async {
    await pump(tester, recipe(authorName: 'Ada Lovelace'));

    final updated = DateFormat.yMMMd(
      'en',
    ).add_jm().format(updatedAt.toLocal());
    expect(find.text('Morning V60'), findsOneWidget);
    expect(find.text('Ada Lovelace · $updated'), findsOneWidget);
    expect(find.textContaining('Kenya AA'), findsOneWidget);

    final tile = tester.getRect(find.byType(ListTile));
    final caret = tester.getCenter(find.byIcon(Icons.chevron_right));
    expect(caret.dy, closeTo(tile.center.dy, 0.5));
  });

  testWidgets('uses a fallback when the author is missing', (tester) async {
    await pump(tester, recipe());

    expect(find.textContaining('Unknown author'), findsOneWidget);
  });

  testWidgets('the favorite button toggles without opening the recipe', (
    tester,
  ) async {
    var opened = false;
    var favorited = false;
    final item = recipe()..isFavorite = true;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        localeListResolutionCallback: resolveBrewSyncLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: ListView(
            children: [
              RecipeTile(
                recipe: item,
                currentScreen: ScreenNames.recipeList,
                onTap: () => opened = true,
                onFavorite: () => favorited = true,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.favorite), findsOneWidget);
    await tester.tap(find.byIcon(Icons.favorite));
    expect(favorited, isTrue);
    expect(opened, isFalse);
  });
}
