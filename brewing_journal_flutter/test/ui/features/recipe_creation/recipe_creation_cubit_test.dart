import 'dart:typed_data';

import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:brewing_journal_flutter/data/repositories/fake_ingredient_repository.dart';
import 'package:brewing_journal_flutter/data/repositories/fake_recipe_media_repository.dart';
import 'package:brewing_journal_flutter/data/repositories/fake_recipe_repository.dart';
import 'package:brewing_journal_flutter/ui/features/recipe_creation/cubit/recipe_creation_cubit.dart';
import 'package:brewing_journal_flutter/ui/features/recipe_creation/cubit/recipe_creation_state.dart';
import 'package:brewing_journal_flutter/ui/features/recipe_creation/recipe_limits.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeIngredientRepository ingredients;
  late FakeRecipeRepository recipes;
  late FakeRecipeMediaRepository media;
  late RecipeCreationCubit cubit;

  RecipeCreationCubit build() => RecipeCreationCubit(
    recipes: recipes,
    ingredients: ingredients,
    media: media,
  );

  setUp(() {
    ingredients = FakeIngredientRepository();
    recipes = FakeRecipeRepository(ingredients);
    media = FakeRecipeMediaRepository();
    cubit = build();
  });

  tearDown(() => cubit.close());

  Matcher isValidationError() => isA<BrewingException>().having(
    (e) => e.code,
    'code',
    BrewingErrorCode.validation,
  );

  /// Fills the ingredient and extraction steps with valid values.
  Future<void> fillRequired(RecipeCreationCubit cubit) async {
    await cubit.registerIngredient(
      IngredientDraft(kind: BeverageKind.coffee, name: 'Ethiopia Guji'),
    );
    cubit
      ..setTitle('Morning V60')
      ..setWaterTemp(93)
      ..setDose(15)
      ..setGrindSize('Medium-fine')
      ..setGrinderModel('Comandante')
      ..setExtractionMethod(ExtractionMethod.v60);
  }

  group('instructions', () {
    test('add, edit, move, and remove keep the list in order', () {
      cubit
        ..addInstruction('  grind ')
        ..addInstruction('bloom')
        ..addInstruction('stir');
      expect(cubit.state.instructions, ['grind', 'bloom', 'stir']);

      cubit.updateInstruction(1, ' bloom 30s ');
      expect(cubit.state.instructions, ['grind', 'bloom 30s', 'stir']);

      cubit.moveInstruction(2, 0);
      expect(cubit.state.instructions, ['stir', 'grind', 'bloom 30s']);

      cubit.moveInstruction(0, 2);
      expect(cubit.state.instructions, ['grind', 'bloom 30s', 'stir']);

      cubit.removeInstruction(1);
      expect(cubit.state.instructions, ['grind', 'stir']);
    });

    test('duplicates are kept', () {
      cubit
        ..addInstruction('stir')
        ..addInstruction('stir');
      expect(cubit.state.instructions, ['stir', 'stir']);
    });

    test('removing the last item leaves an empty list', () {
      cubit
        ..addInstruction('stir')
        ..removeInstruction(0);
      expect(cubit.state.instructions, isEmpty);
    });

    test('blank input sets error and leaves the list unchanged', () {
      cubit.addInstruction('stir');
      for (final blank in ['', '   ']) {
        expect(cubit.addInstruction(blank), isFalse);
        expect(cubit.state.error, isValidationError());
        expect(cubit.state.instructions, ['stir']);
      }
      expect(cubit.updateInstruction(0, '  '), isFalse);
      expect(cubit.state.instructions, ['stir']);
    });

    test('281-character input sets error and leaves the list unchanged', () {
      final tooLong = 'a' * (kInstructionMaxLength + 1);
      expect(cubit.addInstruction(tooLong), isFalse);
      expect(cubit.state.error, isValidationError());
      expect(cubit.state.instructions, isEmpty);

      expect(cubit.addInstruction('a' * kInstructionMaxLength), isTrue);
    });

    test('the list is capped at 30 items', () {
      for (var i = 0; i < kMaxInstructions; i++) {
        cubit.addInstruction('step $i');
      }
      expect(cubit.addInstruction('one more'), isFalse);
      expect(cubit.state.instructions, hasLength(kMaxInstructions));
    });

    test('skipInstructions clears the list and goes to the media step', () {
      cubit.addInstruction('stir');
      cubit.skipInstructions();
      expect(cubit.state.instructions, isEmpty);
      expect(cubit.state.step, RecipeWizardStep.media);
    });
  });

  group('next() guards', () {
    test('ingredient step requires a selected ingredient', () async {
      expect(cubit.next(), isFalse);
      expect(cubit.state.step, RecipeWizardStep.ingredient);
      expect(cubit.state.error, isValidationError());

      await cubit.registerIngredient(
        IngredientDraft(kind: BeverageKind.tea, name: 'Sencha'),
      );
      expect(cubit.next(), isTrue);
      expect(cubit.state.step, RecipeWizardStep.extraction);
    });

    test('extraction step requires every parameter', () async {
      await cubit.registerIngredient(
        IngredientDraft(kind: BeverageKind.coffee, name: 'Kenya AA'),
      );
      cubit.next();

      final fills = <void Function()>[
        () => cubit.setTitle('Title'),
        () => cubit.setWaterTemp(93),
        () => cubit.setDose(15),
        () => cubit.setGrindSize('fine'),
        () => cubit.setGrinderModel('Niche'),
        () => cubit.setExtractionMethod(ExtractionMethod.other),
      ];
      for (final fill in fills) {
        expect(cubit.next(), isFalse);
        expect(cubit.state.step, RecipeWizardStep.extraction);
        fill();
      }
      // `other` also needs a note.
      expect(cubit.next(), isFalse);
      cubit.setExtractionMethodNote('Clever dripper');
      expect(cubit.next(), isTrue);
      expect(cubit.state.step, RecipeWizardStep.flavor);
    });

    test('out-of-range temperature and dose are rejected', () async {
      await fillRequired(cubit);
      cubit.next();
      cubit.setWaterTemp(101);
      expect(cubit.next(), isFalse);
      cubit
        ..setWaterTemp(93)
        ..setDose(0);
      expect(cubit.next(), isFalse);
      cubit.setDose(0.1);
      expect(cubit.next(), isTrue);
    });

    test('flavor and instructions steps always advance', () async {
      await fillRequired(cubit);
      cubit
        ..next()
        ..next();
      expect(cubit.next(), isTrue);
      expect(cubit.state.step, RecipeWizardStep.instructions);
      expect(cubit.next(), isTrue);
      expect(cubit.state.step, RecipeWizardStep.media);
      expect(cubit.next(), isFalse);
    });

    test('goTo a later step stops at the first incomplete one', () {
      expect(cubit.goTo(RecipeWizardStep.media), isFalse);
      expect(cubit.state.step, RecipeWizardStep.ingredient);
    });

    test('back() goes to the previous step', () async {
      await fillRequired(cubit);
      cubit.next();
      cubit.back();
      expect(cubit.state.step, RecipeWizardStep.ingredient);
    });
  });

  group('stopwatch', () {
    test('stop writes extractionDuration and reset clears it', () {
      fakeAsync((async) {
        final cubit = build();
        cubit.startStopwatch();
        expect(cubit.state.stopwatchRunning, isTrue);

        async.elapse(const Duration(seconds: 3, milliseconds: 250));
        expect(
          cubit.state.stopwatchElapsed,
          const Duration(milliseconds: 3200),
        );

        cubit.stopStopwatch();
        expect(cubit.state.stopwatchRunning, isFalse);
        expect(
          cubit.state.extractionDuration,
          const Duration(milliseconds: 3300),
        );

        cubit.resetStopwatch();
        expect(cubit.state.extractionDuration, isNull);
        expect(cubit.state.stopwatchElapsed, Duration.zero);
        cubit.close();
      });
    });

    test('next() from extraction stops a running stopwatch', () {
      fakeAsync((async) {
        final cubit = build();
        fillRequired(cubit);
        async.flushMicrotasks();
        cubit.next();
        cubit.startStopwatch();
        async.elapse(const Duration(seconds: 2));

        expect(cubit.next(), isTrue);
        expect(cubit.state.stopwatchRunning, isFalse);
        expect(cubit.state.extractionDuration, const Duration(seconds: 2));
        cubit.close();
      });
    });

    test('close() cancels the ticker', () {
      fakeAsync((async) {
        final cubit = build();
        cubit.startStopwatch();
        cubit.close();
        async.elapse(const Duration(seconds: 1));
        expect(async.periodicTimerCount, 0);
      });
    });
  });

  group('load', () {
    test('restores the saved fields and instructions in order', () async {
      await fillRequired(cubit);
      cubit
        ..addInstruction('grind')
        ..addInstruction('stir')
        ..addInstruction('stir')
        ..setFlavor(acidity: 4, tags: ['fruity', 'floral']);
      await cubit.save();
      final id = cubit.state.recipeId!;

      final editor = build();
      addTearDown(editor.close);
      await editor.load(id);

      expect(editor.state.loadStatus, LoadStatus.ready);
      expect(editor.state.recipeId, id);
      expect(editor.state.instructions, ['grind', 'stir', 'stir']);
      expect(editor.state.title, 'Morning V60');
      expect(editor.state.acidity, 4);
      expect(editor.state.flavorTags, ['fruity', 'floral']);
      expect(editor.state.selectedIngredient?.name, 'Ethiopia Guji');
      expect(editor.state.step, RecipeWizardStep.ingredient);
    });

    test('an unknown id sets loadStatus failure with notFound', () async {
      await cubit.load(const Uuid().v7obj());
      expect(cubit.state.loadStatus, LoadStatus.failure);
      expect(
        cubit.state.error,
        isA<BrewingException>().having(
          (e) => e.code,
          'code',
          BrewingErrorCode.notFound,
        ),
      );
    });
  });

  group('save', () {
    test('sends trimmed instructions and stores the recipe id', () async {
      await fillRequired(cubit);
      cubit.addInstruction('  stir  ');

      expect(await cubit.save(), isTrue);
      expect(cubit.state.saveStatus, SaveStatus.success);
      expect(cubit.state.recipeId, isNotNull);
      expect(recipes.savedDrafts.single.instructions, ['stir']);
      expect(recipes.savedDrafts.single.id, isNull);
    });

    test('a second save updates the same recipe', () async {
      await fillRequired(cubit);
      await cubit.save();
      final id = cubit.state.recipeId;
      cubit.removeInstruction(0);
      await cubit.save();

      expect(recipes.savedDrafts.last.id, id);
      expect(recipes.savedDrafts.last.instructions, isEmpty);
    });

    test('a failed save keeps every field and sets failure', () async {
      await fillRequired(cubit);
      cubit
        ..addInstruction('stir')
        ..setFlavor(sweetness: 3, tags: ['nutty']);
      final before = cubit.state;
      recipes.nextError = const ServerpodClientNetworkException('down');

      expect(await cubit.save(), isFalse);

      final after = cubit.state;
      expect(after.saveStatus, SaveStatus.failure);
      expect(after.error, isA<ServerpodClientNetworkException>());
      expect(after.instructions, before.instructions);
      expect(after.title, before.title);
      expect(after.sweetness, 3);
      expect(after.flavorTags, ['nutty']);
      expect(after.selectedIngredient, before.selectedIngredient);
      expect(after.recipeId, isNull);
    });

    test('an incomplete wizard does not call the repository', () async {
      expect(await cubit.save(), isFalse);
      expect(cubit.state.saveStatus, SaveStatus.failure);
      expect(recipes.savedDrafts, isEmpty);
    });
  });

  group('photos', () {
    final bytes = ByteData.sublistView(Uint8List.fromList([0xFF, 0xD8, 0xFF]));

    test('addPhoto with no recipeId saves first', () async {
      await fillRequired(cubit);

      expect(await cubit.addPhoto(bytes), isTrue);

      expect(recipes.savedDrafts, hasLength(1));
      final id = cubit.state.recipeId!;
      expect(media.uploadedTo, [id]);
      expect(cubit.state.photos, hasLength(1));
      expect(cubit.state.pendingUpload, isFalse);
    });

    test('addPhoto does not upload when the first save fails', () async {
      expect(await cubit.addPhoto(bytes), isFalse);
      expect(media.uploadedTo, isEmpty);
    });

    test('uploadRejected leaves photos unchanged', () async {
      await fillRequired(cubit);
      await cubit.addPhoto(bytes);
      final before = cubit.state.photos;
      media.nextError = BrewingException(
        code: BrewingErrorCode.uploadRejected,
        message: 'rejected',
      );

      expect(await cubit.addPhoto(bytes), isFalse);

      expect(cubit.state.photos, before);
      expect(cubit.state.pendingUpload, isFalse);
      expect(
        cubit.state.error,
        isA<BrewingException>().having(
          (e) => e.code,
          'code',
          BrewingErrorCode.uploadRejected,
        ),
      );
    });

    test('removePhoto drops the row', () async {
      await fillRequired(cubit);
      await cubit.addPhoto(bytes);
      await cubit.removePhoto(cubit.state.photos.single.id!);
      expect(cubit.state.photos, isEmpty);
    });
  });

  group('flavor', () {
    test('tags are trimmed and de-duplicated case-insensitively', () {
      cubit.setFlavor(tags: [' Fruity ', 'fruity', 'Floral']);
      expect(cubit.state.flavorTags, ['Fruity', 'Floral']);
    });

    test('a 41-character tag is rejected and the list kept', () {
      cubit.setFlavor(tags: ['fruity']);
      cubit.setFlavor(tags: ['fruity', 'a' * (kTagMaxLength + 1)]);
      expect(cubit.state.flavorTags, ['fruity']);
      expect(cubit.state.error, isValidationError());
    });

    test('scores are clamped to 0..5', () {
      cubit.setFlavor(acidity: 9, body: -1);
      expect(cubit.state.acidity, kMaxScore);
      expect(cubit.state.body, 0);
    });
  });

  group('ingredients', () {
    test('search returns matches for the kind', () async {
      await ingredients.register(
        IngredientDraft(kind: BeverageKind.matcha, name: 'Uji Ceremonial'),
      );
      await cubit.searchIngredients(BeverageKind.matcha, 'uj');
      expect(cubit.state.ingredientResults.map((i) => i.name), [
        'Uji Ceremonial',
      ]);
      expect(cubit.state.searchingIngredients, isFalse);
    });

    test('a failed register keeps the draft for a retry', () async {
      ingredients.nextError = const ServerpodClientNetworkException('down');
      final draft = IngredientDraft(kind: BeverageKind.tea, name: 'Sencha');

      expect(await cubit.registerIngredient(draft), isFalse);
      expect(cubit.state.ingredientDraft, draft);
      expect(cubit.state.selectedIngredient, isNull);
    });
  });
}
