import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Every recipe photo lives in the `public` storage.
const kPhotoStorageId = 'public';

/// Fills [RecipePhoto.publicUrl] for each photo. A photo whose file is missing
/// gets `null` instead of failing the whole read.
Future<List<RecipePhoto>> withPublicUrls(
  Session session,
  List<RecipePhoto> photos,
) async {
  if (photos.isEmpty) return photos;
  final urls = await session.storage.publicDownloadUrls(
    storageId: kPhotoStorageId,
    paths: [for (final photo in photos) photo.storagePath],
  );
  return [
    for (var i = 0; i < photos.length; i++)
      photos[i].copyWith(publicUrl: urls[i]),
  ];
}

/// Copies every photo of [fromRecipeId] into new files for [toRecipeId].
///
/// The source rows are not changed. The returned rows are not inserted; the
/// caller inserts them after the destination recipe exists. Files already
/// stored are deleted if a later copy fails.
Future<List<RecipePhoto>> copyRecipePhotos(
  Session session, {
  required UuidValue fromRecipeId,
  required UuidValue toRecipeId,
}) async {
  final photos = await RecipePhoto.db.find(
    session,
    where: (t) => t.recipeId.equals(fromRecipeId),
    orderBy: (t) => t.sortOrder,
  );
  final copies = <RecipePhoto>[];
  final stored = <String>[];
  try {
    for (final photo in photos) {
      final bytes = await session.storage.retrieveFile(
        storageId: kPhotoStorageId,
        path: photo.storagePath,
      );
      final path = 'recipes/${toRecipeId.uuid}/${const Uuid().v4()}.jpg';
      await session.storage.storeFile(
        storageId: kPhotoStorageId,
        path: path,
        byteData: bytes,
        options: const StoreFileOptions(
          preventOverwrite: true,
          metadata: FileMetadata(contentType: 'image/jpeg'),
        ),
      );
      stored.add(path);
      copies.add(
        RecipePhoto(
          recipeId: toRecipeId,
          storagePath: path,
          sortOrder: photo.sortOrder,
        ),
      );
    }
  } catch (error) {
    await deletePhotoFiles(session, stored);
    rethrow;
  }
  return copies;
}

/// Deletes stored photo files after their rows are gone. Failures are logged,
/// not thrown: the rows are already committed, so an orphaned file is the
/// only possible leftover.
Future<void> deletePhotoFiles(Session session, Iterable<String> paths) async {
  for (final path in paths) {
    try {
      await session.storage.deleteFile(storageId: kPhotoStorageId, path: path);
    } catch (error, stackTrace) {
      session.log(
        'Failed to delete photo file $path',
        level: LogLevel.warning,
        exception: error,
        stackTrace: stackTrace,
      );
    }
  }
}
