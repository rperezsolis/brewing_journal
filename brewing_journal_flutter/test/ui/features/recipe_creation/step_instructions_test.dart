import 'package:brewing_journal_flutter/data/repositories/fake_ingredient_repository.dart';
import 'package:brewing_journal_flutter/data/repositories/fake_recipe_media_repository.dart';
import 'package:brewing_journal_flutter/data/repositories/fake_recipe_repository.dart';
import 'package:brewing_journal_flutter/ui/features/recipe_creation/cubit/recipe_creation_cubit.dart';
import 'package:brewing_journal_flutter/ui/features/recipe_creation/view/step_instructions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late RecipeCreationCubit cubit;

  setUp(() {
    final ingredients = FakeIngredientRepository();
    cubit = RecipeCreationCubit(
      recipes: FakeRecipeRepository(ingredients),
      ingredients: ingredients,
      media: FakeRecipeMediaRepository(),
    );
  });

  tearDown(() => cubit.close());

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: const StepInstructions(),
          ),
        ),
      ),
    );
  }

  testWidgets('dragging the first row below the second swaps them', (
    tester,
  ) async {
    cubit
      ..addInstruction('grind')
      ..addInstruction('bloom');
    await pump(tester);
    expect(find.text('1. grind'), findsOneWidget);

    final firstHandle = find.byIcon(Icons.drag_handle).first;
    final rowHeight = tester.getSize(find.byType(ListTile).first).height;
    final gesture = await tester.startGesture(tester.getCenter(firstHandle));
    await tester.pump();
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(Offset(0, rowHeight * 0.15));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(cubit.state.instructions, ['bloom', 'grind']);
    expect(find.text('1. bloom'), findsOneWidget);
    expect(find.text('2. grind'), findsOneWidget);
  });

  testWidgets('typing a step and tapping add appends it', (tester) async {
    await pump(tester);
    expect(find.text('No extra steps yet.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('instruction-input')),
      '  use 150ml of whole milk ',
    );
    await tester.tap(find.byKey(const Key('instruction-add')));
    await tester.pump();

    expect(cubit.state.instructions, ['use 150ml of whole milk']);
    expect(find.text('1. use 150ml of whole milk'), findsOneWidget);
  });

  testWidgets('removing the only step shows the empty state', (tester) async {
    cubit.addInstruction('stir');
    await pump(tester);

    await tester.tap(find.byTooltip('Remove step'));
    await tester.pump();

    expect(cubit.state.instructions, isEmpty);
    expect(find.text('No extra steps yet.'), findsOneWidget);
  });
}
