import 'package:brewing_journal_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import '../helpers/recipe_fixtures.dart';
import '../helpers/team_fixtures.dart';
import '../helpers/test_users.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given a team recipe catalog', (sessionBuilder, endpoints) {
    late TestUser owner;
    late TestUser member;
    late TestUser stranger;
    late TeamSummary team;

    setUp(() async {
      owner = await createTestUser(sessionBuilder);
      member = await createTestUser(sessionBuilder);
      stranger = await createTestUser(sessionBuilder);
      team = await createTeam(endpoints, owner);
      await inviteMember(
        endpoints,
        owner,
        member,
        team.team.id!,
        role: TeamRole.viewer,
      );
    });

    Future<RecipeDetail> shareRecipe({
      String name = 'Ethiopia Guji',
      BeverageKind kind = BeverageKind.coffee,
      String? origin,
      String? roaster,
      RoastLevel? roastLevel,
      String? processing,
      String grinderModel = 'Comandante C40',
      String title = 'Shop V60',
    }) async {
      final bean = await endpoints.ingredient.register(
        owner.sessionBuilder,
        IngredientDraft(
          kind: kind,
          name: name,
          origin: origin,
          roaster: roaster,
          roastLevel: roastLevel,
          processing: processing,
        ),
      );
      return endpoints.recipe.save(
        owner.sessionBuilder,
        sampleDraft(bean.id!).copyWith(
          teamId: team.team.id,
          title: title,
          grinderModel: grinderModel,
        ),
      );
    }

    test(
      'when a viewer searches then the team bean is included and a personal bean is not',
      () async {
        await shareRecipe();
        final kenya = await registerIngredient(
          endpoints,
          owner,
          name: 'Kenya AA',
        );
        await endpoints.recipe.save(
          owner.sessionBuilder,
          sampleDraft(kenya.id!).copyWith(
            title: 'Home Kenya',
            grinderModel: 'Niche Zero',
          ),
        );

        final visible = await endpoints.ingredient.search(
          member.sessionBuilder,
          BeverageKind.coffee,
          '',
          30,
        );
        expect(visible.map((ingredient) => ingredient.name), ['Ethiopia Guji']);

        final matcha = await endpoints.ingredient.search(
          member.sessionBuilder,
          BeverageKind.matcha,
          '',
          30,
        );
        expect(matcha, isEmpty);
      },
    );

    test(
      'when the team recipe is matcha then only matcha search returns it',
      () async {
        await shareRecipe(
          name: 'Uji Ceremonial',
          kind: BeverageKind.matcha,
          title: 'Usucha',
        );

        final coffee = await endpoints.ingredient.search(
          member.sessionBuilder,
          BeverageKind.coffee,
          'uji',
          10,
        );
        final matcha = await endpoints.ingredient.search(
          member.sessionBuilder,
          BeverageKind.matcha,
          'uji',
          10,
        );
        expect(coffee, isEmpty);
        expect(matcha.map((ingredient) => ingredient.name), ['Uji Ceremonial']);
      },
    );

    test(
      'when a member adopts a team bean then a copy is stored and a second adopt returns it',
      () async {
        final shared = await shareRecipe(
          origin: 'Yirgacheffe',
          roaster: 'Heart',
          roastLevel: RoastLevel.light,
          processing: 'Washed',
        );
        final bean = shared.ingredient;

        final copy = await endpoints.ingredient.adopt(
          member.sessionBuilder,
          bean.id!,
        );
        expect(copy.id, isNot(bean.id));
        expect(copy.ownerId, member.authUserId);
        expect(copy.origin, 'Yirgacheffe');
        expect(copy.roaster, 'Heart');
        expect(copy.roastLevel, RoastLevel.light);
        expect(copy.processing, 'Washed');

        final again = await endpoints.ingredient.adopt(
          member.sessionBuilder,
          bean.id!,
        );
        expect(again.id, copy.id);
      },
    );

    test(
      'when the member already has that name then adopt keeps their details',
      () async {
        final bean = (await shareRecipe(origin: 'Yirgacheffe')).ingredient;
        final mine = await endpoints.ingredient.register(
          member.sessionBuilder,
          IngredientDraft(
            kind: BeverageKind.coffee,
            name: 'Ethiopia Guji',
            origin: 'Mine',
          ),
        );

        final adopted = await endpoints.ingredient.adopt(
          member.sessionBuilder,
          bean.id!,
        );
        expect(adopted.id, mine.id);
        expect(adopted.origin, 'Mine');
      },
    );

    test(
      'when a stranger uses the team bean then search is empty and adopt and save are notFound',
      () async {
        final bean = (await shareRecipe()).ingredient;

        final results = await endpoints.ingredient.search(
          stranger.sessionBuilder,
          BeverageKind.coffee,
          '',
          30,
        );
        expect(results, isEmpty);
        await expectLater(
          endpoints.ingredient.adopt(stranger.sessionBuilder, bean.id!),
          throwsBrewing(BrewingErrorCode.notFound),
        );
        await expectLater(
          endpoints.recipe.save(
            member.sessionBuilder,
            sampleDraft(bean.id!),
          ),
          throwsBrewing(BrewingErrorCode.notFound),
        );

        final copy = await endpoints.ingredient.adopt(
          member.sessionBuilder,
          bean.id!,
        );
        final saved = await endpoints.recipe.save(
          member.sessionBuilder,
          sampleDraft(copy.id!).copyWith(title: 'Member V60'),
        );
        expect(saved.recipe.ingredientId, copy.id);
      },
    );

    test(
      'when listing grinders then team and own models are included and a personal model is not',
      () async {
        final older = await shareRecipe(
          grinderModel: 'Comandante C40',
          title: 'Older',
        );
        final newer = await endpoints.recipe.save(
          owner.sessionBuilder,
          sampleDraft(older.ingredient.id!).copyWith(
            teamId: team.team.id,
            title: 'Newer',
            grinderModel: 'comandante c40',
          ),
        );
        final session = sessionBuilder.build();
        final stored = await Recipe.db.findById(session, older.recipe.id!);
        await Recipe.db.updateRow(
          session,
          stored!.copyWith(updatedAt: DateTime.utc(2020)),
        );

        await endpoints.recipe.save(
          owner.sessionBuilder,
          sampleDraft(older.ingredient.id!).copyWith(
            title: 'Home only',
            grinderModel: 'Niche Zero',
          ),
        );
        final memberBean = await registerIngredient(
          endpoints,
          member,
          name: 'Member bean',
        );
        await endpoints.recipe.save(
          member.sessionBuilder,
          sampleDraft(memberBean.id!).copyWith(
            title: 'My brew',
            grinderModel: '1Zpresso JX',
          ),
        );

        final models = await endpoints.recipe.listGrinderModels(
          member.sessionBuilder,
          '',
          30,
        );
        expect(models, ['1Zpresso JX', 'comandante c40']);
        expect(newer.recipe.grinderModel, 'comandante c40');

        final prefixed = await endpoints.recipe.listGrinderModels(
          member.sessionBuilder,
          'COM',
          10,
        );
        expect(prefixed, ['comandante c40']);

        final literal = await endpoints.recipe.listGrinderModels(
          member.sessionBuilder,
          '%',
          10,
        );
        expect(literal, isEmpty);
      },
    );

    test(
      'when a recipe joins and then leaves the team then its bean and grinder follow it',
      () async {
        await shareRecipe();
        final kenya = await registerIngredient(
          endpoints,
          owner,
          name: 'Kenya AA',
        );
        final personal = await endpoints.recipe.save(
          owner.sessionBuilder,
          sampleDraft(kenya.id!).copyWith(
            title: 'Home Kenya',
            grinderModel: 'Niche Zero',
          ),
        );

        Future<List<String>> names() async {
          final results = await endpoints.ingredient.search(
            member.sessionBuilder,
            BeverageKind.coffee,
            '',
            30,
          );
          return results.map((ingredient) => ingredient.name).toList();
        }

        Future<List<String>> grinders() => endpoints.recipe.listGrinderModels(
          member.sessionBuilder,
          '',
          30,
        );

        expect(await names(), ['Ethiopia Guji']);
        expect(await grinders(), ['Comandante C40']);

        await endpoints.recipe.assignToTeam(
          owner.sessionBuilder,
          personal.recipe.id!,
          team.team.id!,
        );
        expect(await names(), ['Ethiopia Guji', 'Kenya AA']);
        expect(await grinders(), ['Comandante C40', 'Niche Zero']);

        final copy = await endpoints.ingredient.adopt(
          member.sessionBuilder,
          kenya.id!,
        );
        await endpoints.recipe.removeFromTeam(
          owner.sessionBuilder,
          personal.recipe.id!,
        );
        expect(await names(), ['Ethiopia Guji', 'Kenya AA']);
        final remaining = await endpoints.ingredient.search(
          member.sessionBuilder,
          BeverageKind.coffee,
          'kenya',
          10,
        );
        expect(remaining.single.id, copy.id);
        expect(remaining.single.ownerId, member.authUserId);
        expect(await grinders(), ['Comandante C40']);
      },
    );

    test(
      'when the bean is on another team then this member does not see it',
      () async {
        final other = await createTeam(endpoints, stranger, name: 'Other shop');
        final bean = await registerIngredient(
          endpoints,
          stranger,
          name: 'Panama Geisha',
        );
        await endpoints.recipe.save(
          stranger.sessionBuilder,
          sampleDraft(bean.id!).copyWith(
            teamId: other.team.id,
            title: 'Geisha',
            grinderModel: 'Weber EG-1',
          ),
        );

        final results = await endpoints.ingredient.search(
          member.sessionBuilder,
          BeverageKind.coffee,
          '',
          30,
        );
        expect(results, isEmpty);
        final models = await endpoints.recipe.listGrinderModels(
          member.sessionBuilder,
          '',
          30,
        );
        expect(models, isEmpty);
        await expectLater(
          endpoints.ingredient.adopt(member.sessionBuilder, bean.id!),
          throwsBrewing(BrewingErrorCode.notFound),
        );
      },
    );

    test(
      'when the personal list is longer than the limit then the team bean stays',
      () async {
        await shareRecipe(name: 'Zebra');
        await registerIngredient(endpoints, member, name: 'Alpha');
        await registerIngredient(endpoints, member, name: 'Beta');

        final results = await endpoints.ingredient.search(
          member.sessionBuilder,
          BeverageKind.coffee,
          '',
          2,
        );
        expect(results.map((ingredient) => ingredient.name), [
          'Alpha',
          'Zebra',
        ]);
      },
    );

    test(
      'when personal grinders fill the limit then the team grinder stays',
      () async {
        await shareRecipe(grinderModel: 'Zebra Mill');
        final bean = await registerIngredient(endpoints, member, name: 'Mine');
        for (final (title, model) in [
          ('Alpha brew', 'Alpha Mill'),
          ('Beta brew', 'Beta Mill'),
        ]) {
          await endpoints.recipe.save(
            member.sessionBuilder,
            sampleDraft(bean.id!).copyWith(title: title, grinderModel: model),
          );
        }

        final models = await endpoints.recipe.listGrinderModels(
          member.sessionBuilder,
          '',
          2,
        );
        expect(models, ['Alpha Mill', 'Zebra Mill']);
      },
    );

    test(
      'when the team recipe is deleted then its bean and grinder leave the catalog',
      () async {
        final shared = await shareRecipe(
          name: 'Kenya AA',
          grinderModel: 'Niche Zero',
        );
        await endpoints.recipe.delete(
          owner.sessionBuilder,
          shared.recipe.id!,
        );

        final beans = await endpoints.ingredient.search(
          member.sessionBuilder,
          BeverageKind.coffee,
          '',
          30,
        );
        expect(beans, isEmpty);
        final models = await endpoints.recipe.listGrinderModels(
          member.sessionBuilder,
          '',
          30,
        );
        expect(models, isEmpty);
      },
    );

    test(
      'when a new version uses another grinder then both models stay available',
      () async {
        final shared = await shareRecipe(grinderModel: 'Comandante C40');
        final bean = shared.ingredient;
        final source = await endpoints.recipe.listForTeam(
          owner.sessionBuilder,
          team.team.id!,
          10,
          0,
        );
        await endpoints.recipe.save(
          owner.sessionBuilder,
          sampleDraft(bean.id!).copyWith(
            id: source.single.id,
            title: 'Shop V60 v2',
            grinderModel: 'Fellow Ode',
          ),
        );

        final models = await endpoints.recipe.listGrinderModels(
          member.sessionBuilder,
          '',
          30,
        );
        expect(models, ['Comandante C40', 'Fellow Ode']);
      },
    );
  });
}
