import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:brewing_journal_flutter/l10n/app_localizations.dart';

extension BeverageKindLabel on BeverageKind {
  String label(AppLocalizations l10n) => switch (this) {
    BeverageKind.coffee => l10n.coffee,
    BeverageKind.tea => l10n.tea,
    BeverageKind.matcha => l10n.matcha,
  };
}

extension RoastLevelLabel on RoastLevel {
  String label(AppLocalizations l10n) => switch (this) {
    RoastLevel.light => l10n.roastLight,
    RoastLevel.medium => l10n.roastMedium,
    RoastLevel.mediumDark => l10n.roastMediumDark,
    RoastLevel.dark => l10n.roastDark,
  };
}

extension ExtractionMethodLabel on ExtractionMethod {
  String label(AppLocalizations l10n) => switch (this) {
    ExtractionMethod.v60 => l10n.methodV60,
    ExtractionMethod.espresso => l10n.methodEspresso,
    ExtractionMethod.frenchPress => l10n.methodFrenchPress,
    ExtractionMethod.aeropress => l10n.methodAeropress,
    ExtractionMethod.chemex => l10n.methodChemex,
    ExtractionMethod.coldBrew => l10n.methodColdBrew,
    ExtractionMethod.matchaWhisk => l10n.methodMatchaWhisk,
    ExtractionMethod.other => l10n.methodOther,
  };
}

extension TeamRoleLabel on TeamRole {
  String label(AppLocalizations l10n) => switch (this) {
    TeamRole.viewer => l10n.roleViewer,
    TeamRole.editor => l10n.roleEditor,
  };
}

/// "Ethiopia · Onyx · Light · Washed", leaving out missing attributes.
String ingredientDetails(Ingredient ingredient, AppLocalizations l10n) => [
  ingredient.origin,
  ingredient.roaster,
  ingredient.roastLevel?.label(l10n),
  ingredient.processing,
].whereType<String>().where((s) => s.isNotEmpty).join(' · ');
