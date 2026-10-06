/// Mirrors `brewing_journal_server/lib/src/brewing/recipe_limits.dart`, so the
/// wizard rejects input the server would reject.
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
const kMinWaterTempC = 1.0;
const kMaxWaterTempC = 100.0;
const kMinDoseGrams = 0.1;
const kMaxDoseGrams = 500.0;
const kMinWaterMl = 1.0;
const kMaxWaterMl = 5000.0;
const kMaxExtractionDuration = Duration(hours: 2);
const kMaxScore = 5;
