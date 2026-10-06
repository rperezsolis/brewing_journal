import 'dart:async';
import 'dart:typed_data';

import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:clock/clock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/ingredient_repository.dart';
import '../../../../data/repositories/recipe_media_repository.dart';
import '../../../../data/repositories/recipe_repository.dart';
import '../../../core/validation_messages.dart';
import '../recipe_limits.dart';
import 'recipe_creation_state.dart';

/// Holds the 5-step wizard. Step widgets only edit this state; the
/// repositories are called from the intent methods.
class RecipeCreationCubit extends Cubit<RecipeCreationState> {
  RecipeCreationCubit({
    required this._recipes,
    required this._ingredients,
    required this._media,
  }) : super(const RecipeCreationState());

  final RecipeRepository _recipes;
  final IngredientRepository _ingredients;
  final RecipeMediaRepository _media;

  Stopwatch? _stopwatch;
  Timer? _ticker;
  int _searchSeq = 0;
  int _grinderSeq = 0;

  /// A forward step the user asked for while an ingredient copy was in flight.
  RecipeWizardStep? _stepAfterAdopt;

  void startNew({UuidValue? teamId}) {
    _cancelStopwatch();
    emit(RecipeCreationState(teamId: teamId));
  }

  Future<void> load(UuidValue id) async {
    _cancelStopwatch();
    emit(RecipeCreationState(loadStatus: LoadStatus.loading, recipeId: id));
    final RecipeDetail detail;
    try {
      detail = await _recipes.get(id);
    } catch (error) {
      if (isClosed) return;
      emit(state.copyWith(loadStatus: LoadStatus.failure, error: error));
      return;
    }
    if (isClosed) return;

    final recipe = detail.recipe;
    final instructions = [...detail.instructions]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final photos = [...detail.photos]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    emit(
      RecipeCreationState(
        recipeId: recipe.id,
        teamId: recipe.teamId,
        canEdit: detail.access.canEdit,
        ingredientKind: detail.ingredient.kind,
        selectedIngredient: detail.ingredient,
        title: recipe.title,
        waterTempC: recipe.waterTempC,
        doseGrams: recipe.doseGrams,
        waterMl: recipe.waterMl,
        grindSize: recipe.grindSize,
        grinderModel: recipe.grinderModel,
        extractionMethod: recipe.extractionMethod,
        extractionMethodNote: recipe.extractionMethodNote ?? '',
        extractionDuration: recipe.extractionDuration,
        stopwatchElapsed: recipe.extractionDuration ?? Duration.zero,
        acidity: recipe.acidity,
        sweetness: recipe.sweetness,
        body: recipe.body,
        bitterness: recipe.bitterness,
        flavorTags: [for (final tag in detail.flavorTags) tag.tag],
        instructions: [for (final i in instructions) i.text],
        photos: photos,
      ),
    );
  }

  // Step 1: ingredient

  Future<void> searchIngredients(BeverageKind kind, String query) async {
    final seq = ++_searchSeq;
    emit(
      state.copyWith(
        ingredientKind: kind,
        ingredientQuery: query,
        searchingIngredients: true,
      ),
    );
    try {
      final results = await _ingredients.search(kind, query, limit: 30);
      if (isClosed || seq != _searchSeq) return;
      emit(
        state.copyWith(ingredientResults: results, searchingIngredients: false),
      );
    } catch (error) {
      if (isClosed || seq != _searchSeq) return;
      emit(state.copyWith(searchingIngredients: false, error: error));
    }
  }

