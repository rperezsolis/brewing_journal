import 'package:brewing_journal_client/brewing_journal_client.dart';

const connectionErrorMessage =
    "Can't reach the server. Check your connection and try again.";
const genericErrorMessage = 'Something went wrong. Please try again.';

/// Maps an error thrown by a repository to a message that is safe to show.
String errorMessage(Object error) {
  if (error is ServerpodClientException) return connectionErrorMessage;
  return genericErrorMessage;
}
