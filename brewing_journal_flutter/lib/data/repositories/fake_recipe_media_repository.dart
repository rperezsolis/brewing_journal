import 'dart:typed_data';

import 'package:brewing_journal_client/brewing_journal_client.dart';

import 'recipe_media_repository.dart';

/// In-memory [RecipeMediaRepository] for tests and previews.
class FakeRecipeMediaRepository implements RecipeMediaRepository {
  final List<RecipePhoto> photos = [];

  /// Recipe ids passed to [uploadPhoto], in call order.
  final List<UuidValue> uploadedTo = [];

  /// When set, the next call throws it once.
  Object? nextError;

  @override
  Future<RecipePhoto> uploadPhoto(UuidValue recipeId, ByteData bytes) async {
    uploadedTo.add(recipeId);
    _throwIfFailing();
    final id = const Uuid().v4();
    final photo = RecipePhoto(
      id: const Uuid().v7obj(),
      recipeId: recipeId,
      storagePath: 'recipes/${recipeId.uuid}/$id.jpg',
      sortOrder: photos.where((p) => p.recipeId == recipeId).length,
      publicUrl: Uri.parse('https://example.com/recipes/$id.jpg'),
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
