import 'package:brewing_journal_server/src/brewing/recipe_storage.dart';
import 'package:brewing_journal_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import '../helpers/recipe_fixtures.dart';
import '../helpers/test_users.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given RecipeEndpoint.delete', (sessionBuilder, endpoints) {
    late TestUser a;

    setUp(() async {
      a = await createTestUser(sessionBuilder);
    });

    test('when the owner deletes then child rows and files are gone', () async {
      final bean = await registerIngredient(endpoints, a);
      final saved = await endpoints.recipe.save(
        a.sessionBuilder,
        sampleDraft(bean.id!, instructions: ['stir'], flavorTags: ['fruity']),
      );
      final id = saved.recipe.id!;
      final ticket = await endpoints.recipeMedia.createUploadDescription(
        a.sessionBuilder,
        id,
      );
      final session = sessionBuilder.build();
      await session.storage.storeFile(
        storageId: kPhotoStorageId,
        path: ticket.path,
        byteData: jpegPhotoBytes(),
      );
      await endpoints.recipeMedia.confirmUpload(
        a.sessionBuilder,
        id,
        ticket.path,
      );

      await endpoints.recipe.delete(a.sessionBuilder, id);

      expect(await Recipe.db.findById(session, id), isNull);
      expect(
        await RecipeInstruction.db.count(
          session,
          where: (t) => t.recipeId.equals(id),
        ),
        0,
      );
      expect(
        await RecipeFlavorTag.db.count(
          session,
          where: (t) => t.recipeId.equals(id),
        ),
        0,
      );
      expect(
        await RecipePhoto.db.count(
          session,
          where: (t) => t.recipeId.equals(id),
        ),
        0,
      );
      expect(
        await session.storage.fileExists(
          storageId: kPhotoStorageId,
          path: ticket.path,
        ),
        isFalse,
      );
      expect(await Ingredient.db.findById(session, bean.id!), isNotNull);
    });

    test('when user B deletes then notFound and the recipe stays', () async {
      final saved = await createRecipe(endpoints, a);
      final b = await createTestUser(sessionBuilder);

      await expectLater(
        endpoints.recipe.delete(b.sessionBuilder, saved.recipe.id!),
        throwsBrewing(BrewingErrorCode.notFound),
      );
      expect(
        await Recipe.db.findById(sessionBuilder.build(), saved.recipe.id!),
        isNotNull,
      );
    });
  });
}
