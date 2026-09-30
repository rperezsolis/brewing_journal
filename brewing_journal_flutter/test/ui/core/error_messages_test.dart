import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:brewing_journal_flutter/l10n/app_localizations.dart';
import 'package:brewing_journal_flutter/ui/core/error_messages.dart';
import 'package:brewing_journal_flutter/ui/core/validation_messages.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  BrewingException brewing(BrewingErrorCode code, [String message = 'm']) =>
      BrewingException(code: code, message: message);

  test('a client network error maps to the connection message', () {
    expect(
      errorMessage(const ServerpodClientNetworkException('down'), l10n),
      l10n.connectionError,
    );
  });

  test('any other client error maps to the connection message', () {
    expect(
      errorMessage(ServerpodClientInternalServerError(), l10n),
      l10n.connectionError,
    );
  });

  test('an unknown error maps to the generic message', () {
    expect(errorMessage(StateError('boom'), l10n), l10n.genericError);
  });

  test('validation shows the message, which names the field', () {
    expect(
      errorMessage(
        brewing(BrewingErrorCode.validation, 'title: must not be empty'),
        l10n,
      ),
      'title: must not be empty',
    );
  });

  test('a client validation key is localized', () {
    expect(
      errorMessage(
        brewing(BrewingErrorCode.validation, validationMessage('addTitle')),
        l10n,
      ),
      l10n.validationAddTitle,
    );
    expect(
      errorMessage(
        brewing(
          BrewingErrorCode.validation,
          validationMessage('addTitle'),
        ),
        lookupAppLocalizations(const Locale('es', '419')),
      ),
      'Agrega un título',
    );
  });

  test('shared defaults for recipe codes', () {
    expect(
      errorMessage(brewing(BrewingErrorCode.notFound), l10n),
      l10n.recipeNotFound,
    );
    expect(
      errorMessage(brewing(BrewingErrorCode.forbidden), l10n),
      l10n.cantEditRecipe,
    );
    expect(
      errorMessage(brewing(BrewingErrorCode.uploadRejected), l10n),
      l10n.photoNotVerified,
    );
    expect(
      errorMessage(brewing(BrewingErrorCode.inviteExpired), l10n),
      l10n.inviteExpired,
    );
    expect(
      errorMessage(brewing(BrewingErrorCode.inviteUsed), l10n),
      l10n.inviteUsed,
    );
    expect(
      errorMessage(brewing(BrewingErrorCode.alreadyMember), l10n),
      l10n.alreadyMember,
    );
  });

  test('overrides win over the shared default', () {
    expect(
      errorMessage(
        brewing(BrewingErrorCode.notFound),
        l10n,
        overrides: {BrewingErrorCode.notFound: 'Invite not found.'},
      ),
      'Invite not found.',
    );
  });
}
