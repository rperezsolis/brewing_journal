/// Limits shared by the brewing endpoints, the validator, and the tests.
/// The Flutter app mirrors these in `ui/features/recipe_creation/recipe_limits.dart`.
library;

const kInstructionMaxLength = 280;
const kMaxInstructions = 30;
const kMaxTags = 12;
const kTagMaxLength = 40;
const kTitleMaxLength = 120;
const kGrindMaxLength = 80;
const kMaxPhotos = 6;

const kIngredientNameMaxLength = 120;
const kIngredientDetailMaxLength = 120;
const kExtractionNoteMaxLength = 280;

/// Most rows a catalog search reads before it trims to the caller's limit.
const kCatalogScanLimit = 200;

/// Team recipes inspected when collecting ingredients shared with the caller.
const kTeamRecipeScanLimit = 500;

/// Largest photo the upload description and confirm step will accept.
const kMaxPhotoBytes = 2 * 1024 * 1024;
const kMinWaterTempC = 1.0;
const kMaxWaterTempC = 100.0;
const kMinDoseGrams = 0.1;
const kMaxDoseGrams = 500.0;
const kMinExtractionDuration = Duration(seconds: 1);
const kMaxExtractionDuration = Duration(hours: 2);
const kMaxScore = 5;
