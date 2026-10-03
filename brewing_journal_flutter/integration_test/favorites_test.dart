import 'package:brewing_journal_flutter/ui/features/brew_mode/view/brew_mode_screen.dart';
import 'package:brewing_journal_flutter/ui/features/recipe_list/view/recipe_list_screen.dart';
import 'package:brewing_journal_flutter/ui/features/teams/view/team_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/auth_harness.dart';
import 'support/recipe_harness.dart';
import 'support/team_harness.dart';

/// Feature 6 against the development server (`serverpod start`).
///
/// US-6.1 one favorite per recipe name, US-6.2 hearts on the tile and in
/// Brew Mode, US-6.3 close, Cancel, and Accept on the replace dialog,
/// US-6.4 the home filter, US-6.5 a viewer's favorite stays off the owner's
/// team list and off the viewer's home filter.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final auth = AuthHarness();
  final recipes = RecipeHarness(auth);
  final teams = TeamHarness(recipes);
  tearDownAll(() async {
    await recipes.close();
    await auth.close();
  });

  group('Feature 6 — Favorites', () {
    testWidgets(
      'US-6.1 through US-6.4 keeps one winning version and filters the journal',
      (tester) async {
        await recipes.signUpFresh(tester);
        final stamp = DateTime.now().millisecondsSinceEpoch;
        final title = 'Trial V60 $stamp';
        final firstBean = 'First lot $stamp';
        final secondBean = 'Second lot $stamp';

        await _saveRecipe(tester, recipes, title: title, bean: firstBean);
        await recipes.backToJournal(tester);
        await _saveRecipe(tester, recipes, title: title, bean: secondBean);
        await recipes.backToJournal(tester);

        await recipes.setHomeFavoritesOnly(tester, true);
        await recipes.expectHomeMessage(tester, recipes.l10n.noFavoriteRecipes);
        expect(find.text(title).hitTestable(), findsNothing);
        await recipes.setHomeFavoritesOnly(tester, false);
        await recipes.expectTileFavorite(
          tester,
          scope: RecipeListScreen,
          marker: firstBean,
          selected: false,
        );
        await recipes.expectTileFavorite(
          tester,
          scope: RecipeListScreen,
          marker: secondBean,
          selected: false,
        );

        await recipes.tapTileFavorite(
          tester,
          scope: RecipeListScreen,
          marker: firstBean,
        );
        await recipes.expectTileFavorite(
          tester,
          scope: RecipeListScreen,
          marker: firstBean,
          selected: true,
        );
        expect(find.byType(BrewModeScreen), findsNothing);

        await recipes.tapTileFavorite(
          tester,
          scope: RecipeListScreen,
          marker: secondBean,
        );
        await recipes.expectReplaceFavoriteDialog(tester);
        await recipes.closeReplaceFavoriteDialog(tester);
        await recipes.expectTileFavorite(
          tester,
          scope: RecipeListScreen,
          marker: firstBean,
          selected: true,
        );
        await recipes.expectTileFavorite(
          tester,
          scope: RecipeListScreen,
          marker: secondBean,
          selected: false,
        );

        await recipes.tapTileFavorite(
          tester,
          scope: RecipeListScreen,
          marker: secondBean,
        );
        await recipes.expectReplaceFavoriteDialog(tester);
        await recipes.cancelReplaceFavoriteDialog(tester);
        await recipes.expectTileFavorite(
          tester,
          scope: RecipeListScreen,
          marker: firstBean,
          selected: true,
        );
        await recipes.expectTileFavorite(
          tester,
          scope: RecipeListScreen,
          marker: secondBean,
          selected: false,
        );

        await recipes.tapTileFavorite(
          tester,
          scope: RecipeListScreen,
          marker: secondBean,
        );
        await recipes.expectReplaceFavoriteDialog(tester);
        await recipes.acceptReplaceFavoriteDialog(tester);
        await recipes.expectTileFavorite(
          tester,
          scope: RecipeListScreen,
          marker: secondBean,
          selected: true,
        );
        await recipes.expectTileFavorite(
          tester,
          scope: RecipeListScreen,
          marker: firstBean,
          selected: false,
        );

        await recipes.setHomeFavoritesOnly(tester, true);
        await recipes.expectTileFavorite(
          tester,
          scope: RecipeListScreen,
          marker: secondBean,
          selected: true,
        );
        expect(find.textContaining(firstBean).hitTestable(), findsNothing);
        await recipes.setHomeFavoritesOnly(tester, false);
        await recipes.expectTileFavorite(
          tester,
          scope: RecipeListScreen,
          marker: firstBean,
          selected: false,
        );
        await recipes.expectTileFavorite(
          tester,
          scope: RecipeListScreen,
          marker: secondBean,
          selected: true,
        );

        // The list is newest first, so the title tap opens the second recipe.
        await recipes.openRecipe(tester, title);
        await recipes.expectBrewText(tester, secondBean);
        await recipes.expectBrewFavorite(tester, selected: true);
        await recipes.toggleBrewFavorite(tester);
        await recipes.backToJournal(tester);
        await recipes.expectTileFavorite(
          tester,
          scope: RecipeListScreen,
          marker: secondBean,
          selected: false,
        );

        await recipes.openRecipe(tester, title);
        await recipes.expectBrewText(tester, secondBean);
        await recipes.expectBrewFavorite(tester, selected: false);
        await recipes.toggleBrewFavorite(tester);
        await recipes.backToJournal(tester);
        await recipes.expectTileFavorite(
          tester,
          scope: RecipeListScreen,
          marker: secondBean,
          selected: true,
        );
        await recipes.expectTileFavorite(
          tester,
          scope: RecipeListScreen,
          marker: firstBean,
          selected: false,
        );
      },
      timeout: const Timeout(Duration(minutes: 8)),
    );

    testWidgets(
      'US-6.5 a viewer favorite stays off the owner list and the viewer journal',
      (tester) async {
        await recipes.signUpFresh(tester);
        final ownerEmail = auth.accountEmail!;
        final stamp = DateTime.now().millisecondsSinceEpoch;
        final team = 'Shop Recipes $stamp';
        final title = 'Shop V60 $stamp';
        final bean = 'Shop lot $stamp';

        await teams.openTeams(tester);
        await teams.createTeam(tester, team);
        await teams.openTeam(tester, team);
        await teams.saveTeamRecipe(
          tester,
          title: title,
          bean: bean,
          instructions: const ['bloom 30g'],
        );
        await recipes.backToJournal(tester);
        await recipes.expectTileFavorite(
          tester,
          scope: TeamDetailScreen,
          marker: bean,
          selected: false,
        );

        final viewerUrl = await teams.createInvite(
          tester,
          roleLabel: recipes.l10n.roleViewer,
          ttlLabel: recipes.l10n.inviteTtlOneHour,
        );
        await teams.signOutViaJournal(tester);

        final viewerEmail = auth.freshEmail();
        await auth.signUp(tester, viewerEmail, integrationPassword);
        await teams.go(tester, teams.invitePath(viewerUrl));
        await teams.expectJoined(tester, team, recipes.l10n.roleViewer);
        await teams.openJoinedTeam(tester, team);
        await recipes.tapTileFavorite(
          tester,
          scope: TeamDetailScreen,
          marker: bean,
        );
        await recipes.expectTileFavorite(
          tester,
          scope: TeamDetailScreen,
          marker: bean,
          selected: true,
        );

        await teams.openMyRecipes(tester);
        await teams.expectJournalDoesNotList(tester, title);
        await recipes.setHomeFavoritesOnly(tester, true);
        await recipes.expectHomeMessage(tester, recipes.l10n.noFavoriteRecipes);
        expect(find.text(title).hitTestable(), findsNothing);

        await teams.signOutViaJournal(tester);
        await auth.signIn(tester, ownerEmail, integrationPassword);
        await teams.openTeams(tester);
        await teams.openTeam(tester, team);
        await recipes.expectTileFavorite(
          tester,
          scope: TeamDetailScreen,
          marker: bean,
          selected: false,
        );
      },
      timeout: const Timeout(Duration(minutes: 8)),
    );
  });
}

Future<void> _saveRecipe(
  WidgetTester tester,
  RecipeHarness recipes, {
  required String title,
  required String bean,
}) async {
  await recipes.startNewRecipe(tester);
  await recipes.registerBean(tester, bean);
  await recipes.next(tester, find.text(recipes.l10n.brewParameters));
  await recipes.fillBrewParameters(tester, title: title);
  await recipes.next(tester, find.text(recipes.l10n.flavorMap));
  await recipes.next(tester, find.text(recipes.l10n.extraSteps));
  await recipes.next(tester, find.byKey(const Key('media-add')));
  await recipes.finish(tester);
}
