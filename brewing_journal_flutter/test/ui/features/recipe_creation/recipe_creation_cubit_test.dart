import 'dart:async';
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
      ..setWater(250)
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
        () => cubit.setWater(250),
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

    test('out-of-range temperature, dose, and water are rejected', () async {
      await fillRequired(cubit);
      cubit.next();
      cubit.setWaterTemp(101);
      expect(cubit.next(), isFalse);
      cubit
        ..setWaterTemp(93)
        ..setDose(0);
      expect(cubit.next(), isFalse);
      cubit
        ..setDose(0.1)
        ..setWater(0);
      expect(cubit.next(), isFalse);
      cubit.setWater(5000);
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
      expect(recipes.savedDrafts.single.waterMl, 250);
      expect(recipes.savedDrafts.single.id, isNull);
    });

    test('a second Finish does not store another recipe', () async {
      await fillRequired(cubit);
      cubit.addInstruction('stir');
      expect(await cubit.save(), isTrue);
      final id = cubit.state.recipeId!;
      cubit.removeInstruction(0);
      expect(await cubit.save(), isTrue);

      expect(recipes.savedDrafts, hasLength(1));
      expect(cubit.state.recipeId, id);
      expect(recipes.details[id]!.instructions.map((i) => i.text), ['stir']);
    });

    test(
      'saving an opened recipe stores a new version and keeps the source',
      () async {
        await fillRequired(cubit);
        cubit.addInstruction('stir');
        await cubit.save();
        final id = cubit.state.recipeId!;

        final editor = build();
        addTearDown(editor.close);
        await editor.load(id);
        editor.removeInstruction(0);
        await editor.save();

        expect(recipes.savedDrafts.last.id, id);
        expect(recipes.savedDrafts.last.instructions, isEmpty);
        final savedId = editor.state.recipeId!;
        expect(savedId, isNot(id));
        expect(recipes.details[id]!.instructions.map((i) => i.text), ['stir']);
        expect(recipes.details[savedId]!.instructions, isEmpty);
      },
    );

    test('refreshAccess stores canEdit from getAccess', () async {
      await fillRequired(cubit);
      expect(await cubit.save(), isTrue);
      final id = cubit.state.recipeId!;
      final detail = recipes.details[id]!;
      recipes.details[id] = RecipeDetail(
        recipe: detail.recipe,
        ingredient: detail.ingredient,
        instructions: detail.instructions,
        flavorTags: detail.flavorTags,
        photos: detail.photos,
        access: RecipeAccess(
          role: TeamRole.viewer,
          canEdit: false,
          canDelete: false,
        ),
      );

      await cubit.refreshAccess();

      expect(cubit.state.canEdit, isFalse);
    });

    test('save sends teamId on insert and not on a new version', () async {
      final teamId = const Uuid().v7obj();
      cubit.startNew(teamId: teamId);
      await fillRequired(cubit);
      expect(await cubit.save(), isTrue);
      expect(recipes.savedDrafts.single.teamId, teamId);

      final editor = build();
      addTearDown(editor.close);
      await editor.load(cubit.state.recipeId!);
      editor.addInstruction('stir');
      expect(await editor.save(), isTrue);
      expect(recipes.savedDrafts.last.id, cubit.state.recipeId);
      expect(recipes.savedDrafts.last.teamId, isNull);
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

    test('a new recipe keeps its photo until Finish stores one row', () async {
      await fillRequired(cubit);

      expect(await cubit.addPhoto(bytes, contentType: 'image/png'), isTrue);

      expect(recipes.savedDrafts, isEmpty);
      expect(media.uploadedTo, isEmpty);
      expect(cubit.state.recipeId, isNull);
      expect(cubit.state.photos, isEmpty);
      expect(cubit.state.stagedPhotos, hasLength(1));
      expect(cubit.state.stagedPhotos.single.contentType, 'image/png');

      expect(await cubit.save(), isTrue);

      expect(recipes.savedDrafts, hasLength(1));
      expect(recipes.savedDrafts.single.id, isNull);
      final id = cubit.state.recipeId!;
      expect(media.uploadedTo, [id]);
      expect(media.uploadedContentTypes, ['image/png']);
      expect(cubit.state.stagedPhotos, isEmpty);
      expect(cubit.state.photos.single.recipeId, id);

      expect(await cubit.save(), isTrue);
      expect(recipes.savedDrafts, hasLength(1));
      expect(media.uploadedTo, [id]);
    });

    test('addPhoto does not save or upload', () async {
      expect(await cubit.addPhoto(bytes), isTrue);
      expect(recipes.savedDrafts, isEmpty);
      expect(media.uploadedTo, isEmpty);
      expect(cubit.state.stagedPhotos, hasLength(1));
    });

    test('a rejected upload retries onto the same recipe', () async {
      await fillRequired(cubit);
      await cubit.addPhoto(bytes);
      media.nextError = BrewingException(
        code: BrewingErrorCode.uploadRejected,
        message: 'rejected',
      );

      expect(await cubit.save(), isFalse);

      final id = cubit.state.recipeId!;
      expect(recipes.savedDrafts, hasLength(1));
      expect(cubit.state.saveStatus, SaveStatus.failure);
      expect(cubit.state.photos, isEmpty);
      expect(cubit.state.stagedPhotos, hasLength(1));
      expect(
        cubit.state.error,
        isA<BrewingException>().having(
          (e) => e.code,
          'code',
          BrewingErrorCode.uploadRejected,
        ),
      );

      expect(await cubit.save(), isTrue);

      expect(recipes.savedDrafts, hasLength(1));
      expect(cubit.state.recipeId, id);
      expect(media.uploadedTo, [id, id]);
      expect(cubit.state.stagedPhotos, isEmpty);
      expect(cubit.state.photos.single.recipeId, id);
    });

    test('uploadRejected leaves stored photos unchanged', () async {
      await fillRequired(cubit);
      await cubit.addPhoto(bytes);
      expect(await cubit.save(), isTrue);
      final before = cubit.state.photos;
      media.nextError = BrewingException(
        code: BrewingErrorCode.uploadRejected,
        message: 'rejected',
      );

      expect(await cubit.addPhoto(bytes), isFalse);

      expect(cubit.state.photos, before);
      expect(cubit.state.pendingUpload, isFalse);
      expect(recipes.savedDrafts, hasLength(1));
      expect(
        cubit.state.error,
        isA<BrewingException>().having(
          (e) => e.code,
          'code',
          BrewingErrorCode.uploadRejected,
        ),
      );
    });

    test(
      'a photo added while editing is stored on the new version only',
      () async {
        await fillRequired(cubit);
        await cubit.save();
        final sourceId = cubit.state.recipeId!;
        final source = recipes.details[sourceId]!;
        final existing = RecipePhoto(
          id: const Uuid().v7obj(),
          recipeId: sourceId,
          storagePath: 'recipes/${sourceId.uuid}/old.jpg',
          sortOrder: 0,
          publicUrl: Uri.parse('https://example.com/old.jpg'),
        );
        recipes.details[sourceId] = RecipeDetail(
          recipe: source.recipe,
          ingredient: source.ingredient,
          instructions: source.instructions,
          flavorTags: source.flavorTags,
          photos: [existing],
          access: source.access,
        );

        final editor = build();
        addTearDown(editor.close);
        await editor.load(sourceId);

        expect(await editor.addPhoto(bytes, contentType: 'image/webp'), isTrue);

        expect(media.uploadedTo, isEmpty);
        expect(recipes.details[sourceId]!.photos, [existing]);
        expect(editor.state.stagedPhotos, hasLength(1));
        expect(editor.state.photos, [existing]);

        expect(await editor.save(), isTrue);

        final savedId = editor.state.recipeId!;
        expect(savedId, isNot(sourceId));
        expect(media.uploadedTo, [savedId]);
        expect(media.uploadedContentTypes, ['image/webp']);
        expect(recipes.details[sourceId]!.photos, [existing]);
        expect(
          editor.state.photos.map((photo) => photo.recipeId).toSet(),
          {savedId},
        );
        expect(editor.state.stagedPhotos, isEmpty);
      },
    );

    test('removing a staged photo does not call the server', () async {
      await fillRequired(cubit);
      await cubit.save();
      final sourceId = cubit.state.recipeId!;
      final editor = build();
      addTearDown(editor.close);
      await editor.load(sourceId);
      await editor.addPhoto(bytes);
      await editor.removePhoto(editor.state.stagedPhotos.single.id);

      expect(editor.state.stagedPhotos, isEmpty);
      expect(media.uploadedTo, isEmpty);
      expect(await editor.save(), isTrue);
      expect(media.uploadedTo, isEmpty);
    });

    test('removePhoto drops a stored photo', () async {
      await fillRequired(cubit);
      await cubit.addPhoto(bytes);
      expect(await cubit.save(), isTrue);
      await cubit.removePhoto(cubit.state.photos.single.id!);
      expect(cubit.state.photos, isEmpty);
      expect(cubit.state.stagedPhotos, isEmpty);
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

    test('selecting a team ingredient copies it onto this account', () async {
      final foreign = Ingredient(
        id: const Uuid().v7obj(),
        ownerId: const Uuid().v7obj(),
        kind: BeverageKind.coffee,
        name: 'Ethiopia Guji',
        nameKey: 'ethiopia guji',
        origin: 'Yirgacheffe',
      );
      ingredients.ingredients.add(foreign);
      await cubit.searchIngredients(BeverageKind.coffee, '');

      await cubit.selectIngredient(foreign);

      final selected = cubit.state.selectedIngredient!;
      expect(selected.id, isNot(foreign.id));
      expect(selected.ownerId, ingredients.selfId);
      expect(selected.origin, 'Yirgacheffe');
      expect(selected.name, 'Ethiopia Guji');
      expect(cubit.state.ingredientResults.single.id, selected.id);
    });

    test(
      'selecting a team ingredient keeps the row this account already named',
      () async {
        final own = await ingredients.register(
          IngredientDraft(
            kind: BeverageKind.coffee,
            name: 'Ethiopia Guji',
            origin: 'Mine',
          ),
        );
        final foreign = Ingredient(
          id: const Uuid().v7obj(),
          ownerId: const Uuid().v7obj(),
          kind: BeverageKind.coffee,
          name: 'ethiopia guji',
          nameKey: 'ethiopia guji',
          origin: 'Theirs',
        );
        ingredients.ingredients.add(foreign);

        await cubit.selectIngredient(foreign);

        expect(cubit.state.selectedIngredient!.id, own.id);
        expect(cubit.state.selectedIngredient!.origin, 'Mine');
      },
    );

    test('next waits until the tapped team ingredient is copied', () async {
      final foreign = Ingredient(
        id: const Uuid().v7obj(),
        ownerId: const Uuid().v7obj(),
        kind: BeverageKind.coffee,
        name: 'Ethiopia Guji',
        nameKey: 'ethiopia guji',
      );
      final other = Ingredient(
        id: const Uuid().v7obj(),
        ownerId: const Uuid().v7obj(),
        kind: BeverageKind.coffee,
        name: 'Kenya AA',
        nameKey: 'kenya aa',
      );
      ingredients.ingredients.addAll([foreign, other]);
      final gate = Completer<void>();
      ingredients.pendingAdopt = gate.future;

      final pending = cubit.selectIngredient(foreign);
      await cubit.selectIngredient(other);
      expect(cubit.state.adoptingIngredientId, foreign.id);
      expect(cubit.next(), isFalse);
      expect(cubit.state.step, RecipeWizardStep.ingredient);
      expect(cubit.state.selectedIngredient, isNull);

      gate.complete();
      await pending;

      expect(cubit.state.step, RecipeWizardStep.extraction);
      expect(cubit.state.selectedIngredient!.name, 'Ethiopia Guji');
      expect(cubit.state.selectedIngredient!.ownerId, ingredients.selfId);
      expect(cubit.state.adoptingIngredientId, isNull);
      expect(
        ingredients.ingredients.where(
          (row) => row.ownerId == ingredients.selfId,
        ),
        hasLength(1),
      );
    });

    test('grinder search returns models that start with the query', () async {
      recipes.grinderCatalog.addAll(['Comandante C40', 'Niche Zero']);

      await cubit.searchGrinderModels('com');

      expect(cubit.state.grinderSuggestions, ['Comandante C40']);
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
