import 'package:serverpod/serverpod.dart';

import '../common/authenticated_endpoint.dart';
import '../generated/protocol.dart';
import 'recipe_access_policy.dart';
import 'recipe_limits.dart';
import 'recipe_storage.dart';
import 'recipe_validator.dart';

/// Photo uploads: the server picks the storage path, the client uploads to
/// it, and a row is written only after the upload is verified.
class RecipeMediaEndpoint extends AuthenticatedEndpoint {
  Future<UploadTicket> createUploadDescription(
    Session session,
    UuidValue recipeId,
  ) async {
    await RecipeAccessPolicy.loadForEdit(session, recipeId);
    final count = await RecipePhoto.db.count(
      session,
      where: (t) => t.recipeId.equals(recipeId),
    );
    if (count >= kMaxPhotos) {
      throw validationError('photos', 'at most $kMaxPhotos photos');
    }

    // A v4 (not v7) UUID, so public URLs carry no timestamp.
    final path = 'recipes/${recipeId.uuid}/${const Uuid().v4()}.jpg';
    final description = await session.storage.createUploadDescription(
      storageId: kPhotoStorageId,
      path: path,
      options: const UploadOptions(
        preventOverwrite: true,
        maxFileSize: kMaxPhotoBytes,
        metadata: FileMetadata(contentType: 'image/jpeg'),
      ),
    );
    return UploadTicket(path: path, description: description);
  }

  /// Verifies the upload at [path] and attaches it to the recipe. Calling it
  /// again for the same path returns the same row.
  Future<RecipePhoto> confirmUpload(
    Session session,
    UuidValue recipeId,
    String path,
  ) async {
    await RecipeAccessPolicy.loadForEdit(session, recipeId);
    final pathPattern = RegExp(
      '^recipes/${RegExp.escape(recipeId.uuid)}/[0-9a-f-]{36}\\.jpg\$',
    );
    if (!pathPattern.hasMatch(path)) {
      throw validationError('path', 'is not a valid upload path');
    }

    final existing = await _findByPath(session, path);
    if (existing != null) return _withUrl(session, existing);

    // `verifyUpload` is false for a file that is already verified (a retry
    // after a failed insert, or `storeFile` in tests), so accept an existing
    // verified file as well.
    final verified =
        await session.storage.verifyUpload(
          storageId: kPhotoStorageId,
          path: path,
        ) ||
        await session.storage.fileExists(
          storageId: kPhotoStorageId,
          path: path,
        );
    if (!verified) {
      throw BrewingException(
        code: BrewingErrorCode.uploadRejected,
        message: 'The photo could not be verified',
      );
    }
    await _requireJpeg(session, path);

    for (var attempt = 0; ; attempt++) {
      try {
        final photo = await session.db.transaction(
          (tx) => _insertNext(session, recipeId, path, tx),
        );
        return await _withUrl(session, photo);
      } on DatabaseUniqueViolationException {
        final raced = await _findByPath(session, path);
        if (raced != null) return _withUrl(session, raced);
        if (attempt >= 1) rethrow;
      }
    }
  }

  Future<void> remove(Session session, UuidValue photoId) async {
    final photo = await RecipePhoto.db.findById(session, photoId);
    if (photo == null) throw recipeNotFound();
    await RecipeAccessPolicy.loadForEdit(session, photo.recipeId);
    await RecipePhoto.db.deleteRow(session, photo);
    await deletePhotoFiles(session, [photo.storagePath]);
  }

  Future<RecipePhoto> _insertNext(
    Session session,
    UuidValue recipeId,
    String path,
    Transaction tx,
  ) async {
    final photos = await RecipePhoto.db.find(
      session,
      where: (t) => t.recipeId.equals(recipeId),
      transaction: tx,
    );
    if (photos.length >= kMaxPhotos) {
      throw validationError('photos', 'at most $kMaxPhotos photos');
    }
    final maxOrder = photos.fold(
      -1,
      (max, p) => p.sortOrder > max ? p.sortOrder : max,
    );
    return RecipePhoto.db.insertRow(
      session,
      RecipePhoto(
        recipeId: recipeId,
        storagePath: path,
        sortOrder: maxOrder + 1,
      ),
      transaction: tx,
    );
  }

  Future<RecipePhoto?> _findByPath(Session session, String path) =>
      RecipePhoto.db.findFirstRow(
        session,
        where: (t) => t.storagePath.equals(path),
      );

  Future<RecipePhoto> _withUrl(Session session, RecipePhoto photo) async =>
      (await withPublicUrls(session, [photo])).single;
}

/// JPEG files start with the SOI marker and the next marker byte.
Future<void> _requireJpeg(Session session, String path) async {
  final stat = await session.storage.statFile(
    storageId: kPhotoStorageId,
    path: path,
  );
  final bytes = await session.storage.retrieveFile(
    storageId: kPhotoStorageId,
    path: path,
  );
  final header = bytes.buffer.asUint8List(
    bytes.offsetInBytes,
    bytes.lengthInBytes,
  );
  final isJpeg =
      stat.size <= kMaxPhotoBytes &&
      header.length >= 3 &&
      header[0] == 0xFF &&
      header[1] == 0xD8 &&
      header[2] == 0xFF;
  if (isJpeg) return;
  await deletePhotoFiles(session, [path]);
  throw validationError('path', 'must be a JPEG image of at most 2 MB');
}
