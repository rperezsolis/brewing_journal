import 'dart:typed_data';

import 'package:brewing_journal_client/brewing_journal_client.dart';

import 'recipe_media_repository.dart';

/// In-memory [RecipeMediaRepository] for tests and previews.
class FakeRecipeMediaRepository implements RecipeMediaRepository {
  final List<RecipePhoto> photos = [];

  /// Recipe ids passed to [uploadPhoto], in call order.
  final List<UuidValue> uploadedTo = [];

  /// Content types passed to [uploadPhoto], in call order.
  final List<String> uploadedContentTypes = [];

  /// Bytes passed to [uploadPhoto], in call order.
  final List<Uint8List> uploadedBytes = [];

  /// When set, the next call throws it once.
  Object? nextError;

  @override
  Future<RecipePhoto> uploadPhoto(
    UuidValue recipeId,
    ByteData bytes, {
    String contentType = 'image/jpeg',
  }) async {
    uploadedTo.add(recipeId);
    uploadedContentTypes.add(contentType);
    uploadedBytes.add(Uint8List.sublistView(bytes));
    _throwIfFailing();
    final id = const Uuid().v4();
    final extension = switch (contentType) {
      'image/png' => 'png',
      'image/webp' => 'webp',
      _ => 'jpg',
    };
    final photo = RecipePhoto(
      id: const Uuid().v7obj(),
      recipeId: recipeId,
      storagePath: 'recipes/${recipeId.uuid}/$id.$extension',
      sortOrder: photos.where((p) => p.recipeId == recipeId).length,
      publicUrl: Uri.parse('https://example.com/recipes/$id.$extension'),
    );
    photos.add(photo);
    return photo;
  }

  @override
  Future<void> remove(UuidValue photoId) async {
    _throwIfFailing();
    photos.removeWhere((p) => p.id == photoId);
  }

  void _throwIfFailing() {
    final error = nextError;
    if (error == null) return;
    nextError = null;
    throw error;
  }
}
