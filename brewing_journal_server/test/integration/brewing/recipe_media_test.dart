import 'dart:typed_data';

import 'package:brewing_journal_server/src/brewing/recipe_limits.dart';
import 'package:brewing_journal_server/src/brewing/recipe_storage.dart';
import 'package:brewing_journal_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../helpers/recipe_fixtures.dart';
import '../helpers/test_users.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given RecipeMediaEndpoint', (sessionBuilder, endpoints) {
    late TestUser a;
    late UuidValue recipeId;

    setUp(() async {
      a = await createTestUser(sessionBuilder);
      recipeId = (await createRecipe(endpoints, a)).recipe.id!;
    });

    Future<void> storeFile(String path) =>
        sessionBuilder.build().storage.storeFile(
          storageId: kPhotoStorageId,
          path: path,
          byteData: jpegPhotoBytes(),
        );

    Future<RecipePhoto> upload() async {
      final ticket = await endpoints.recipeMedia.createUploadDescription(
        a.sessionBuilder,
        recipeId,
      );
      await storeFile(ticket.path);
      return endpoints.recipeMedia.confirmUpload(
        a.sessionBuilder,
        recipeId,
        ticket.path,
      );
    }

    test('when uploading then the path is server-chosen', () async {
      final ticket = await endpoints.recipeMedia.createUploadDescription(
        a.sessionBuilder,
        recipeId,
      );
      expect(
        ticket.path,
        matches(RegExp('^recipes/${recipeId.uuid}/[0-9a-f-]{36}\\.jpg\$')),
      );
      expect(ticket.description, isNotEmpty);
    });

    test(
      'when confirming an upload then a row with a publicUrl is returned',
      () async {
        final photo = await upload();

        expect(photo.id, isNotNull);
        expect(photo.recipeId, recipeId);
        expect(photo.sortOrder, 0);
        expect(photo.publicUrl.toString(), contains('temporaryFile'));

        final detail = await endpoints.recipe.get(a.sessionBuilder, recipeId);
        expect(
          detail.photos.single.publicUrl.toString(),
          contains('temporaryFile'),
        );
      },
    );

    test(
      'when confirming the same path twice then the same row is returned',
      () async {
        final ticket = await endpoints.recipeMedia.createUploadDescription(
          a.sessionBuilder,
          recipeId,
        );
        await storeFile(ticket.path);

        final first = await endpoints.recipeMedia.confirmUpload(
          a.sessionBuilder,
          recipeId,
          ticket.path,
        );
        final second = await endpoints.recipeMedia.confirmUpload(
          a.sessionBuilder,
          recipeId,
          ticket.path,
        );
        expect(second.id, first.id);
      },
    );

    test('when uploading twice then sortOrder increments', () async {
      final first = await upload();
      final second = await upload();
      expect([first.sortOrder, second.sortOrder], [0, 1]);
    });

    test('when confirming a forged path then validation', () async {
      final other = (await createRecipe(endpoints, a)).recipe.id!;
      final forged = [
        'recipes/${other.uuid}/${const Uuid().v4()}.jpg',
        'recipes/${recipeId.uuid}/../secret.jpg',
        'recipes/${recipeId.uuid}/${const Uuid().v4()}.png',
      ];
      for (final path in forged) {
        await expectLater(
          endpoints.recipeMedia.confirmUpload(a.sessionBuilder, recipeId, path),
          throwsBrewing(BrewingErrorCode.validation),
        );
      }
    });

    test(
      'when confirming without an upload then uploadRejected and no row',
      () async {
        final ticket = await endpoints.recipeMedia.createUploadDescription(
          a.sessionBuilder,
          recipeId,
        );

        await expectLater(
          endpoints.recipeMedia.confirmUpload(
            a.sessionBuilder,
            recipeId,
            ticket.path,
          ),
          throwsBrewing(BrewingErrorCode.uploadRejected),
        );
        final rows = await RecipePhoto.db.count(
          sessionBuilder.build(),
          where: (t) => t.recipeId.equals(recipeId),
        );
        expect(rows, 0);
      },
    );

    test(
      'when the recipe has 6 photos then the 7th description gives validation',
      () async {
        await RecipePhoto.db.insert(sessionBuilder.build(), [
          for (var i = 0; i < kMaxPhotos; i++)
            RecipePhoto(
              recipeId: recipeId,
              storagePath: 'recipes/${recipeId.uuid}/${const Uuid().v4()}.jpg',
              sortOrder: i,
            ),
        ]);

        await expectLater(
          endpoints.recipeMedia.createUploadDescription(
            a.sessionBuilder,
            recipeId,
          ),
          throwsBrewing(BrewingErrorCode.validation),
        );
      },
    );

    test('when user B asks for an upload description then notFound', () async {
      final b = await createTestUser(sessionBuilder);
      await expectLater(
        endpoints.recipeMedia.createUploadDescription(
          b.sessionBuilder,
          recipeId,
        ),
        throwsBrewing(BrewingErrorCode.notFound),
      );
    });

    test(
      'when the owner removes a photo then the row and file are gone',
      () async {
        final photo = await upload();

        await endpoints.recipeMedia.remove(a.sessionBuilder, photo.id!);

        final session = sessionBuilder.build();
        expect(await RecipePhoto.db.findById(session, photo.id!), isNull);
        expect(
          await session.storage.fileExists(
            storageId: kPhotoStorageId,
            path: photo.storagePath,
          ),
          isFalse,
        );
      },
    );

    test(
      'when the file is not a jpeg then validation and it is removed',
      () async {
        final ticket = await endpoints.recipeMedia.createUploadDescription(
          a.sessionBuilder,
          recipeId,
        );
        final session = sessionBuilder.build();
        await session.storage.storeFile(
          storageId: kPhotoStorageId,
          path: ticket.path,
          byteData: ByteData.sublistView(Uint8List.fromList([1, 2, 3, 4])),
        );

        await expectLater(
          endpoints.recipeMedia.confirmUpload(
            a.sessionBuilder,
            recipeId,
            ticket.path,
          ),
          throwsBrewing(BrewingErrorCode.validation),
        );
        expect(
          await session.storage.fileExists(
            storageId: kPhotoStorageId,
            path: ticket.path,
          ),
          isFalse,
        );
      },
    );

    test('when user B removes a photo then notFound', () async {
      final photo = await upload();
      final b = await createTestUser(sessionBuilder);

      await expectLater(
        endpoints.recipeMedia.remove(b.sessionBuilder, photo.id!),
        throwsBrewing(BrewingErrorCode.notFound),
      );
    });
  });
}
