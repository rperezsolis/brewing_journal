// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'BrewSync';

  @override
  String get myRecipes => 'My recipes';

  @override
  String get teams => 'Teams';

  @override
  String get signOut => 'Sign out';

  @override
  String get newRecipe => 'New recipe';

  @override
  String get retry => 'Retry';

  @override
  String get noRecipesYet => 'No recipes yet';

  @override
  String get noRecipesYetDetail => 'Tap New recipe to log your first brew.';

  @override
  String recipeByline(String author, String updated) {
    return '$author · $updated';
  }

  @override
  String get unknownAuthor => 'Unknown author';

  @override
  String get pageNotFound => 'This page does not exist.';

  @override
  String get goHome => 'Go home';

  @override
  String get connectionError =>
      'Can\'t reach the server. Check your connection and try again.';

  @override
  String get genericError => 'Something went wrong. Please try again.';

  @override
  String get recipeNotFound => 'Recipe not found';

  @override
  String get cantEditRecipe => 'You can\'t edit this recipe';

  @override
  String get photoNotVerified =>
      'Photo could not be verified — try again or skip';

  @override
  String get inviteExpired =>
      'This invite has expired. Ask the team owner for a new one.';

  @override
  String get inviteUsed => 'This invite has already been used.';

  @override
  String get alreadyMember => 'You\'re already in this team.';

  @override
  String get recipeNotFoundOrUnshared =>
      'Recipe not found or no longer shared with you';

  @override
  String get viewersCantChange => 'Viewers can\'t change team recipes.';

  @override
  String get recipeCouldNotBeLoaded => 'This recipe couldn\'t be loaded.';

  @override
  String get photoFormatUnsupported =>
      'This image format isn\'t supported. Choose a JPEG or PNG.';

  @override
  String get coffee => 'Coffee';

  @override
  String get tea => 'Tea';

  @override
  String get matcha => 'Matcha';

  @override
  String get roastLight => 'Light';

  @override
  String get roastMedium => 'Medium';

  @override
  String get roastMediumDark => 'Medium-dark';

  @override
  String get roastDark => 'Dark';

  @override
  String get methodV60 => 'V60';

  @override
  String get methodEspresso => 'Espresso';

  @override
  String get methodFrenchPress => 'French press';

  @override
  String get methodAeropress => 'AeroPress';

  @override
  String get methodChemex => 'Chemex';

  @override
  String get methodColdBrew => 'Cold brew';

  @override
  String get methodMatchaWhisk => 'Matcha whisk';

  @override
  String get methodOther => 'Other';

  @override
  String get roleViewer => 'Viewer';

  @override
  String get roleEditor => 'Editor';

  @override
  String get stepBean => 'Bean';

  @override
  String get stepBrew => 'Brew';

  @override
  String get stepFlavor => 'Flavor';

  @override
  String get stepSteps => 'Steps';

  @override
  String get stepPhotos => 'Photos';

  @override
  String get editRecipe => 'Edit recipe';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get finish => 'Finish';

  @override
  String get next => 'Next';

  @override
  String get whatAreYouBrewing => 'What are you brewing?';

  @override
  String searchIngredient(String kind) {
    return 'Search your $kind';
  }

  @override
  String get nothingRegistered => 'Nothing registered yet.';

  @override
  String noMatches(String query) {
    return 'No matches for \"$query\".';
  }

  @override
  String registerNewKind(String kind) {
    return 'Register new $kind';
  }

  @override
  String get nameLabel => 'Name';

  @override
  String get originOptional => 'Origin (optional)';

  @override
  String get roasterOptional => 'Roaster or producer (optional)';

  @override
  String get roastLevelOptional => 'Roast level (optional)';

  @override
  String get notSet => 'Not set';

  @override
  String get processingOptional => 'Processing (optional)';

  @override
  String get processingHint => 'Washed, natural, shade-grown…';

  @override
  String get register => 'Register';

  @override
  String get brewParameters => 'Brew parameters';

  @override
  String get recipeTitle => 'Recipe title';

  @override
  String get waterTemperature => 'Water temperature';

  @override
  String get dose => 'Dose';

  @override
  String get grindSize => 'Grind size';

  @override
  String get grindSizeHint => 'Medium-fine, 18 clicks…';

  @override
  String get grinderModel => 'Grinder model';

  @override
  String get grinderModelHint => 'Comandante C40, Niche Zero…';

  @override
  String get extractionMethodLabel => 'Extraction method';

  @override
  String get describeTheMethod => 'Describe the method';

  @override
  String get enterTime => 'Or enter the time (m:ss)';

  @override
  String get timeFormatError => 'Use m:ss, for example 2:30';

  @override
  String get extractionTime => 'Extraction time';

  @override
  String get stop => 'Stop';

  @override
  String get start => 'Start';

  @override
  String get reset => 'Reset';

  @override
  String get flavorMap => 'Flavor map';

  @override
  String get flavorTags => 'Flavor tags';

  @override
  String get addTagHint => 'Add a tag (fruity, chocolate, floral…)';

  @override
  String atMostTags(int count) {
    return 'At most $count tags';
  }

  @override
  String get addTag => 'Add tag';

  @override
  String get acidity => 'Acidity';

  @override
  String get sweetness => 'Sweetness';

  @override
  String get flavorBody => 'Body';

  @override
  String get bitterness => 'Bitterness';

  @override
  String flavorMapSemantics(
    int acidity,
    int sweetness,
    int body,
    int bitterness,
    int maxScore,
  ) {
    return 'Flavor map: acidity $acidity, sweetness $sweetness, body $body, bitterness $bitterness, out of $maxScore';
  }

  @override
  String get extraSteps => 'Extra steps';

  @override
  String get skip => 'Skip';

  @override
  String get extraStepsHelp =>
      'Optional. Anything outside the brew parameters, like \"use 150ml of whole milk\" or \"add cinnamon and stir\".';

  @override
  String atMostSteps(int count) {
    return 'At most $count steps';
  }

  @override
  String get addAStep => 'Add a step';

  @override
  String get addStep => 'Add step';

  @override
  String get noExtraSteps => 'No extra steps yet.';

  @override
  String get reorder => 'Reorder';

  @override
  String get editStep => 'Edit step';

  @override
  String get removeStep => 'Remove step';

  @override
  String get stepCantBeEmpty => 'A step can\'t be empty';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get photos => 'Photos';

  @override
  String photosHelp(int count) {
    return 'Optional. Add up to $count photos of the cup, the crema, or the packaging, or tap Finish to save without.';
  }

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get addPhoto => 'Add photo';

  @override
  String get deleteRecipeTitle => 'Delete this recipe?';

  @override
  String deleteRecipeBody(String title) {
    return '“$title” will be removed. This cannot be undone.';
  }

  @override
  String get delete => 'Delete';

  @override
  String get createOrJoinTeam => 'Create or join a team as an editor first.';

  @override
  String get addToTeam => 'Add to team';

  @override
  String get brewFallback => 'Brew';

  @override
  String get share => 'Share';

  @override
  String get removeFromTeam => 'Remove from team';

  @override
  String get edit => 'Edit';

  @override
  String get prepAndExtraSteps => 'Prep & extra steps';

  @override
  String get noExtractionTime => 'No extraction time recorded';

  @override
  String get extractionTimer => 'Extraction timer';

  @override
  String targetDuration(String time) {
    return 'Target $time';
  }

  @override
  String get countDown => 'Count down';

  @override
  String get countUp => 'Count up';

  @override
  String get stopAlarm => 'Stop alarm';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get couldNotCreateShareImage => 'Could not create the share image.';

  @override
  String get couldNotSaveImage => 'Could not save the image.';

  @override
  String get sharingNotSupported =>
      'Sharing isn\'t supported here — download the image instead';

  @override
  String get downloadImage => 'Download image';

  @override
  String get madeWithBrewSync => 'Made with BrewSync';

  @override
  String brewingSummary(String method, String dose, String temp) {
    return 'Brewing: $method · $dose g · $temp °C';
  }

  @override
  String grindingSummary(String grind, String grinder) {
    return 'Grinding: $grind · $grinder';
  }

  @override
  String kindAndName(String kind, String name) {
    return '$kind: $name';
  }

  @override
  String moreCount(int count) {
    return '+$count more';
  }

  @override
  String timerSummary(String minutes, String seconds) {
    return 'Timer: ${minutes}m ${seconds}s';
  }

  @override
  String get joinWithInvite => 'Join with invite';

  @override
  String get createTeam => 'Create team';

  @override
  String get noTeamsYet => 'No teams yet. Create one or join with an invite.';

  @override
  String ownerRole(String role) {
    return 'Owner · $role';
  }

  @override
  String get create => 'Create';

  @override
  String get inviteUrlOrToken => 'Invite URL or token';

  @override
  String get join => 'Join';

  @override
  String get inviteToTeam => 'Invite to team';

  @override
  String get inviteTtlOneHour => '1h';

  @override
  String get inviteTtlOneDay => '24h';

  @override
  String get inviteTtlOneWeek => '7d';

  @override
  String get inviteLinkCopied => 'Invite link copied';

  @override
  String get copyLink => 'Copy';

  @override
  String get singleUse => 'Single use';

  @override
  String get teamFallback => 'Team';

  @override
  String get invite => 'Invite';

  @override
  String get noRecipesOnTeam => 'No recipes on this team yet.';

  @override
  String get teamInvite => 'Team invite';

  @override
  String youJoined(String team, String role) {
    return 'You joined $team as $role.';
  }

  @override
  String get inviteNotFound => 'Invite not found.';

  @override
  String get openTeam => 'Open team';

  @override
  String validationNameLength(int max) {
    return 'Name must be 1 to $max characters';
  }

  @override
  String validationTagTooLong(int max) {
    return 'A tag must be at most $max characters';
  }

  @override
  String validationTooManyTags(int max) {
    return 'At most $max tags';
  }

  @override
  String validationTooManyInstructions(int max) {
    return 'At most $max instructions';
  }

  @override
  String get validationEmptyInstruction => 'An instruction can\'t be empty';

  @override
  String validationInstructionTooLong(int max) {
    return 'An instruction must be at most $max characters';
  }

  @override
  String get validationSelectIngredient => 'Select or register an ingredient';

  @override
  String get validationAddTitle => 'Add a title';

  @override
  String validationWaterTemp(int min, int max) {
    return 'Water temperature must be between $min and $max °C';
  }

  @override
  String validationDose(String min, String max) {
    return 'Dose must be between $min and $max g';
  }

  @override
  String get validationAddGrindSize => 'Add a grind size';

  @override
  String get validationAddGrinder => 'Add a grinder model';

  @override
  String get validationChooseMethod => 'Choose an extraction method';

  @override
  String get validationDescribeMethod => 'Describe the extraction method';

  @override
  String get validationExtractionTime =>
      'Extraction time must be between 1 s and 2 h';

  @override
  String validationTooManyPhotos(int max) {
    return 'At most $max photos';
  }

  @override
  String get accept => 'Accept';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get showFavorites => 'Show favorites';

  @override
  String get showAllRecipes => 'Show all recipes';

  @override
  String get favoriteNameTakenTitle => 'Already in favorites';

  @override
  String get favoriteNameTakenBody =>
      'A recipe with this name is already in your favorites. Replace it with this one?';

  @override
  String get noFavoriteRecipes => 'No favorite recipes';

  @override
  String get noFavoriteRecipesDetail =>
      'Save a recipe to keep the version you want to brew.';
}
