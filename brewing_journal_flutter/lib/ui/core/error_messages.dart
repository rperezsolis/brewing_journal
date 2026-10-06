import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:brewing_journal_flutter/l10n/app_localizations.dart';

import 'validation_messages.dart';

/// Maps an error thrown by a repository to a message that is safe to show.
///
/// A [BrewingException] uses `overrides[code]` first, then the shared wording
/// for that code. `validation` uses a client key when the message starts with
/// [validationMessagePrefix]; otherwise it shows the server's message, which
/// names the field.
String errorMessage(
  Object error,
  AppLocalizations l10n, {
  Map<BrewingErrorCode, String> overrides = const {},
}) {
  if (error is BrewingException) {
    final override = overrides[error.code];
    if (override != null) return override;
    return switch (error.code) {
      BrewingErrorCode.validation =>
        localizeValidation(l10n, error.message) ?? error.message,
      BrewingErrorCode.notFound => l10n.recipeNotFound,
      BrewingErrorCode.forbidden => l10n.cantEditRecipe,
      BrewingErrorCode.uploadRejected => l10n.photoNotVerified,
      BrewingErrorCode.inviteExpired => l10n.inviteExpired,
      BrewingErrorCode.inviteUsed => l10n.inviteUsed,
      BrewingErrorCode.alreadyMember => l10n.alreadyMember,
    };
  }
  if (error is ServerpodClientException) return l10n.connectionError;
  return l10n.genericError;
}

/// Turns a [validationMessage] key into a sentence, or null when [message]
/// is server text.
String? localizeValidation(AppLocalizations l10n, String message) {
  if (!message.startsWith(validationMessagePrefix)) return null;
  final parts = message.substring(validationMessagePrefix.length).split(':');
  final key = parts.first;
  final args = parts.sublist(1);
  return switch (key) {
    'nameLength' => l10n.validationNameLength(int.parse(args[0])),
    'tagTooLong' => l10n.validationTagTooLong(int.parse(args[0])),
    'tooManyTags' => l10n.validationTooManyTags(int.parse(args[0])),
    'tooManyInstructions' => l10n.validationTooManyInstructions(
      int.parse(args[0]),
    ),
    'emptyInstruction' => l10n.validationEmptyInstruction,
    'instructionTooLong' => l10n.validationInstructionTooLong(
      int.parse(args[0]),
    ),
    'selectIngredient' => l10n.validationSelectIngredient,
    'addTitle' => l10n.validationAddTitle,
    'waterTemp' => l10n.validationWaterTemp(
      int.parse(args[0]),
      int.parse(args[1]),
    ),
    'dose' => l10n.validationDose(args[0], args[1]),
    'waterMl' => l10n.validationWaterQuantity(args[0], args[1]),
    'addGrindSize' => l10n.validationAddGrindSize,
    'addGrinder' => l10n.validationAddGrinder,
    'chooseMethod' => l10n.validationChooseMethod,
    'describeMethod' => l10n.validationDescribeMethod,
    'extractionTime' => l10n.validationExtractionTime,
    'tooManyPhotos' => l10n.validationTooManyPhotos(int.parse(args[0])),
    'photoFormat' => l10n.photoFormatUnsupported,
    _ => null,
  };
}
