import 'package:brewing_journal_client/brewing_journal_client.dart';

extension BeverageKindLabel on BeverageKind {
  String get label => switch (this) {
    BeverageKind.coffee => 'Coffee',
    BeverageKind.tea => 'Tea',
    BeverageKind.matcha => 'Matcha',
  };
}

extension RoastLevelLabel on RoastLevel {
  String get label => switch (this) {
    RoastLevel.light => 'Light',
    RoastLevel.medium => 'Medium',
    RoastLevel.mediumDark => 'Medium-dark',
    RoastLevel.dark => 'Dark',
  };
}

extension ExtractionMethodLabel on ExtractionMethod {
  String get label => switch (this) {
    ExtractionMethod.v60 => 'V60',
    ExtractionMethod.espresso => 'Espresso',
    ExtractionMethod.frenchPress => 'French press',
    ExtractionMethod.aeropress => 'AeroPress',
    ExtractionMethod.chemex => 'Chemex',
    ExtractionMethod.coldBrew => 'Cold brew',
    ExtractionMethod.matchaWhisk => 'Matcha whisk',
    ExtractionMethod.other => 'Other',
  };
}

extension TeamRoleLabel on TeamRole {
  String get label => switch (this) {
    TeamRole.viewer => 'Viewer',
    TeamRole.editor => 'Editor',
  };
}

/// "Ethiopia · Onyx · Light · Washed", leaving out missing attributes.
String ingredientDetails(Ingredient ingredient) => [
  ingredient.origin,
  ingredient.roaster,
  ingredient.roastLevel?.label,
  ingredient.processing,
].whereType<String>().where((s) => s.isNotEmpty).join(' · ');
