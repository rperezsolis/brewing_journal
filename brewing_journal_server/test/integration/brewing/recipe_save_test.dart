import 'package:brewing_journal_server/src/brewing/recipe_limits.dart';
import 'package:brewing_journal_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import '../helpers/recipe_fixtures.dart';
import '../helpers/test_users.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given RecipeEndpoint.save', (sessionBuilder, endpoints) {
    late TestUser a;
    late Ingredient bean;

    setUp(() async {
      a = await createTestUser(sessionBuilder);
      bean = await registerIngredient(endpoints, a);
    });

    Future<RecipeDetail> save(RecipeDraft draft) =>
        endpoints.recipe.save(a.sessionBuilder, draft);

    Future<List<String>> savedInstructions(List<String> instructions) async {
      final detail = await save(
        sampleDraft(bean.id!, instructions: instructions),
      );
      return detail.instructions.map((i) => i.text).toList();
    }

    test(
      'when updating then updatedAt is refreshed and createdAt kept',
      () async {
        final inserted = await save(sampleDraft(bean.id!));
        await Future<void>.delayed(const Duration(milliseconds: 20));

        final updated = await save(
          sampleDraft(
            bean.id!,
          ).copyWith(id: inserted.recipe.id, title: 'Afternoon V60'),
        );

        expect(updated.recipe.id, inserted.recipe.id);
        expect(updated.recipe.title, 'Afternoon V60');
        expect(updated.recipe.createdAt, inserted.recipe.createdAt);
        expect(
          updated.recipe.updatedAt.isAfter(inserted.recipe.updatedAt),
          isTrue,
        );
      },
    );

    test(
      'when instructions have spaces and duplicates then they are trimmed and kept in order',
      () async {
        expect(await savedInstructions(['  stir ', 'stir']), ['stir', 'stir']);
      },
    );

    test('when an instruction has amounts then it round-trips', () async {
      expect(await savedInstructions(['use 150ml of whole milk']), [
        'use 150ml of whole milk',
      ]);
    });

    test('when an instruction is empty or blank then validation', () async {
      for (final blank in ['', '   ']) {
        await expectLater(
          savedInstructions([blank]),
          throwsBrewing(BrewingErrorCode.validation),
        );
      }
    });

    test('when an instruction is 281 characters then validation', () async {
      await expectLater(
        savedInstructions(['a' * (kInstructionMaxLength + 1)]),
        throwsBrewing(BrewingErrorCode.validation),
      );
    });

    test(
      'when an instruction is exactly 280 characters then accepted',
      () async {
        final text = 'a' * kInstructionMaxLength;
        expect(await savedInstructions([text]), [text]);
      },
    );

    test('when there are 31 instructions then validation', () async {
      await expectLater(
        savedInstructions(List.filled(kMaxInstructions + 1, 'stir')),
        throwsBrewing(BrewingErrorCode.validation),
      );
    });

    test('when saving an empty list then every row is removed', () async {
      final inserted = await save(
        sampleDraft(bean.id!, instructions: ['a', 'b']),
      );

      final updated = await save(
        sampleDraft(bean.id!).copyWith(id: inserted.recipe.id),
      );

      expect(updated.instructions, isEmpty);
      final rows = await RecipeInstruction.db.count(
        sessionBuilder.build(),
        where: (t) => t.recipeId.equals(inserted.recipe.id!),
      );
      expect(rows, 0);
    });

    test(
      'when tags differ only in case and spaces then one is stored',
      () async {
        final detail = await save(
          sampleDraft(bean.id!, flavorTags: ['Fruity', ' fruity ']),
        );
        expect(detail.flavorTags.map((t) => t.tag), ['Fruity']);
      },
    );

    test('when a tag is 41 characters then validation', () async {
      await expectLater(
        save(sampleDraft(bean.id!, flavorTags: ['a' * (kTagMaxLength + 1)])),
        throwsBrewing(BrewingErrorCode.validation),
      );
    });

    test('when using user B ingredient then notFound', () async {
      final b = await createTestUser(sessionBuilder);
      final otherBean = await registerIngredient(endpoints, b);

      await expectLater(
        save(sampleDraft(otherBean.id!)),
        throwsBrewing(BrewingErrorCode.notFound),
      );
    });

    test('when user B updates user A recipe then notFound', () async {
      final b = await createTestUser(sessionBuilder);
      final otherBean = await registerIngredient(endpoints, b);
      final inserted = await save(sampleDraft(bean.id!));

      await expectLater(
        endpoints.recipe.save(
          b.sessionBuilder,
          sampleDraft(otherBean.id!).copyWith(id: inserted.recipe.id),
        ),
        throwsBrewing(BrewingErrorCode.notFound),
      );
    });
  });
}
