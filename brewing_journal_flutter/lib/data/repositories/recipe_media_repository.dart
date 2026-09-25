import 'dart:typed_data';

import 'package:brewing_journal_client/brewing_journal_client.dart';

abstract class RecipeMediaRepository {
  /// Uploads JPEG [bytes] and attaches them to the recipe. Throws a
  /// [BrewingException] with `uploadRejected` when the upload fails
  /// verification.
  Future<RecipePhoto> uploadPhoto(UuidValue recipeId, ByteData bytes);

  Future<void> remove(UuidValue photoId);
}
