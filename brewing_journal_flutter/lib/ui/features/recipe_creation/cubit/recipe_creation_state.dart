import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

enum RecipeWizardStep { ingredient, extraction, flavor, instructions, media }

enum SaveStatus { idle, saving, success, failure }

/// Loading an existing recipe into the wizard (`load`).
enum LoadStatus { loading, ready, failure }

class RecipeCreationState extends Equatable {
  const RecipeCreationState({
    this.step = RecipeWizardStep.ingredient,
    this.loadStatus = LoadStatus.ready,
    this.saveStatus = SaveStatus.idle,
    this.error,
    this.recipeId,
    this.ingredientKind = BeverageKind.coffee,
    this.ingredientQuery = '',
    this.ingredientResults = const [],
    this.searchingIngredients = false,
    this.selectedIngredient,
    this.ingredientDraft,
    this.registeringIngredient = false,
    this.title = '',
    this.waterTempC,
    this.doseGrams,
    this.grindSize = '',
    this.grinderModel = '',
    this.extractionMethod,
    this.extractionMethodNote = '',
    this.extractionDuration,
    this.stopwatchRunning = false,
    this.stopwatchElapsed = Duration.zero,
    this.acidity = 0,
    this.sweetness = 0,
    this.body = 0,
    this.bitterness = 0,
    this.flavorTags = const [],
    this.instructions = const [],
    this.photos = const [],
    this.pendingUpload = false,
    this.canEdit = true,
  });

  final RecipeWizardStep step;
  final LoadStatus loadStatus;
  final SaveStatus saveStatus;

  /// The last failure, for a one-off message. Cleared by the next change.
  final Object? error;

  /// Null until the first successful save; set when editing.
  final UuidValue? recipeId;

  final BeverageKind ingredientKind;
  final String ingredientQuery;
  final List<Ingredient> ingredientResults;
  final bool searchingIngredients;
  final Ingredient? selectedIngredient;

  /// The draft being registered; kept after a failure so it can be retried.
  final IngredientDraft? ingredientDraft;
  final bool registeringIngredient;

  final String title;
  final double? waterTempC;
  final double? doseGrams;
  final String grindSize;
  final String grinderModel;
  final ExtractionMethod? extractionMethod;
  final String extractionMethodNote;

  /// The last stopwatch reading or manual entry; null if never recorded.
  final Duration? extractionDuration;
  final bool stopwatchRunning;

  /// Live stopwatch reading for the UI.
  final Duration stopwatchElapsed;

  final int acidity;
  final int sweetness;
  final int body;
  final int bitterness;
  final List<String> flavorTags;

  /// Display order; duplicates kept.
  final List<String> instructions;

  /// Confirmed rows only.
  final List<RecipePhoto> photos;
  final bool pendingUpload;
  final bool canEdit;

  bool get isEditing => recipeId != null;
  bool get isSaving => saveStatus == SaveStatus.saving;
  bool get isLastStep => step == RecipeWizardStep.values.last;

  /// Every [error] is a new value, so it clears unless passed again.
  RecipeCreationState copyWith({
    RecipeWizardStep? step,
    LoadStatus? loadStatus,
    SaveStatus? saveStatus,
    Object? error,
    ValueGetter<UuidValue?>? recipeId,
    BeverageKind? ingredientKind,
    String? ingredientQuery,
    List<Ingredient>? ingredientResults,
    bool? searchingIngredients,
    ValueGetter<Ingredient?>? selectedIngredient,
    ValueGetter<IngredientDraft?>? ingredientDraft,
    bool? registeringIngredient,
    String? title,
    ValueGetter<double?>? waterTempC,
    ValueGetter<double?>? doseGrams,
    String? grindSize,
    String? grinderModel,
    ValueGetter<ExtractionMethod?>? extractionMethod,
    String? extractionMethodNote,
    ValueGetter<Duration?>? extractionDuration,
    bool? stopwatchRunning,
    Duration? stopwatchElapsed,
    int? acidity,
    int? sweetness,
    int? body,
    int? bitterness,
    List<String>? flavorTags,
    List<String>? instructions,
    List<RecipePhoto>? photos,
    bool? pendingUpload,
    bool? canEdit,
  }) {
    return RecipeCreationState(
      step: step ?? this.step,
      loadStatus: loadStatus ?? this.loadStatus,
      saveStatus: saveStatus ?? this.saveStatus,
      error: error,
      recipeId: recipeId != null ? recipeId() : this.recipeId,
      ingredientKind: ingredientKind ?? this.ingredientKind,
      ingredientQuery: ingredientQuery ?? this.ingredientQuery,
      ingredientResults: ingredientResults ?? this.ingredientResults,
      searchingIngredients: searchingIngredients ?? this.searchingIngredients,
      selectedIngredient: selectedIngredient != null
          ? selectedIngredient()
          : this.selectedIngredient,
      ingredientDraft: ingredientDraft != null
          ? ingredientDraft()
          : this.ingredientDraft,
      registeringIngredient:
          registeringIngredient ?? this.registeringIngredient,
      title: title ?? this.title,
      waterTempC: waterTempC != null ? waterTempC() : this.waterTempC,
      doseGrams: doseGrams != null ? doseGrams() : this.doseGrams,
      grindSize: grindSize ?? this.grindSize,
      grinderModel: grinderModel ?? this.grinderModel,
      extractionMethod: extractionMethod != null
          ? extractionMethod()
          : this.extractionMethod,
      extractionMethodNote: extractionMethodNote ?? this.extractionMethodNote,
      extractionDuration: extractionDuration != null
          ? extractionDuration()
          : this.extractionDuration,
      stopwatchRunning: stopwatchRunning ?? this.stopwatchRunning,
      stopwatchElapsed: stopwatchElapsed ?? this.stopwatchElapsed,
      acidity: acidity ?? this.acidity,
      sweetness: sweetness ?? this.sweetness,
      body: body ?? this.body,
      bitterness: bitterness ?? this.bitterness,
      flavorTags: flavorTags ?? this.flavorTags,
      instructions: instructions ?? this.instructions,
      photos: photos ?? this.photos,
      pendingUpload: pendingUpload ?? this.pendingUpload,
      canEdit: canEdit ?? this.canEdit,
    );
  }

  @override
  List<Object?> get props => [
    step,
    loadStatus,
    saveStatus,
    error,
    recipeId,
    ingredientKind,
    ingredientQuery,
    ingredientResults,
    searchingIngredients,
    selectedIngredient,
    ingredientDraft,
    registeringIngredient,
    title,
    waterTempC,
    doseGrams,
    grindSize,
    grinderModel,
    extractionMethod,
    extractionMethodNote,
    extractionDuration,
    stopwatchRunning,
    stopwatchElapsed,
    acidity,
    sweetness,
    body,
    bitterness,
    flavorTags,
    instructions,
    photos,
    pendingUpload,
    canEdit,
  ];
}