  /// Copies a teammate's ingredient onto this account, then selects that copy.
  ///
  /// A second tap while a copy is in flight is ignored. Forward navigation
  /// waits until the copy exists, so a new recipe is never saved with the
  /// teammate's id.
  Future<void> selectIngredient(Ingredient ingredient) async {
    final id = ingredient.id;
    if (id == null || state.adoptingIngredientId != null) return;
    emit(state.copyWith(adoptingIngredientId: () => id));
    try {
      final adopted = await _ingredients.adopt(id);
      if (isClosed) return;
      final results = _withAdopted(state.ingredientResults, id, adopted);
      final nextStep = _stepAfterAdopt;
      _stepAfterAdopt = null;
      emit(
        state.copyWith(
          adoptingIngredientId: () => null,
          selectedIngredient: () => adopted,
          ingredientResults: results,
        ),
      );
      if (nextStep != null) goTo(nextStep);
    } catch (error) {
      if (isClosed) return;
      _stepAfterAdopt = null;
      emit(
        state.copyWith(adoptingIngredientId: () => null, error: error),
      );
    }
  }

  /// Registers (or finds) the ingredient and selects it.
  Future<bool> registerIngredient(IngredientDraft draft) async {
    final name = draft.name.trim();
    if (name.isEmpty || name.length > kIngredientNameMaxLength) {
      emit(
        state.copyWith(
          error: _validation(
            validationMessage('nameLength', [kIngredientNameMaxLength]),
          ),
        ),
      );
      return false;
    }
    emit(
      state.copyWith(
        ingredientDraft: () => draft,
        registeringIngredient: true,
      ),
    );
    try {
      final ingredient = await _ingredients.register(draft);
      if (isClosed) return false;
      emit(
        state.copyWith(
          ingredientKind: ingredient.kind,
          selectedIngredient: () => ingredient,
          ingredientDraft: () => null,
          registeringIngredient: false,
          ingredientResults: [
            ingredient,
            ...state.ingredientResults.where((i) => i.id != ingredient.id),
          ],
        ),
      );
      return true;
    } catch (error) {
      if (isClosed) return false;
      emit(state.copyWith(registeringIngredient: false, error: error));
      return false;
    }
  }

  // Step 2: extraction

  void setTitle(String value) => emit(state.copyWith(title: value));

  void setWaterTemp(double? value) =>
      emit(state.copyWith(waterTempC: () => value));

  void setDose(double? value) => emit(state.copyWith(doseGrams: () => value));

  void setWater(double? value) => emit(state.copyWith(waterMl: () => value));

  void setGrindSize(String value) => emit(state.copyWith(grindSize: value));

  void setGrinderModel(String value) =>
      emit(state.copyWith(grinderModel: value));

  /// Models whose folded name starts with [query], from this account and
  /// from recipes on this account's teams.
  Future<void> searchGrinderModels(String query) async {
    final seq = ++_grinderSeq;
    try {
      final models = await _recipes.listGrinderModels(query, limit: 30);
      if (isClosed || seq != _grinderSeq) return;
      emit(state.copyWith(grinderSuggestions: models));
    } catch (error) {
      if (isClosed || seq != _grinderSeq) return;
      emit(state.copyWith(error: error));
    }
  }

  void setExtractionMethod(ExtractionMethod? value) =>
      emit(state.copyWith(extractionMethod: () => value));

  void setExtractionMethodNote(String value) =>
      emit(state.copyWith(extractionMethodNote: value));

  /// Manual entry, or clearing, for a brew timed elsewhere.
  void setExtractionDuration(Duration? value) {
    if (state.stopwatchRunning) return;
    _stopwatch?.reset();
    emit(
      state.copyWith(
        extractionDuration: () => value,
        stopwatchElapsed: value ?? Duration.zero,
      ),
    );
  }

