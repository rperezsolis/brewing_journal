import 'package:brewing_journal_client/brewing_journal_client.dart';

const connectionErrorMessage =
    "Can't reach the server. Check your connection and try again.";
const genericErrorMessage = 'Something went wrong. Please try again.';

const _defaults = <BrewingErrorCode, String>{
  BrewingErrorCode.notFound: 'Recipe not found',
  BrewingErrorCode.forbidden: "You can't edit this recipe",
  BrewingErrorCode.uploadRejected:
      'Photo could not be verified — try again or skip',
  BrewingErrorCode.inviteExpired:
      'This invite has expired. Ask the team owner for a new one.',
  BrewingErrorCode.inviteUsed: 'This invite has already been used.',
  BrewingErrorCode.alreadyMember: "You're already in this team.",
};

/// Maps an error thrown by a repository to a message that is safe to show.
///
/// A [BrewingException] uses `overrides[code]` first, then the shared default
/// for that code. `validation` defaults to the server's message, which names
/// the field.
String errorMessage(
  Object error, {
  Map<BrewingErrorCode, String> overrides = const {},
}) {
  if (error is BrewingException) {
    return overrides[error.code] ??
        _defaults[error.code] ??
        (error.code == BrewingErrorCode.validation
            ? error.message
            : genericErrorMessage);
  }
  if (error is ServerpodClientException) return connectionErrorMessage;
  return genericErrorMessage;
}
