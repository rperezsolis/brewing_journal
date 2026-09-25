import 'dart:typed_data';

import 'package:brewing_journal_client/brewing_journal_client.dart';

import 'recipe_media_repository.dart';

class ServerpodRecipeMediaRepository implements RecipeMediaRepository {
  ServerpodRecipeMediaRepository(this._endpoint);

  final EndpointRecipeMedia _endpoint;

  @override
  Future<RecipePhoto> uploadPhoto(UuidValue recipeId, ByteData bytes) async {
    final ticket = await _endpoint.createUploadDescription(recipeId);
    // A FileUploader can upload only once, so each attempt needs a new one.
    final uploaded = await FileUploader(ticket.description).uploadByteData(
      bytes,
    );
    if (!uploaded) {
      throw BrewingException(
        code: BrewingErrorCode.uploadRejected,
        message: 'The photo upload failed',
      );
    }
    return _endpoint.confirmUpload(recipeId, ticket.path);
  }

  @override
  Future<void> remove(UuidValue photoId) => _endpoint.remove(photoId);
}
