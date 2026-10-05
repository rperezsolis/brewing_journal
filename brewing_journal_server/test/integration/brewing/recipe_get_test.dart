import 'package:brewing_journal_server/src/brewing/recipe_storage.dart';
import 'package:brewing_journal_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import '../helpers/recipe_fixtures.dart';
import '../helpers/test_users.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given RecipeEndpoint.get', (sessionBuilder, endpoints) {
    late TestUser a;

    setUp(() async {
      a = await createTestUser(sessionBuilder);
    });

    test('when reading then instructions come back in sortOrder', () async {
      final saved = await createRecipe(
        endpoints,
        a,
        instructions: ['grind', 'bloom', 'pour', 'stir'],
      );

      final detail = await endpoints.recipe.get(
        a.sessionBuilder,
        saved.recipe.id!,
      );

      expect(detail.instructions.map((i) => i.text), [
        'grind',
        'bloom',
        'pour',
        'stir',
      ]);
      expect(detail.instructions.map((i) => i.sortOrder), [0, 1, 2, 3]);
      expect(detail.ingredient.id, saved.recipe.ingredientId);
    });

    test('when the owner reads then access allows edit and delete', () async {
      final saved = await createRecipe(endpoints, a);

      final detail = await endpoints.recipe.get(
        a.sessionBuilder,
        saved.recipe.id!,
      );
      final access = await endpoints.recipe.getAccess(
        a.sessionBuilder,
        saved.recipe.id!,
      );

      expect(detail.access.canEdit, isTrue);
      expect(detail.access.canDelete, isTrue);
      expect(access.canEdit, isTrue);
      expect(access.canDelete, isTrue);
    });

    test('when user B reads user A recipe then notFound', () async {
      final saved = await createRecipe(endpoints, a);
      final b = await createTestUser(sessionBuilder);

      await expectLater(
        endpoints.recipe.get(b.sessionBuilder, saved.recipe.id!),
        throwsBrewing(BrewingErrorCode.notFound),
      );
      await expectLater(
        endpoints.recipe.getAccess(b.sessionBuilder, saved.recipe.id!),
        throwsBrewing(BrewingErrorCode.notFound),
      );
    });

    test(
      'when extractionDuration was not recorded then get returns null, not zero',
      () async {
        final ingredient = await registerIngredient(endpoints, a);
        final saved = await endpoints.recipe.save(
          a.sessionBuilder,
          sampleDraft(ingredient.id!).copyWith(extractionDuration: null),
        );

        expect(saved.recipe.extractionDuration, isNull);

        final detail = await endpoints.recipe.get(
          a.sessionBuilder,
          saved.recipe.id!,
        );
        expect(detail.recipe.extractionDuration, isNull);
      },
    );

    test(
      'when there are no instructions then get returns an empty list',
      () async {
        final saved = await createRecipe(endpoints, a);

        final detail = await endpoints.recipe.get(
          a.sessionBuilder,
          saved.recipe.id!,
        );
        expect(detail.instructions, isEmpty);
      },
    );

    test('when there are no photos then get returns an empty list', () async {
      final saved = await createRecipe(endpoints, a);

      final detail = await endpoints.recipe.get(
        a.sessionBuilder,
        saved.recipe.id!,
      );
      expect(detail.photos, isEmpty);
    });

    test('when photos exist then every photo has a publicUrl', () async {
      final saved = await createRecipe(endpoints, a);
      final recipeId = saved.recipe.id!;
      final session = a.sessionBuilder.build();

      for (var i = 0; i < 2; i++) {
        final ticket = await endpoints.recipeMedia.createUploadDescription(
          a.sessionBuilder,
          recipeId,
        );
        await session.storage.storeFile(
          storageId: kPhotoStorageId,
          path: ticket.path,
          byteData: jpegPhotoBytes(),
        );
        await endpoints.recipeMedia.confirmUpload(
          a.sessionBuilder,
          recipeId,
          ticket.path,
        );
      }

      final detail = await endpoints.recipe.get(a.sessionBuilder, recipeId);
      expect(detail.photos, hasLength(2));
      for (final photo in detail.photos) {
        expect(photo.publicUrl, isNotNull);
      }
    });
  });
}
