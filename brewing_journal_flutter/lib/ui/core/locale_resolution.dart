import 'package:flutter/widgets.dart';

/// Picks a BrewSync catalog for the device language list.
///
/// Spanish uses Latin American Spanish (`es_419`). Portuguese uses Brazilian
/// Portuguese (`pt_BR`), the Latin American variety. Anything else stays in
/// English.
Locale resolveBrewSyncLocales(
  List<Locale>? locales,
  Iterable<Locale> supportedLocales,
) {
  final supported = supportedLocales.toList();
  for (final locale in locales ?? const <Locale>[]) {
    final match = switch (locale.languageCode) {
      'es' => const Locale('es', '419'),
      'pt' => const Locale('pt', 'BR'),
      'en' => const Locale('en'),
      _ => null,
    };
    if (match != null && supported.contains(match)) return match;
  }
  for (final locale in supported) {
    if (locale == const Locale('en')) return locale;
  }
  return supported.first;
}
