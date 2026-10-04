import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es', '419'),
    Locale('pt', 'BR'),
    Locale('es'),
    Locale('pt'),
  ];

  /// Application name shown in the window title and app bars
  ///
  /// In en, this message translates to:
  /// **'BrewSync'**
  String get appTitle;

  /// Bottom navigation label for the user's own recipes
  ///
  /// In en, this message translates to:
  /// **'My recipes'**
  String get myRecipes;

  /// Bottom navigation label for teams
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get teams;

  /// Tooltip for the sign-out button
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// Button that starts a new recipe
  ///
  /// In en, this message translates to:
  /// **'New recipe'**
  String get newRecipe;

  /// Button that repeats a failed action
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Empty state title on the recipe list
  ///
  /// In en, this message translates to:
  /// **'No recipes yet'**
  String get noRecipesYet;

  /// Empty state detail on the recipe list
  ///
  /// In en, this message translates to:
  /// **'Tap New recipe to log your first brew.'**
  String get noRecipesYetDetail;

  /// Recipe tile line with the author and the time the recipe was saved
  ///
  /// In en, this message translates to:
  /// **'{author} · {updated}'**
  String recipeByline(String author, String updated);

  /// Recipe tile author when the profile has no name or email
  ///
  /// In en, this message translates to:
  /// **'Unknown author'**
  String get unknownAuthor;

  /// Message on the unknown-route screen
  ///
  /// In en, this message translates to:
  /// **'This page does not exist.'**
  String get pageNotFound;

  /// Button that returns to the recipe list
  ///
  /// In en, this message translates to:
  /// **'Go home'**
  String get goHome;

  /// Shown when the app cannot contact the server
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server. Check your connection and try again.'**
  String get connectionError;

  /// Fallback when an error has no specific message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericError;

  /// Default message when a recipe does not exist
  ///
  /// In en, this message translates to:
  /// **'Recipe not found'**
  String get recipeNotFound;

  /// Default message when the user lacks edit access
  ///
  /// In en, this message translates to:
  /// **'You can\'t edit this recipe'**
  String get cantEditRecipe;

  /// Shown when a photo upload is rejected
  ///
  /// In en, this message translates to:
  /// **'Photo could not be verified — try again or skip'**
  String get photoNotVerified;

  /// Shown when a team invite is past its expiry
  ///
  /// In en, this message translates to:
  /// **'This invite has expired. Ask the team owner for a new one.'**
  String get inviteExpired;

  /// Shown when a single-use invite was already accepted
  ///
  /// In en, this message translates to:
  /// **'This invite has already been used.'**
  String get inviteUsed;

  /// Shown when the user is already a member of the invited team
  ///
  /// In en, this message translates to:
  /// **'You\'re already in this team.'**
  String get alreadyMember;

  /// Shown when a shared recipe can no longer be opened
  ///
  /// In en, this message translates to:
  /// **'Recipe not found or no longer shared with you'**
  String get recipeNotFoundOrUnshared;

  /// Shown when a viewer tries to edit a team recipe
  ///
  /// In en, this message translates to:
  /// **'Viewers can\'t change team recipes.'**
  String get viewersCantChange;

  /// Shown when the recipe wizard fails to load
  ///
  /// In en, this message translates to:
  /// **'This recipe couldn\'t be loaded.'**
  String get recipeCouldNotBeLoaded;

  /// Shown when the chosen photo is not JPEG or PNG
  ///
  /// In en, this message translates to:
  /// **'This image format isn\'t supported. Choose a JPEG or PNG.'**
  String get photoFormatUnsupported;

  /// Beverage kind
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get coffee;

  /// Beverage kind
  ///
  /// In en, this message translates to:
  /// **'Tea'**
  String get tea;

  /// Beverage kind
  ///
  /// In en, this message translates to:
  /// **'Matcha'**
  String get matcha;

  /// Roast level
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get roastLight;

  /// Roast level
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get roastMedium;

  /// Roast level
  ///
  /// In en, this message translates to:
  /// **'Medium-dark'**
  String get roastMediumDark;

  /// Roast level
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get roastDark;

  /// Extraction method name
  ///
  /// In en, this message translates to:
  /// **'V60'**
  String get methodV60;

  /// Extraction method name
  ///
  /// In en, this message translates to:
  /// **'Espresso'**
  String get methodEspresso;

  /// Extraction method name
  ///
  /// In en, this message translates to:
  /// **'French press'**
  String get methodFrenchPress;

  /// Extraction method name
  ///
  /// In en, this message translates to:
  /// **'AeroPress'**
  String get methodAeropress;

  /// Extraction method name
  ///
  /// In en, this message translates to:
  /// **'Chemex'**
  String get methodChemex;

  /// Extraction method name
  ///
  /// In en, this message translates to:
  /// **'Cold brew'**
  String get methodColdBrew;

  /// Extraction method name
  ///
  /// In en, this message translates to:
  /// **'Matcha whisk'**
  String get methodMatchaWhisk;

  /// Extraction method when none of the named methods apply
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get methodOther;

  /// Team role that can read recipes
  ///
  /// In en, this message translates to:
  /// **'Viewer'**
  String get roleViewer;

  /// Team role that can change recipes
  ///
  /// In en, this message translates to:
  /// **'Editor'**
  String get roleEditor;

  /// Wizard step for choosing the ingredient
  ///
  /// In en, this message translates to:
  /// **'Bean'**
  String get stepBean;

  /// Wizard step for brew parameters
  ///
  /// In en, this message translates to:
  /// **'Brew'**
  String get stepBrew;

  /// Wizard step for the flavor map
  ///
  /// In en, this message translates to:
  /// **'Flavor'**
  String get stepFlavor;

  /// Wizard step for extra instructions
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get stepSteps;

  /// Wizard step for photos
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get stepPhotos;

  /// Title of the wizard when editing
  ///
  /// In en, this message translates to:
  /// **'Edit recipe'**
  String get editRecipe;

  /// Tooltip for the button that leaves the wizard
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Button that returns to the previous step or screen
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Button that saves the recipe
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// Button that advances the wizard
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Heading of the ingredient step
  ///
  /// In en, this message translates to:
  /// **'What are you brewing?'**
  String get whatAreYouBrewing;

  /// Search field label. kind is the beverage, already lowercased.
  ///
  /// In en, this message translates to:
  /// **'Search your {kind}'**
  String searchIngredient(String kind);

  /// Empty ingredient search before the user has registered any
  ///
  /// In en, this message translates to:
  /// **'Nothing registered yet.'**
  String get nothingRegistered;

  /// Empty ingredient search for a query
  ///
  /// In en, this message translates to:
  /// **'No matches for \"{query}\".'**
  String noMatches(String query);

  /// Button and sheet title for registering an ingredient. kind is already lowercased.
  ///
  /// In en, this message translates to:
  /// **'Register new {kind}'**
  String registerNewKind(String kind);

  /// Label for a name field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// Ingredient origin field
  ///
  /// In en, this message translates to:
  /// **'Origin (optional)'**
  String get originOptional;

  /// Ingredient roaster field
  ///
  /// In en, this message translates to:
  /// **'Roaster or producer (optional)'**
  String get roasterOptional;

  /// Ingredient roast level field
  ///
  /// In en, this message translates to:
  /// **'Roast level (optional)'**
  String get roastLevelOptional;

  /// Dropdown option when roast level is unset
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// Ingredient processing field
  ///
  /// In en, this message translates to:
  /// **'Processing (optional)'**
  String get processingOptional;

  /// Hint for the processing field
  ///
  /// In en, this message translates to:
  /// **'Washed, natural, shade-grown…'**
  String get processingHint;

  /// Button that saves a new ingredient
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Heading of the extraction step
  ///
  /// In en, this message translates to:
  /// **'Brew parameters'**
  String get brewParameters;

  /// Label for the recipe title field
  ///
  /// In en, this message translates to:
  /// **'Recipe title'**
  String get recipeTitle;

  /// Label for the water temperature field
  ///
  /// In en, this message translates to:
  /// **'Water temperature'**
  String get waterTemperature;

  /// Label for the dose field
  ///
  /// In en, this message translates to:
  /// **'Dose'**
  String get dose;

  /// Label for the grind size field
  ///
  /// In en, this message translates to:
  /// **'Grind size'**
  String get grindSize;

  /// Hint for the grind size field
  ///
  /// In en, this message translates to:
  /// **'Medium-fine, 18 clicks…'**
  String get grindSizeHint;

  /// Label for the grinder model field
  ///
  /// In en, this message translates to:
  /// **'Grinder model'**
  String get grinderModel;

  /// Hint for the grinder model field
  ///
  /// In en, this message translates to:
  /// **'Comandante C40, Niche Zero…'**
  String get grinderModelHint;

  /// Label for the extraction method dropdown
  ///
  /// In en, this message translates to:
  /// **'Extraction method'**
  String get extractionMethodLabel;

  /// Label shown when the extraction method is Other
  ///
  /// In en, this message translates to:
  /// **'Describe the method'**
  String get describeTheMethod;

  /// Label for typing an extraction duration
  ///
  /// In en, this message translates to:
  /// **'Or enter the time (m:ss)'**
  String get enterTime;

  /// Error when a typed duration is not m:ss
  ///
  /// In en, this message translates to:
  /// **'Use m:ss, for example 2:30'**
  String get timeFormatError;

  /// Heading of the stopwatch card
  ///
  /// In en, this message translates to:
  /// **'Extraction time'**
  String get extractionTime;

  /// Button that stops a timer
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// Button that starts a timer
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// Button that clears the stopwatch
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Heading of the flavor step
  ///
  /// In en, this message translates to:
  /// **'Flavor map'**
  String get flavorMap;

  /// Heading above flavor tag chips
  ///
  /// In en, this message translates to:
  /// **'Flavor tags'**
  String get flavorTags;

  /// Label of the flavor tag field
  ///
  /// In en, this message translates to:
  /// **'Add a tag (fruity, chocolate, floral…)'**
  String get addTagHint;

  /// Label when the flavor tag list is full
  ///
  /// In en, this message translates to:
  /// **'At most {count} tags'**
  String atMostTags(int count);

  /// Tooltip for the add-tag button
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get addTag;

  /// Flavor score name
  ///
  /// In en, this message translates to:
  /// **'Acidity'**
  String get acidity;

  /// Flavor score name
  ///
  /// In en, this message translates to:
  /// **'Sweetness'**
  String get sweetness;

  /// Flavor score name
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get flavorBody;

  /// Flavor score name
  ///
  /// In en, this message translates to:
  /// **'Bitterness'**
  String get bitterness;

  /// Screen reader description of the flavor radar
  ///
  /// In en, this message translates to:
  /// **'Flavor map: acidity {acidity}, sweetness {sweetness}, body {body}, bitterness {bitterness}, out of {maxScore}'**
  String flavorMapSemantics(
    int acidity,
    int sweetness,
    int body,
    int bitterness,
    int maxScore,
  );

  /// Heading of the instructions step
  ///
  /// In en, this message translates to:
  /// **'Extra steps'**
  String get extraSteps;

  /// Button that skips extra steps
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Help text on the instructions step
  ///
  /// In en, this message translates to:
  /// **'Optional. Anything outside the brew parameters, like \"use 150ml of whole milk\" or \"add cinnamon and stir\".'**
  String get extraStepsHelp;

  /// Label when the instruction list is full
  ///
  /// In en, this message translates to:
  /// **'At most {count} steps'**
  String atMostSteps(int count);

  /// Label of the instruction field
  ///
  /// In en, this message translates to:
  /// **'Add a step'**
  String get addAStep;

  /// Tooltip for the add-step button
  ///
  /// In en, this message translates to:
  /// **'Add step'**
  String get addStep;

  /// Empty state of the instruction list
  ///
  /// In en, this message translates to:
  /// **'No extra steps yet.'**
  String get noExtraSteps;

  /// Screen reader label for the drag handle
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorder;

  /// Tooltip and dialog title for editing an instruction
  ///
  /// In en, this message translates to:
  /// **'Edit step'**
  String get editStep;

  /// Tooltip for deleting an instruction
  ///
  /// In en, this message translates to:
  /// **'Remove step'**
  String get removeStep;

  /// Error under an empty instruction field
  ///
  /// In en, this message translates to:
  /// **'A step can\'t be empty'**
  String get stepCantBeEmpty;

  /// Button that dismisses a dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Button that saves a dialog
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Heading of the photos step
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// Help text on the photos step
  ///
  /// In en, this message translates to:
  /// **'Optional. Add up to {count} photos of the cup, the crema, or the packaging, or tap Finish to save without.'**
  String photosHelp(int count);

  /// Tooltip for deleting a photo
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// Label of the add-photo tile
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addPhoto;

  /// Title of the delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete this recipe?'**
  String get deleteRecipeTitle;

  /// Body of the delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'“{title}” will be removed. This cannot be undone.'**
  String deleteRecipeBody(String title);

  /// Button and tooltip that delete a recipe
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Shown when adding a recipe to a team and the user has no editor team
  ///
  /// In en, this message translates to:
  /// **'Create or join a team as an editor first.'**
  String get createOrJoinTeam;

  /// Tooltip and dialog title for assigning a recipe to a team
  ///
  /// In en, this message translates to:
  /// **'Add to team'**
  String get addToTeam;

  /// App bar title before a recipe has loaded
  ///
  /// In en, this message translates to:
  /// **'Brew'**
  String get brewFallback;

  /// Share screen title and button
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Tooltip for taking a recipe off a team
  ///
  /// In en, this message translates to:
  /// **'Remove from team'**
  String get removeFromTeam;

  /// Tooltip for editing a recipe
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Heading of the instructions card in brew mode
  ///
  /// In en, this message translates to:
  /// **'Prep & extra steps'**
  String get prepAndExtraSteps;

  /// Shown when a recipe has no timer target
  ///
  /// In en, this message translates to:
  /// **'No extraction time recorded'**
  String get noExtractionTime;

  /// Heading of the brew timer
  ///
  /// In en, this message translates to:
  /// **'Extraction timer'**
  String get extractionTimer;

  /// The recipe's extraction time, already formatted as m:ss
  ///
  /// In en, this message translates to:
  /// **'Target {time}'**
  String targetDuration(String time);

  /// Timer mode that counts down to the target
  ///
  /// In en, this message translates to:
  /// **'Count down'**
  String get countDown;

  /// Timer mode that counts up from zero
  ///
  /// In en, this message translates to:
  /// **'Count up'**
  String get countUp;

  /// Button that silences the timer alarm
  ///
  /// In en, this message translates to:
  /// **'Stop alarm'**
  String get stopAlarm;

  /// Button that pauses the timer
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// Button that resumes the timer
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// Shown when the share card cannot be captured
  ///
  /// In en, this message translates to:
  /// **'Could not create the share image.'**
  String get couldNotCreateShareImage;

  /// Shown when downloading the share image fails
  ///
  /// In en, this message translates to:
  /// **'Could not save the image.'**
  String get couldNotSaveImage;

  /// Shown when the platform has no share sheet
  ///
  /// In en, this message translates to:
  /// **'Sharing isn\'t supported here — download the image instead'**
  String get sharingNotSupported;

  /// Button that saves the share image
  ///
  /// In en, this message translates to:
  /// **'Download image'**
  String get downloadImage;

  /// Footer of the share card
  ///
  /// In en, this message translates to:
  /// **'Made with BrewSync'**
  String get madeWithBrewSync;

  /// Share card line for method, dose, and water temperature
  ///
  /// In en, this message translates to:
  /// **'Brewing: {method} · {dose} g · {temp} °C'**
  String brewingSummary(String method, String dose, String temp);

  /// Share card line for grind size and grinder
  ///
  /// In en, this message translates to:
  /// **'Grinding: {grind} · {grinder}'**
  String grindingSummary(String grind, String grinder);

  /// Share card line for the ingredient kind and name
  ///
  /// In en, this message translates to:
  /// **'{kind}: {name}'**
  String kindAndName(String kind, String name);

  /// Share card line when more instructions are hidden
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String moreCount(int count);

  /// Share card extraction time. seconds may include a tenth, like 30.5
  ///
  /// In en, this message translates to:
  /// **'Timer: {minutes}m {seconds}s'**
  String timerSummary(String minutes, String seconds);

  /// Tooltip and dialog title for joining a team
  ///
  /// In en, this message translates to:
  /// **'Join with invite'**
  String get joinWithInvite;

  /// Button and dialog title for creating a team
  ///
  /// In en, this message translates to:
  /// **'Create team'**
  String get createTeam;

  /// Empty state of the teams list
  ///
  /// In en, this message translates to:
  /// **'No teams yet. Create one or join with an invite.'**
  String get noTeamsYet;

  /// Team list subtitle when the user owns the team
  ///
  /// In en, this message translates to:
  /// **'Owner · {role}'**
  String ownerRole(String role);

  /// Button that creates a team or invite
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Label of the join-with-invite field
  ///
  /// In en, this message translates to:
  /// **'Invite URL or token'**
  String get inviteUrlOrToken;

  /// Button that accepts an invite
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// Title of the invite sheet
  ///
  /// In en, this message translates to:
  /// **'Invite to team'**
  String get inviteToTeam;

  /// Invite expiry of one hour
  ///
  /// In en, this message translates to:
  /// **'1h'**
  String get inviteTtlOneHour;

  /// Invite expiry of one day
  ///
  /// In en, this message translates to:
  /// **'24h'**
  String get inviteTtlOneDay;

  /// Invite expiry of one week
  ///
  /// In en, this message translates to:
  /// **'7d'**
  String get inviteTtlOneWeek;

  /// Confirmation after copying an invite link
  ///
  /// In en, this message translates to:
  /// **'Invite link copied'**
  String get inviteLinkCopied;

  /// Button that copies the invite link
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyLink;

  /// Note that an invite can be used once
  ///
  /// In en, this message translates to:
  /// **'Single use'**
  String get singleUse;

  /// App bar title before the team name has loaded
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get teamFallback;

  /// Tooltip for the button that opens the invite sheet
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get invite;

  /// Empty state of a team recipe list
  ///
  /// In en, this message translates to:
  /// **'No recipes on this team yet.'**
  String get noRecipesOnTeam;

  /// Title of the invite acceptance screen
  ///
  /// In en, this message translates to:
  /// **'Team invite'**
  String get teamInvite;

  /// Confirmation after accepting an invite
  ///
  /// In en, this message translates to:
  /// **'You joined {team} as {role}.'**
  String youJoined(String team, String role);

  /// Shown when an invite token does not exist
  ///
  /// In en, this message translates to:
  /// **'Invite not found.'**
  String get inviteNotFound;

  /// Button that opens the joined team
  ///
  /// In en, this message translates to:
  /// **'Open team'**
  String get openTeam;

  /// Ingredient name length error
  ///
  /// In en, this message translates to:
  /// **'Name must be 1 to {max} characters'**
  String validationNameLength(int max);

  /// Flavor tag length error
  ///
  /// In en, this message translates to:
  /// **'A tag must be at most {max} characters'**
  String validationTagTooLong(int max);

  /// Too many flavor tags
  ///
  /// In en, this message translates to:
  /// **'At most {max} tags'**
  String validationTooManyTags(int max);

  /// Too many instructions
  ///
  /// In en, this message translates to:
  /// **'At most {max} instructions'**
  String validationTooManyInstructions(int max);

  /// Blank instruction error
  ///
  /// In en, this message translates to:
  /// **'An instruction can\'t be empty'**
  String get validationEmptyInstruction;

  /// Instruction length error
  ///
  /// In en, this message translates to:
  /// **'An instruction must be at most {max} characters'**
  String validationInstructionTooLong(int max);

  /// Wizard blocked because no ingredient is selected
  ///
  /// In en, this message translates to:
  /// **'Select or register an ingredient'**
  String get validationSelectIngredient;

  /// Wizard blocked because the title is empty
  ///
  /// In en, this message translates to:
  /// **'Add a title'**
  String get validationAddTitle;

  /// Water temperature out of range
  ///
  /// In en, this message translates to:
  /// **'Water temperature must be between {min} and {max} °C'**
  String validationWaterTemp(int min, int max);

  /// Dose out of range. min and max are already formatted numbers.
  ///
  /// In en, this message translates to:
  /// **'Dose must be between {min} and {max} g'**
  String validationDose(String min, String max);

  /// Wizard blocked because grind size is empty
  ///
  /// In en, this message translates to:
  /// **'Add a grind size'**
  String get validationAddGrindSize;

  /// Wizard blocked because the grinder is empty
  ///
  /// In en, this message translates to:
  /// **'Add a grinder model'**
  String get validationAddGrinder;

  /// Wizard blocked because no method is chosen
  ///
  /// In en, this message translates to:
  /// **'Choose an extraction method'**
  String get validationChooseMethod;

  /// Wizard blocked because Other has no description
  ///
  /// In en, this message translates to:
  /// **'Describe the extraction method'**
  String get validationDescribeMethod;

  /// Extraction duration out of range
  ///
  /// In en, this message translates to:
  /// **'Extraction time must be between 1 s and 2 h'**
  String get validationExtractionTime;

  /// Too many photos
  ///
  /// In en, this message translates to:
  /// **'At most {max} photos'**
  String validationTooManyPhotos(int max);

  /// Button that replaces the favorite recipe of the same name
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// Tooltip for saving a recipe to favorites
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// Tooltip for removing a recipe from favorites
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// Tooltip for filtering the home list to favorite recipes
  ///
  /// In en, this message translates to:
  /// **'Show favorites'**
  String get showFavorites;

  /// Tooltip for clearing the favorites filter
  ///
  /// In en, this message translates to:
  /// **'Show all recipes'**
  String get showAllRecipes;

  /// Title of the dialog shown when a favorite already uses this recipe name
  ///
  /// In en, this message translates to:
  /// **'Already in favorites'**
  String get favoriteNameTakenTitle;

  /// Body of the dialog that asks to replace the favorite with the same name
  ///
  /// In en, this message translates to:
  /// **'A recipe with this name is already in your favorites. Replace it with this one?'**
  String get favoriteNameTakenBody;

  /// Empty state title when the home list is filtered to favorites
  ///
  /// In en, this message translates to:
  /// **'No favorite recipes'**
  String get noFavoriteRecipes;

  /// Empty state detail when the home list is filtered to favorites
  ///
  /// In en, this message translates to:
  /// **'Save a recipe to keep the version you want to brew.'**
  String get noFavoriteRecipesDetail;

  /// Tooltip for filtering a team list to that team's favorites
  ///
  /// In en, this message translates to:
  /// **'Show team favorites'**
  String get showTeamFavorites;

  /// Tooltip for clearing the team favorites filter
  ///
  /// In en, this message translates to:
  /// **'Show all team recipes'**
  String get showAllTeamRecipes;

  /// Title of the dialog shown when a team favorite already uses this recipe name
  ///
  /// In en, this message translates to:
  /// **'Already in team favorites'**
  String get favoriteNameTakenTitleTeam;

  /// Body of the dialog that asks to replace the team favorite with the same name
  ///
  /// In en, this message translates to:
  /// **'A recipe with this name is already in this team\'s favorites. Replace it with this one?'**
  String get favoriteNameTakenBodyTeam;

  /// Empty state title when a team list is filtered to favorites
  ///
  /// In en, this message translates to:
  /// **'No team favorites'**
  String get noTeamFavoriteRecipes;

  /// Empty state detail when a team list is filtered to favorites
  ///
  /// In en, this message translates to:
  /// **'Editors save the version the team brews.'**
  String get noTeamFavoriteRecipesDetail;

  /// Shown when a viewer tries to change a team favorite
  ///
  /// In en, this message translates to:
  /// **'Viewers can\'t change team favorites.'**
  String get viewersCantChangeTeamFavorites;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'es':
      {
        switch (locale.countryCode) {
          case '419':
            return AppLocalizationsEs419();
        }
        break;
      }
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
