/// Stable ids used as `screen_name` and as the `name` of each GoRoute.
///
/// Names stay free of ids and invite tokens so a screen view cannot carry
/// a user-specific path.
abstract final class ScreenNames {
  static const splash = 'splash';
  static const signIn = 'sign_in';
  static const invite = 'invite';
  static const recipeList = 'recipe_list';
  static const recipeCreate = 'recipe_create';
  static const recipeEdit = 'recipe_edit';
  static const recipeShare = 'recipe_share';
  static const brewMode = 'brew_mode';
  static const teams = 'teams';
  static const teamDetail = 'team_detail';
  static const notFound = 'not_found';
}
