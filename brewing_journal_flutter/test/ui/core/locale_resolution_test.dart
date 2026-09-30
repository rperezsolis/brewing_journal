import 'package:brewing_journal_flutter/l10n/app_localizations.dart';
import 'package:brewing_journal_flutter/ui/core/locale_resolution.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const supported = AppLocalizations.supportedLocales;

  test('spanish locales use Latin American Spanish', () {
    expect(
      resolveBrewSyncLocales(const [Locale('es', 'MX')], supported),
      const Locale('es', '419'),
    );
    expect(
      resolveBrewSyncLocales(const [Locale('es')], supported),
      const Locale('es', '419'),
    );
    expect(lookupAppLocalizations(const Locale('es', '419')).teams, 'Equipos');
  });

  test('portuguese locales use Brazilian Portuguese', () {
    expect(
      resolveBrewSyncLocales(const [Locale('pt', 'PT')], supported),
      const Locale('pt', 'BR'),
    );
    expect(
      resolveBrewSyncLocales(const [Locale('pt')], supported),
      const Locale('pt', 'BR'),
    );
    expect(
      lookupAppLocalizations(const Locale('pt', 'BR')).teams,
      'Equipes',
    );
  });

  test('english and unknown languages stay in English', () {
    expect(
      resolveBrewSyncLocales(const [Locale('en', 'GB')], supported),
      const Locale('en'),
    );
    expect(
      resolveBrewSyncLocales(const [Locale('fr')], supported),
      const Locale('en'),
    );
    expect(lookupAppLocalizations(const Locale('en')).teams, 'Teams');
  });

  test('the first supported language in the list wins', () {
    expect(
      resolveBrewSyncLocales(const [
        Locale('fr'),
        Locale('pt', 'BR'),
        Locale('es', 'MX'),
      ], supported),
      const Locale('pt', 'BR'),
    );
  });
}
