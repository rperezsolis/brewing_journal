import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:brewing_journal_flutter/ui/features/share/view/recipe_share_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('omits the instruction block when there are none', (
    tester,
  ) async {
    await tester.pumpWidget(_card(<String>[]));

    expect(find.byKey(const Key('share-instructions')), findsNothing);
    expect(find.text('Made with BrewSync'), findsOneWidget);
    expect(find.byKey(const Key('share-footer')), findsOneWidget);
  });

  testWidgets('six instructions show three rows plus +3 more', (tester) async {
    await tester.pumpWidget(
      _card(const ['bloom', 'pour', 'stir', 'wait', 'drawdown', 'serve']),
    );

    expect(find.text('bloom'), findsOneWidget);
    expect(find.text('pour'), findsOneWidget);
    expect(find.text('stir'), findsOneWidget);
    expect(find.text('wait'), findsNothing);
    expect(find.text('+3 more'), findsOneWidget);
    expect(find.text('Made with BrewSync'), findsOneWidget);
  });

  testWidgets('a 280-character instruction does not overflow', (tester) async {
    await tester.pumpWidget(_card(['a' * 280]));

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('share-instructions')), findsOneWidget);
    expect(find.text('Made with BrewSync'), findsOneWidget);
  });

  testWidgets('the footer is present when the recipe has a duration', (
    tester,
  ) async {
    await tester.pumpWidget(
      _card(const ['bloom'], duration: const Duration(minutes: 3)),
    );

    expect(find.text('3:00'), findsOneWidget);
    expect(find.text('Made with BrewSync'), findsOneWidget);
  });
}

Widget _card(List<String> instructions, {Duration? duration}) {
  return MaterialApp(
    home: RecipeShareCard(detail: _detail(instructions, duration: duration)),
  );
}

RecipeDetail _detail(List<String> instructions, {Duration? duration}) {
  final id = const Uuid().v7obj();
  final ownerId = const Uuid().v7obj();
  final ingredientId = const Uuid().v7obj();
  return RecipeDetail(
    recipe: Recipe(
      id: id,
      ownerId: ownerId,
      ingredientId: ingredientId,
      title: 'Morning V60',
      waterTempC: 93,
      doseGrams: 15,
      grindSize: 'Medium-fine',
      grinderModel: 'Comandante C40',
      extractionMethod: ExtractionMethod.v60,
      extractionDuration: duration,
      acidity: 3,
      sweetness: 4,
      body: 2,
      bitterness: 1,
    ),
    ingredient: Ingredient(
      id: ingredientId,
      ownerId: ownerId,
      kind: BeverageKind.coffee,
      name: 'Ethiopia Guji',
      nameKey: 'ethiopia guji',
    ),
    instructions: [
      for (var i = 0; i < instructions.length; i++)
        RecipeInstruction(recipeId: id, sortOrder: i, text: instructions[i]),
    ],
    flavorTags: [
      RecipeFlavorTag(recipeId: id, tag: 'Fruity', tagKey: 'fruity'),
    ],
    photos: const [],
    access: RecipeAccess(canEdit: true, canDelete: true),
  );
}
