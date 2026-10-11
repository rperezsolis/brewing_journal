import 'dart:typed_data';

import 'package:brewing_journal_client/brewing_journal_client.dart';

abstract class RecipeMediaRepository {
  /// Uploads [bytes] and attaches them to the recipe. [contentType] is
  /// `image/jpeg`, `image/png`, or `image/webp`. Throws a [BrewingException]
  /// with `uploadRejected` when the upload fails verification.
  Future<RecipePhoto> uploadPhoto(
    UuidValue recipeId,
    ByteData bytes, {
    String contentType = 'image/jpeg',
  });

  Future<void> remove(UuidValue photoId);
}
