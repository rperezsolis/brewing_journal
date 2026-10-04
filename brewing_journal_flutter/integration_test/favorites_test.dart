import 'package:brewing_journal_flutter/ui/features/brew_mode/view/brew_mode_screen.dart';
import 'package:brewing_journal_flutter/ui/features/recipe_list/view/recipe_list_screen.dart';
import 'package:brewing_journal_flutter/ui/features/teams/view/team_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/auth_harness.dart';
import 'support/recipe_harness.dart';
import 'support/team_harness.dart';

/// Favorites against the development server (`serverpod start`).
///
/// Feature 6: one personal favorite per recipe name, hearts on the tile and
/// in Brew Mode, close, Cancel, and Accept, and the home filter.
/// Feature 7: a separate team list that only an editor can change.
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
        // Spaces and capitalization still count as the same name.
        await _saveRecipe(
          tester,
          recipes,
          title: '  ${title.toLowerCase()} ',
          bean: secondBean,
        );
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

        // The folded title is a different string on screen, so open that tile.
        await recipes.openRecipe(tester, title.toLowerCase());
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

        await recipes.openRecipe(tester, title.toLowerCase());
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

        final otherTitle = 'Aeropress $stamp';
        final otherBean = 'Other lot $stamp';
        await _saveRecipe(tester, recipes, title: otherTitle, bean: otherBean);
        await recipes.backToJournal(tester);
        await recipes.tapTileFavorite(
          tester,
          scope: RecipeListScreen,
          marker: otherBean,
        );
        await recipes.expectTileFavorite(
          tester,
          scope: RecipeListScreen,
          marker: otherBean,
          selected: true,
        );
        expect(find.text(recipes.l10n.favoriteNameTakenTitle), findsNothing);
        await recipes.setHomeFavoritesOnly(tester, true);
        await recipes.expectTileFavorite(
          tester,
          scope: RecipeListScreen,
          marker: secondBean,
          selected: true,
        );
        await recipes.expectTileFavorite(
          tester,
          scope: RecipeListScreen,
          marker: otherBean,
          selected: true,
        );
        expect(find.textContaining(firstBean).hitTestable(), findsNothing);
      },
      timeout: const Timeout(Duration(minutes: 8)),
    );

    testWidgets(
      'US-6.5 through US-6.9 keeps team favorites separate from personal ones',
      (tester) async {
        await recipes.signUpFresh(tester);
        final ownerEmail = auth.accountEmail!;
        final stamp = DateTime.now().millisecondsSinceEpoch;
        final team = 'Shop Recipes $stamp';
        final title = 'Shop V60 $stamp';
        final firstBean = 'First lot $stamp';
        final secondBean = 'Second lot $stamp';

        await teams.openTeams(tester);
        await teams.createTeam(tester, team);
        await teams.openTeam(tester, team);
        await teams.saveTeamRecipe(
          tester,
          title: title,
          bean: firstBean,
          instructions: const ['bloom 30g'],
        );
        await recipes.backToJournal(tester);
        await teams.saveTeamRecipe(
          tester,
          title: title,
          bean: secondBean,
          instructions: const ['bloom 30g'],
        );
        await recipes.backToJournal(tester);

        await recipes.setTeamFavoritesOnly(tester, true);
        await recipes.expectHomeMessage(
          tester,
          recipes.l10n.noTeamFavoriteRecipes,
        );
        expect(find.text(title).hitTestable(), findsNothing);
        await recipes.setTeamFavoritesOnly(tester, false);
        await recipes.expectTileFavorite(
          tester,
          scope: TeamDetailScreen,
          marker: firstBean,
          selected: false,
        );
        await recipes.expectTileFavorite(
          tester,
          scope: TeamDetailScreen,
          marker: secondBean,
          selected: false,
        );

        await recipes.tapTileFavorite(
          tester,
          scope: TeamDetailScreen,
          marker: firstBean,
        );
        await recipes.expectTileFavorite(
          tester,
          scope: TeamDetailScreen,
          marker: firstBean,
          selected: true,
        );
        await recipes.tapTileFavorite(
          tester,
          scope: TeamDetailScreen,
          marker: secondBean,
        );
        await recipes.expectReplaceFavoriteDialog(tester, team: true);
        await recipes.closeReplaceFavoriteDialog(tester, team: true);
        await recipes.expectTileFavorite(
          tester,
          scope: TeamDetailScreen,
          marker: firstBean,
          selected: true,
        );
        await recipes.expectTileFavorite(
          tester,
          scope: TeamDetailScreen,
          marker: secondBean,
          selected: false,
        );

        await recipes.tapTileFavorite(
          tester,
          scope: TeamDetailScreen,
          marker: secondBean,
        );
        await recipes.expectReplaceFavoriteDialog(tester, team: true);
        await recipes.cancelReplaceFavoriteDialog(tester, team: true);
        await recipes.expectTileFavorite(
          tester,
          scope: TeamDetailScreen,
          marker: firstBean,
          selected: true,
        );

        await recipes.tapTileFavorite(
          tester,
          scope: TeamDetailScreen,
          marker: secondBean,
        );
        await recipes.expectReplaceFavoriteDialog(tester, team: true);
        await recipes.acceptReplaceFavoriteDialog(tester, team: true);
        await recipes.expectTileFavorite(
          tester,
          scope: TeamDetailScreen,
          marker: secondBean,
          selected: true,
        );
        await recipes.expectTileFavorite(
          tester,
          scope: TeamDetailScreen,
          marker: firstBean,
          selected: false,
        );

        await recipes.setTeamFavoritesOnly(tester, true);
        await recipes.expectTileFavorite(
          tester,
          scope: TeamDetailScreen,
          marker: secondBean,
          selected: true,
        );
        expect(find.textContaining(firstBean).hitTestable(), findsNothing);
        await recipes.setTeamFavoritesOnly(tester, false);
        expect(find.textContaining(firstBean).hitTestable(), findsOneWidget);

        await teams.openTeamRecipe(tester, title);
        await recipes.expectBrewText(tester, secondBean);
        await recipes.expectBrewFavorite(tester, selected: true);
        await recipes.toggleBrewFavorite(tester);
        await recipes.backToJournal(tester);
        await recipes.expectTileFavorite(
          tester,
          scope: TeamDetailScreen,
          marker: secondBean,
          selected: false,
        );
        await teams.openTeamRecipe(tester, title);
        await recipes.toggleBrewFavorite(tester);
        await recipes.backToJournal(tester);
        await recipes.expectTileFavorite(
          tester,
          scope: TeamDetailScreen,
          marker: secondBean,
          selected: true,
        );

        await teams.openMyRecipes(tester);
        await recipes.setHomeFavoritesOnly(tester, true);
        await recipes.expectHomeMessage(tester, recipes.l10n.noFavoriteRecipes);
        expect(find.text(title).hitTestable(), findsNothing);
        await recipes.setHomeFavoritesOnly(tester, false);

        await teams.openTeams(tester);
        await teams.openTeam(tester, team);
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
        await recipes.expectTileFavoriteLocked(
          tester,
          scope: TeamDetailScreen,
          marker: secondBean,
          selected: true,
        );
        await recipes.setTeamFavoritesOnly(tester, true);
        await recipes.expectTileFavoriteLocked(
          tester,
          scope: TeamDetailScreen,
          marker: secondBean,
          selected: true,
        );
        expect(find.textContaining(firstBean).hitTestable(), findsNothing);
        await recipes.setTeamFavoritesOnly(tester, false);
        expect(find.textContaining(firstBean).hitTestable(), findsOneWidget);

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
          marker: secondBean,
          selected: true,
        );

        await teams.openMyRecipes(tester);
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
        await teams.openTeams(tester);
        await teams.openTeam(tester, team);
        await recipes.expectTileFavorite(
          tester,
          scope: TeamDetailScreen,
          marker: firstBean,
          selected: false,
        );
        await recipes.expectTileFavorite(
          tester,
          scope: TeamDetailScreen,
          marker: secondBean,
          selected: true,
        );

        await teams.openMyRecipes(tester);
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

        await teams.openTeams(tester);
        await teams.openTeam(tester, team);
        await recipes.expectTileFavorite(
          tester,
          scope: TeamDetailScreen,
          marker: firstBean,
          selected: false,
        );
        await recipes.expectTileFavorite(
          tester,
          scope: TeamDetailScreen,
          marker: secondBean,
          selected: true,
        );
        await teams.openTeamRecipe(tester, title);
        await teams.removeFromTeam(tester);
        await recipes.backToJournal(tester);
        expect(find.textContaining(secondBean).hitTestable(), findsNothing);

        await teams.openMyRecipes(tester);
        await recipes.setHomeFavoritesOnly(tester, true);
        await recipes.expectTileFavorite(
          tester,
          scope: RecipeListScreen,
          marker: secondBean,
          selected: true,
        );
        expect(find.textContaining(firstBean).hitTestable(), findsNothing);
      },
      timeout: const Timeout(Duration(minutes: 8)),
    );

    testWidgets(
      'a new version keeps the favorite until it is replaced',
      (tester) async {
        await recipes.signUpFresh(tester);
        final stamp = DateTime.now().millisecondsSinceEpoch;
        final title = 'Versioned V60 $stamp';
        final bean = 'Version lot $stamp';

        await _saveRecipe(tester, recipes, title: title, bean: bean);
        await recipes.backToJournal(tester);
        await recipes.tapTileFavorite(
          tester,
          scope: RecipeListScreen,
          marker: bean,
        );
        await recipes.openRecipe(tester, title);
        await _saveVersion(tester, recipes, dose: '18');
        await recipes.expectBrewFavorite(tester, selected: false);
        await recipes.backToJournal(tester);
        await recipes.expectTileFavorite(
          tester,
          scope: RecipeListScreen,
          marker: '15 g',
          selected: true,
        );
        await recipes.expectTileFavorite(
          tester,
          scope: RecipeListScreen,
          marker: '18 g',
          selected: false,
        );

        await recipes.tapTileFavorite(
          tester,
          scope: RecipeListScreen,
          marker: '18 g',
        );
        await recipes.expectReplaceFavoriteDialog(tester);
        await recipes.acceptReplaceFavoriteDialog(tester);
        await recipes.expectTileFavorite(
          tester,
          scope: RecipeListScreen,
          marker: '18 g',
          selected: true,
        );
        await recipes.expectTileFavorite(
          tester,
          scope: RecipeListScreen,
          marker: '15 g',
          selected: false,
        );

        final team = 'Version shop $stamp';
        final teamTitle = 'Shop version $stamp';
        final teamBean = 'Shop lot $stamp';
        await teams.openTeams(tester);
        await teams.createTeam(tester, team);
        await teams.openTeam(tester, team);
        await teams.saveTeamRecipe(
          tester,
          title: teamTitle,
          bean: teamBean,
          instructions: const ['bloom 30g'],
        );
        await recipes.backToJournal(tester);
        await recipes.tapTileFavorite(
          tester,
          scope: TeamDetailScreen,
          marker: teamBean,
        );
        await teams.openTeamRecipe(tester, teamTitle);
        await recipes.expectBrewFavorite(tester, selected: true);
        await _saveVersion(tester, recipes, dose: '21');
        await recipes.expectBrewFavorite(tester, selected: false);
        await recipes.tapBrewFavorite(tester);
        await recipes.expectReplaceFavoriteDialog(tester, team: true);
        await recipes.cancelReplaceFavoriteDialog(tester, team: true);
        await recipes.expectBrewFavorite(tester, selected: false);
        await recipes.backToJournal(tester);
        await recipes.expectTileFavorite(
          tester,
          scope: TeamDetailScreen,
          marker: '15 g',
          selected: true,
        );
        await recipes.expectTileFavorite(
          tester,
          scope: TeamDetailScreen,
          marker: '21 g',
          selected: false,
        );

        await teams.openMyRecipes(tester);
        await recipes.setHomeFavoritesOnly(tester, true);
        expect(find.text(teamTitle).hitTestable(), findsNothing);
      },
      timeout: const Timeout(Duration(minutes: 8)),
    );

    testWidgets(
      'a viewer who owns the recipe cannot change the team favorite',
      (tester) async {
        await recipes.signUpFresh(tester);
        final email = auth.accountEmail!;
        final stamp = DateTime.now().millisecondsSinceEpoch;
        final team = 'Owner viewer $stamp';
        final title = 'Owner V60 $stamp';
        final bean = 'Owner lot $stamp';

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
        await auth.demoteTeamEditors(team);
        await teams.signOutViaJournal(tester);
        await auth.signIn(tester, email, integrationPassword);

        await teams.openTeams(tester);
        await teams.openTeam(tester, team);
        teams.expectRoleChip(tester, recipes.l10n.roleViewer);
        teams.expectNewRecipeButton(tester, visible: false);
        await recipes.expectTileFavoriteLocked(
          tester,
          scope: TeamDetailScreen,
          marker: bean,
          selected: true,
        );
        await recipes.setTeamFavoritesOnly(tester, true);
        await recipes.expectTileFavoriteLocked(
          tester,
          scope: TeamDetailScreen,
          marker: bean,
          selected: true,
        );
        await recipes.setTeamFavoritesOnly(tester, false);

        await teams.openTeamRecipe(tester, title);
        teams.expectBrewActions(
          tester,
          canEdit: true,
          canDelete: true,
          onTeam: true,
        );
        await recipes.expectBrewFavoriteLocked(tester, selected: true);
      },
      timeout: const Timeout(Duration(minutes: 6)),
    );
  });
}

Future<void> _saveVersion(
  WidgetTester tester,
  RecipeHarness recipes, {
  required String dose,
}) async {
  await recipes.editRecipe(tester);
  await recipes.openStep(
    tester,
    recipes.l10n.stepBrew,
    find.byKey(const Key('extraction-dose')),
  );
  await recipes.setDose(tester, dose);
  await recipes.openStep(
    tester,
    recipes.l10n.stepPhotos,
    find.byKey(const Key('media-add')),
  );
  await recipes.finish(tester);
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
