import 'package:brewing_journal_server/src/brewing/recipe_limits.dart';
import 'package:brewing_journal_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import '../helpers/recipe_fixtures.dart';
import '../helpers/test_users.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given IngredientEndpoint', (sessionBuilder, endpoints) {
    late TestUser a;
    late TestUser b;

    setUp(() async {
      a = await createTestUser(sessionBuilder);
      b = await createTestUser(sessionBuilder);
    });

    test(
      'when searching by a prefix in another case then it matches',
      () async {
        await registerIngredient(endpoints, a, name: 'Ethiopia Guji');
        await registerIngredient(endpoints, a, name: 'Kenya AA');

        final results = await endpoints.ingredient.search(
          a.sessionBuilder,
          BeverageKind.coffee,
          'eTHi',
          10,
        );
        expect(results.map((i) => i.name), ['Ethiopia Guji']);
      },
    );

    test('when searching another kind then it does not match', () async {
      await registerIngredient(endpoints, a, name: 'Uji Ceremonial');

      final results = await endpoints.ingredient.search(
        a.sessionBuilder,
        BeverageKind.matcha,
        'uji',
        10,
      );
      expect(results, isEmpty);
    });

    test(
      'when the query has LIKE wildcards then they match literally',
      () async {
        await registerIngredient(endpoints, a, name: 'Ethiopia Guji');

        final results = await endpoints.ingredient.search(
          a.sessionBuilder,
          BeverageKind.coffee,
          '%',
          10,
        );
        expect(results, isEmpty);
      },
    );

    test(
      'when registering the same name in a different case then it returns the same id',
      () async {
        final first = await registerIngredient(endpoints, a, name: 'Kenya AA');
        final second = await registerIngredient(
          endpoints,
          a,
          name: '  kenya aa ',
        );
        expect(second.id, first.id);
      },
    );

    test('when origin is too long then validation', () async {
      await expectLater(
        endpoints.ingredient.register(
          a.sessionBuilder,
          IngredientDraft(
            kind: BeverageKind.coffee,
            name: 'Kenya',
            origin: 'a' * (kIngredientDetailMaxLength + 1),
          ),
        ),
        throwsBrewing(BrewingErrorCode.validation),
      );
    });

    test('when registering an empty name then it gives validation', () async {
      await expectLater(
        registerIngredient(endpoints, a, name: '   '),
        throwsBrewing(BrewingErrorCode.validation),
      );
    });

    test('when user B searches then user A ingredients are hidden', () async {
      await registerIngredient(endpoints, a, name: 'Ethiopia Guji');

      final results = await endpoints.ingredient.search(
        b.sessionBuilder,
        BeverageKind.coffee,
        '',
        30,
      );
      expect(results, isEmpty);
    });
  });
}
