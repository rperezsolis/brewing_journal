import 'dart:typed_data';

import 'package:brewing_journal_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../test_tools/serverpod_test_tools.dart';
import 'test_users.dart';

/// Smallest byte sequence confirmUpload accepts as a JPEG.
ByteData jpegPhotoBytes() =>
    ByteData.sublistView(Uint8List.fromList(const [0xFF, 0xD8, 0xFF]));

Matcher throwsBrewing(BrewingErrorCode code) =>
    throwsA(isA<BrewingException>().having((e) => e.code, 'code', code));

Future<Ingredient> registerIngredient(
  TestEndpoints endpoints,
  TestUser user, {
  String name = 'Ethiopia Guji',
  BeverageKind kind = BeverageKind.coffee,
}) => endpoints.ingredient.register(
  user.sessionBuilder,
  IngredientDraft(kind: kind, name: name),
);

/// A valid V60 draft; override fields with `copyWith`.
RecipeDraft sampleDraft(
  UuidValue ingredientId, {
  List<String> instructions = const [],
  List<String> flavorTags = const [],
}) => RecipeDraft(
  ingredientId: ingredientId,
  title: 'Morning V60',
  waterTempC: 93,
  doseGrams: 15,
  waterMl: 250,
  grindSize: 'Medium-fine',
  grinderModel: 'Comandante C40',
  extractionMethod: ExtractionMethod.v60,
  extractionDuration: const Duration(minutes: 3),
  acidity: 3,
  sweetness: 4,
  body: 2,
  bitterness: 1,
  flavorTags: flavorTags,
  instructions: instructions,
);

/// Registers an ingredient for [user] and saves [sampleDraft] with it.
Future<RecipeDetail> createRecipe(
  TestEndpoints endpoints,
  TestUser user, {
  List<String> instructions = const [],
  String title = 'Morning V60',
}) async {
  final ingredient = await registerIngredient(endpoints, user);
  return endpoints.recipe.save(
    user.sessionBuilder,
    sampleDraft(ingredient.id!, instructions: instructions).copyWith(
      title: title,
    ),
  );
}
