import '../generated/protocol.dart';
import 'recipe_limits.dart';

BrewingException validationError(String field, String problem) =>
    BrewingException(
      code: BrewingErrorCode.validation,
      message: '$field: $problem',
    );

/// Trims [value] and checks its length is `1..maxLength`.
String validateText(String field, String value, int maxLength) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) throw validationError(field, 'must not be empty');
  if (trimmed.length > maxLength) {
    throw validationError(field, 'must be at most $maxLength characters');
  }
  return trimmed;
}

String tagKeyOf(String tag) => tag.trim().toLowerCase();

/// A validated, normalized [RecipeDraft], ready to be written.
class ValidatedRecipe {
  ValidatedRecipe({
    required this.title,
    required this.grindSize,
    required this.grinderModel,
    required this.extractionMethodNote,
    required this.tags,
    required this.instructions,
  });

  final String title;
  final String grindSize;
  final String grinderModel;
  final String? extractionMethodNote;

  /// Trimmed tags, de-duplicated by [tagKeyOf], first spelling kept.
  final List<String> tags;

  /// Trimmed instructions, in the submitted order, duplicates kept.
  final List<String> instructions;
}

/// Validates every field of [draft]; throws a `validation` [BrewingException]
/// naming the first invalid field.
ValidatedRecipe validateRecipeDraft(RecipeDraft draft) {
  final title = validateText('title', draft.title, kTitleMaxLength);
  final grindSize = validateText('grindSize', draft.grindSize, kGrindMaxLength);
  final grinderModel = validateText(
    'grinderModel',
    draft.grinderModel,
    kGrindMaxLength,
  );

  _checkRange('waterTempC', draft.waterTempC, kMinWaterTempC, kMaxWaterTempC);
  _checkRange('doseGrams', draft.doseGrams, kMinDoseGrams, kMaxDoseGrams);

  final duration = draft.extractionDuration;
  if (duration != null &&
      (duration < kMinExtractionDuration ||
          duration > kMaxExtractionDuration)) {
    throw validationError('extractionDuration', 'must be between 1s and 2h');
  }

  for (final (field, score) in [
    ('acidity', draft.acidity),
    ('sweetness', draft.sweetness),
    ('body', draft.body),
    ('bitterness', draft.bitterness),
  ]) {
    if (score < 0 || score > kMaxScore) {
      throw validationError(field, 'must be between 0 and $kMaxScore');
    }
  }

  final note = draft.extractionMethodNote?.trim();
  if (draft.extractionMethod == ExtractionMethod.other &&
      (note == null || note.isEmpty)) {
    throw validationError(
      'extractionMethodNote',
      'is required when the method is other',
    );
  }

  return ValidatedRecipe(
    title: title,
    grindSize: grindSize,
    grinderModel: grinderModel,
    extractionMethodNote: (note == null || note.isEmpty) ? null : note,
    tags: validateTags(draft.flavorTags),
    instructions: validateInstructions(draft.instructions),
  );
}

List<String> validateTags(List<String> tags) {
  final byKey = <String, String>{};
  for (final tag in tags) {
    final trimmed = validateText('flavorTags', tag, kTagMaxLength);
    byKey.putIfAbsent(tagKeyOf(trimmed), () => trimmed);
  }
  if (byKey.length > kMaxTags) {
    throw validationError('flavorTags', 'at most $kMaxTags tags');
  }
  return byKey.values.toList();
}

List<String> validateInstructions(List<String> instructions) {
  if (instructions.length > kMaxInstructions) {
    throw validationError(
      'instructions',
      'at most $kMaxInstructions instructions',
    );
  }
  return [
    for (final instruction in instructions)
      validateText('instructions', instruction, kInstructionMaxLength),
  ];
}

void _checkRange(String field, double value, double min, double max) {
  if (value.isNaN || value < min || value > max) {
    throw validationError(field, 'must be between $min and $max');
  }
}
