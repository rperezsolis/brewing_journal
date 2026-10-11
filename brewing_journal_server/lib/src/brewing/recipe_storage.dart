import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'photo_format.dart';

/// Every recipe photo lives in the private storage.
///
/// Download links are short-lived and issued only after the caller is allowed
/// to read the recipe. A public URL would keep working after that access ends.
const kPhotoStorageId = 'private';

const _photoUrlTtl = Duration(minutes: 15);

/// Fills [RecipePhoto.publicUrl] with a temporary download URL. A photo whose
/// file is missing gets `null` instead of failing the whole read.
Future<List<RecipePhoto>> withPublicUrls(
  Session session,
  List<RecipePhoto> photos,
) async {
  if (photos.isEmpty) return photos;
  final urls = <Uri?>[];
  for (final photo in photos) {
    try {
      urls.add(
        await session.storage.temporaryDownloadUrl(
          storageId: kPhotoStorageId,
          path: photo.storagePath,
          options: const TemporaryDownloadUrlOptions(
            expirationDuration: _photoUrlTtl,
          ),
        ),
      );
    } on CloudStorageException {
      urls.add(null);
    }
  }
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
      final extension = photoExtension(photo.storagePath) ?? 'jpg';
      final path = 'recipes/${toRecipeId.uuid}/${const Uuid().v4()}.$extension';
      await session.storage.storeFile(
        storageId: kPhotoStorageId,
        path: path,
        byteData: bytes,
        options: StoreFileOptions(
          preventOverwrite: true,
          metadata: FileMetadata(
            contentType: contentTypeForPhotoExtension(extension),
          ),
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
