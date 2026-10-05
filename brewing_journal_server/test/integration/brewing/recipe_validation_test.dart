import 'package:brewing_journal_server/src/brewing/recipe_limits.dart';
import 'package:brewing_journal_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import '../helpers/recipe_fixtures.dart';
import '../helpers/test_users.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given RecipeEndpoint.save validation', (
    sessionBuilder,
    endpoints,
  ) {
    late TestUser a;
    late RecipeDraft valid;

    setUp(() async {
      a = await createTestUser(sessionBuilder);
      final bean = await registerIngredient(endpoints, a);
      valid = sampleDraft(bean.id!);
    });

    final invalid = <String, RecipeDraft Function(RecipeDraft)>{
      'temperature 0': (d) => d.copyWith(waterTempC: 0),
      'temperature 101': (d) => d.copyWith(waterTempC: 101),
      'dose 0': (d) => d.copyWith(doseGrams: 0),
      'dose 501': (d) => d.copyWith(doseGrams: 501),
      'duration 0s': (d) => d.copyWith(extractionDuration: Duration.zero),
      'duration 2h1s': (d) => d.copyWith(
        extractionDuration: const Duration(hours: 2, seconds: 1),
      ),
      'score -1': (d) => d.copyWith(acidity: -1),
      'score 6': (d) => d.copyWith(bitterness: 6),
      'method other with no note': (d) =>
          d.copyWith(extractionMethod: ExtractionMethod.other),
      'method other with a blank note': (d) => d.copyWith(
        extractionMethod: ExtractionMethod.other,
        extractionMethodNote: '  ',
      ),
      '13 tags': (d) => d.copyWith(
        flavorTags: [for (var i = 0; i <= kMaxTags; i++) 'tag $i'],
      ),
      'title of 121 characters': (d) =>
          d.copyWith(title: 'a' * (kTitleMaxLength + 1)),
      'blank title': (d) => d.copyWith(title: '  '),
      'grind size of 81 characters': (d) =>
          d.copyWith(grindSize: 'a' * (kGrindMaxLength + 1)),
      'blank grinder model': (d) => d.copyWith(grinderModel: ''),
      'note of 281 characters': (d) => d.copyWith(
        extractionMethodNote: 'a' * (kExtractionNoteMaxLength + 1),
      ),
    };

    for (final MapEntry(key: name, value: change) in invalid.entries) {
      test('when $name then validation', () async {
        await expectLater(
          endpoints.recipe.save(a.sessionBuilder, change(valid)),
          throwsBrewing(BrewingErrorCode.validation),
        );
      });
    }

    final boundaries = <String, RecipeDraft Function(RecipeDraft)>{
      'temperature 1 and dose 0.1': (d) =>
          d.copyWith(waterTempC: 1, doseGrams: 0.1),
      'temperature 100 and dose 500': (d) =>
          d.copyWith(waterTempC: 100, doseGrams: 500),
      'duration 1s': (d) =>
          d.copyWith(extractionDuration: const Duration(seconds: 1)),
      'duration 2h': (d) =>
          d.copyWith(extractionDuration: const Duration(hours: 2)),
      'no duration': (d) => d.copyWith(extractionDuration: null),
      'scores 0 and 5': (d) => d.copyWith(acidity: 0, sweetness: 5),
      'method other with a note': (d) => d.copyWith(
        extractionMethod: ExtractionMethod.other,
        extractionMethodNote: 'Clever dripper',
      ),
      '12 tags': (d) =>
          d.copyWith(flavorTags: [for (var i = 0; i < kMaxTags; i++) 'tag $i']),
      'title of 120 characters': (d) =>
          d.copyWith(title: 'a' * kTitleMaxLength),
      'note of 280 characters': (d) => d.copyWith(
        extractionMethodNote: 'a' * kExtractionNoteMaxLength,
      ),
    };

    for (final MapEntry(key: name, value: change) in boundaries.entries) {
      test('when $name then accepted', () async {
        final detail = await endpoints.recipe.save(
          a.sessionBuilder,
          change(valid),
        );
        expect(detail.recipe.id, isNotNull);
      });
    }

    test('when no duration is sent then it is stored as null', () async {
      final detail = await endpoints.recipe.save(
        a.sessionBuilder,
        valid.copyWith(extractionDuration: null),
      );
      expect(detail.recipe.extractionDuration, isNull);
    });
  });
}
