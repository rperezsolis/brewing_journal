import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:brewing_journal_flutter/ui/core/error_messages.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  BrewingException brewing(BrewingErrorCode code, [String message = 'm']) =>
      BrewingException(code: code, message: message);

  test('a client network error maps to the connection message', () {
    expect(
      errorMessage(const ServerpodClientNetworkException('down')),
      connectionErrorMessage,
    );
  });

  test('any other client error maps to the connection message', () {
    expect(
      errorMessage(ServerpodClientInternalServerError()),
      connectionErrorMessage,
    );
  });

  test('an unknown error maps to the generic message', () {
    expect(errorMessage(StateError('boom')), genericErrorMessage);
  });

  test('validation shows the message, which names the field', () {
    expect(
      errorMessage(
        brewing(BrewingErrorCode.validation, 'title: must not be empty'),
      ),
      'title: must not be empty',
    );
  });

  test('shared defaults for recipe codes', () {
    expect(
      errorMessage(brewing(BrewingErrorCode.notFound)),
      'Recipe not found',
    );
    expect(
      errorMessage(brewing(BrewingErrorCode.forbidden)),
      "You can't edit this recipe",
    );
    expect(
      errorMessage(brewing(BrewingErrorCode.uploadRejected)),
      'Photo could not be verified — try again or skip',
    );
    expect(
      errorMessage(brewing(BrewingErrorCode.inviteExpired)),
      'This invite has expired. Ask the team owner for a new one.',
    );
    expect(
      errorMessage(brewing(BrewingErrorCode.inviteUsed)),
      'This invite has already been used.',
    );
    expect(
      errorMessage(brewing(BrewingErrorCode.alreadyMember)),
      "You're already in this team.",
    );
  });

  test('overrides win over the shared default', () {
    expect(
      errorMessage(
        brewing(BrewingErrorCode.notFound),
        overrides: {BrewingErrorCode.notFound: 'Invite not found.'},
      ),
      'Invite not found.',
    );
  });
}
