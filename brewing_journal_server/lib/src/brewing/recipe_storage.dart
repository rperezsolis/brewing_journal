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