  void startStopwatch() {
    if (state.stopwatchRunning) return;
    final stopwatch = _stopwatch ??= clock.stopwatch();
    stopwatch.start();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      emit(state.copyWith(stopwatchElapsed: _elapsed));
    });
    emit(state.copyWith(stopwatchRunning: true));
  }

  void stopStopwatch() {
    if (!state.stopwatchRunning) return;
    _stopwatch!.stop();
    _ticker?.cancel();
    final elapsed = _elapsed;
    emit(
      state.copyWith(
        stopwatchRunning: false,
        stopwatchElapsed: elapsed,
        extractionDuration: () => elapsed,
      ),
    );
  }

  void resetStopwatch() {
    _cancelStopwatch();
    emit(
      state.copyWith(
        stopwatchRunning: false,
        stopwatchElapsed: Duration.zero,
        extractionDuration: () => null,
      ),
    );
  }

  /// The stopwatch reading, rounded to the tenth of a second the readout shows.
  Duration get _elapsed {
    final ms = _stopwatch!.elapsedMilliseconds;
    return Duration(milliseconds: (ms / 100).round() * 100);
  }

  // Step 3: flavor

  void setFlavor({
    int? acidity,
    int? sweetness,
    int? body,
    int? bitterness,
    List<String>? tags,
  }) {
    List<String>? cleanTags;
    if (tags != null) {
      cleanTags = [];
      final keys = <String>{};
      for (final tag in tags) {
        final trimmed = tag.trim();
        if (trimmed.isEmpty) continue;
        if (trimmed.length > kTagMaxLength) {
          emit(
            state.copyWith(
              error: _validation(
                validationMessage('tagTooLong', [kTagMaxLength]),
              ),
            ),
          );
          return;
        }
        if (keys.add(trimmed.toLowerCase())) cleanTags.add(trimmed);
      }
      if (cleanTags.length > kMaxTags) {
        emit(
          state.copyWith(
            error: _validation(validationMessage('tooManyTags', [kMaxTags])),
          ),
        );
        return;
      }
    }
    emit(
      state.copyWith(
        acidity: acidity?.clamp(0, kMaxScore),
        sweetness: sweetness?.clamp(0, kMaxScore),
        body: body?.clamp(0, kMaxScore),
        bitterness: bitterness?.clamp(0, kMaxScore),
        flavorTags: cleanTags,
      ),
    );
  }

  // Step 4: instructions

  /// Returns false, and sets [RecipeCreationState.error], when [text] is
  /// blank, too long, or the list is full; the list is then unchanged.
  bool addInstruction(String text) {
    if (state.instructions.length >= kMaxInstructions) {
      emit(
        state.copyWith(
          error: _validation(
            validationMessage('tooManyInstructions', [kMaxInstructions]),
          ),
        ),
      );
      return false;
    }
    final trimmed = _validInstruction(text);
    if (trimmed == null) return false;
    emit(state.copyWith(instructions: [...state.instructions, trimmed]));
    return true;
  }

  bool updateInstruction(int index, String text) {
    if (index < 0 || index >= state.instructions.length) return false;
    final trimmed = _validInstruction(text);
    if (trimmed == null) return false;
    emit(
      state.copyWith(
        instructions: [...state.instructions]..[index] = trimmed,
      ),
    );
    return true;
  }

  void removeInstruction(int index) {
    if (index < 0 || index >= state.instructions.length) return;
    emit(
      state.copyWith(instructions: [...state.instructions]..removeAt(index)),
    );
  }

  /// Moves the item at [from] so it ends up at index [to].
  void moveInstruction(int from, int to) {
    final length = state.instructions.length;
    if (from < 0 || from >= length || to < 0 || to >= length || from == to) {
      return;
    }
    final list = [...state.instructions];
    list.insert(to, list.removeAt(from));
    emit(state.copyWith(instructions: list));
  }

  void skipInstructions() {
    emit(
      state.copyWith(instructions: const [], step: RecipeWizardStep.media),
    );
  }

  String? _validInstruction(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      emit(
        state.copyWith(
          error: _validation(validationMessage('emptyInstruction')),
        ),
      );
      return null;
    }
    if (trimmed.length > kInstructionMaxLength) {
      emit(
        state.copyWith(
          error: _validation(
            validationMessage('instructionTooLong', [kInstructionMaxLength]),
          ),
        ),
      );
      return null;
    }
    return trimmed;
  }

  // Navigation

  /// Advances one step if the current step is complete. Leaving the
  /// extraction step stops a running stopwatch first.
  bool next() {
    if (state.isLastStep) return false;
    return goTo(RecipeWizardStep.values[state.step.index + 1]);
  }

  void back() {
    if (state.step.index == 0) return;
    goTo(RecipeWizardStep.values[state.step.index - 1]);
  }

  /// Goes back freely; goes forward only when every step before [target] is
  /// complete.
  bool goTo(RecipeWizardStep target) {
    if (target == state.step) return true;
    if (state.adoptingIngredientId != null && target.index > state.step.index) {
      _stepAfterAdopt = target;
      return false;
    }
    _stepAfterAdopt = null;
    if (state.step == RecipeWizardStep.extraction &&
        target.index > state.step.index) {
      stopStopwatch();
    }
    for (final step in RecipeWizardStep.values.take(target.index)) {
      final problem = problemAt(step);
      if (problem != null) {
        emit(state.copyWith(step: step, error: _validation(problem)));
        return false;
      }
    }
    emit(state.copyWith(step: target));
    return true;
  }

  /// Why [step] is not complete yet, or null when it is.
  String? problemAt(RecipeWizardStep step) {
    final s = state;
    switch (step) {
      case RecipeWizardStep.ingredient:
        return s.selectedIngredient == null
            ? validationMessage('selectIngredient')
            : null;
      case RecipeWizardStep.extraction:
        final temp = s.waterTempC;
        final dose = s.doseGrams;
        final water = s.waterMl;
        final duration = s.extractionDuration;
        if (s.title.trim().isEmpty) return validationMessage('addTitle');
        if (temp == null || temp < kMinWaterTempC || temp > kMaxWaterTempC) {
          return validationMessage('waterTemp', [
            kMinWaterTempC.round(),
            kMaxWaterTempC.round(),
          ]);
        }
        if (dose == null || dose < kMinDoseGrams || dose > kMaxDoseGrams) {
          return validationMessage('dose', [
            formatLimit(kMinDoseGrams),
            formatLimit(kMaxDoseGrams),
          ]);
        }
        if (water == null || water < kMinWaterMl || water > kMaxWaterMl) {
          return validationMessage('waterMl', [
            formatLimit(kMinWaterMl),
            formatLimit(kMaxWaterMl),
          ]);
        }
        if (s.grindSize.trim().isEmpty) {
          return validationMessage('addGrindSize');
        }
        if (s.grinderModel.trim().isEmpty) {
          return validationMessage('addGrinder');
        }
        if (s.extractionMethod == null) {
          return validationMessage('chooseMethod');
        }
        if (s.extractionMethod == ExtractionMethod.other &&
            s.extractionMethodNote.trim().isEmpty) {
          return validationMessage('describeMethod');
        }
        if (duration != null &&
            (duration < const Duration(seconds: 1) ||
                duration > kMaxExtractionDuration)) {
          return validationMessage('extractionTime');
        }
        return null;
      case RecipeWizardStep.flavor:
      case RecipeWizardStep.instructions:
      case RecipeWizardStep.media:
        return null;
    }
  }

  // Saving and photos

  /// Saves the whole wizard. On failure every field is kept.
  Future<bool> save() async {
    if (state.isSaving || state.adoptingIngredientId != null) return false;
    for (final step in RecipeWizardStep.values) {
      final problem = problemAt(step);
      if (problem != null) {
        emit(
          state.copyWith(
            saveStatus: SaveStatus.failure,
            error: _validation(problem),
          ),
        );
        return false;
      }
    }
    if (state.stopwatchRunning) stopStopwatch();

    final s = state;
    final note = s.extractionMethodNote.trim();
    final draft = RecipeDraft(
      // An existing id is the source of a new version. The server inserts a
      // new recipe and leaves that one unchanged.
      id: s.recipeId,
      teamId: s.recipeId == null ? s.teamId : null,
      ingredientId: s.selectedIngredient!.id!,
      title: s.title.trim(),
      waterTempC: s.waterTempC!,
      doseGrams: s.doseGrams!,
      waterMl: s.waterMl!,
      grindSize: s.grindSize.trim(),
      grinderModel: s.grinderModel.trim(),
      extractionMethod: s.extractionMethod!,
      extractionMethodNote: note.isEmpty ? null : note,
      extractionDuration: s.extractionDuration,
      acidity: s.acidity,
      sweetness: s.sweetness,
      body: s.body,
      bitterness: s.bitterness,
      flavorTags: s.flavorTags,
      instructions: s.instructions,
    );

    emit(state.copyWith(saveStatus: SaveStatus.saving));
    try {
      final detail = await _recipes.save(draft);
      if (isClosed) return true;
      emit(
        state.copyWith(
          saveStatus: SaveStatus.success,
          recipeId: () => detail.recipe.id,
          photos: [...detail.photos]
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
          canEdit: detail.access.canEdit,
        ),
      );
      return true;
    } catch (error) {
      if (isClosed) return false;
      emit(state.copyWith(saveStatus: SaveStatus.failure, error: error));
      return false;
    }
  }

  /// Re-reads access after a `forbidden` save so a demoted editor leaves the
  /// wizard. The view redirects to Brew Mode when [canEdit] becomes false.
  Future<void> refreshAccess() async {
    final id = state.recipeId;
    if (id == null) return;
    try {
      final access = await _recipes.getAccess(id);
      if (isClosed) return;
      emit(state.copyWith(canEdit: access.canEdit));
    } catch (_) {
      // The save error is already on screen. A failed access check leaves
      // the wizard as it is.
    }
  }

  /// Uploads a JPEG. A new recipe is saved first, since a photo needs a
  /// recipe id. The photo is appended only once the server confirms it.
  Future<bool> addPhoto(ByteData bytes) async {
    if (state.pendingUpload) return false;
    if (state.photos.length >= kMaxPhotos) {
      emit(
        state.copyWith(
          error: _validation(validationMessage('tooManyPhotos', [kMaxPhotos])),
        ),
      );
      return false;
    }
    if (state.recipeId == null && !await save()) return false;
    if (isClosed) return false;

    emit(state.copyWith(pendingUpload: true));
    try {
      final photo = await _media.uploadPhoto(state.recipeId!, bytes);
      if (isClosed) return true;
      emit(
        state.copyWith(pendingUpload: false, photos: [...state.photos, photo]),
      );
      return true;
    } catch (error) {
      if (isClosed) return false;
      emit(state.copyWith(pendingUpload: false, error: error));
      return false;
    }
  }

  Future<void> removePhoto(UuidValue photoId) async {
    try {
      await _media.remove(photoId);
      if (isClosed) return;
      emit(
        state.copyWith(
          photos: state.photos.where((p) => p.id != photoId).toList(),
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(state.copyWith(error: error));
    }
  }

  /// Reports a failure that happened in the view (e.g. picking a photo).
  void reportError(Object error) => emit(state.copyWith(error: error));

  BrewingException _validation(String message) =>
      BrewingException(code: BrewingErrorCode.validation, message: message);

  void _cancelStopwatch() {
    _ticker?.cancel();
    _ticker = null;
    _stopwatch?.stop();
    _stopwatch?.reset();
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}

/// Replaces [tappedId] with [adopted], and drops any other row of the same
/// kind and name. Leaves the list unchanged when the tap is no longer in it.
List<Ingredient> _withAdopted(
  List<Ingredient> results,
  UuidValue tappedId,
  Ingredient adopted,
) {
  if (!results.any((row) => row.id == tappedId)) return results;
  final next = <Ingredient>[];
  var placed = false;
  for (final row in results) {
    final sameName = row.kind == adopted.kind && row.nameKey == adopted.nameKey;
    if (row.id != tappedId && row.id != adopted.id && !sameName) {
      next.add(row);
      continue;
    }
    if (!placed) {
      next.add(adopted);
      placed = true;
    }
  }
  return next;
}
