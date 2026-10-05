import 'package:brewing_journal_flutter/ui/features/brew_mode/view/brew_mode_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/auth_harness.dart';
import 'support/recipe_harness.dart';
import 'support/team_harness.dart';

/// Feature 8 against the development server (`serverpod start`).
///
/// US-4.7 a team bean or matcha shows up in ingredient search.
/// US-4.8 choosing it copies origin onto the member, and an existing
/// same-name ingredient keeps its own origin.
/// US-4.9 team grinders and the member's own grinder are suggested.
/// US-4.10 a teammate's personal recipe stays hidden, and taking the team
/// recipes off the team drops their grinders while an adopted ingredient stays.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final auth = AuthHarness();
  final recipes = RecipeHarness(auth);
  final teams = TeamHarness(recipes);
  tearDownAll(() async {
    await recipes.close();
    await auth.close();
  });

  group('Feature 8 — Team beans and grinders', () {
    testWidgets(
      'US-4.7 through US-4.10 shares beans and grinders, then follows the recipe off the team',
      (tester) async {
        await recipes.signUpFresh(tester);
        final ownerEmail = auth.accountEmail!;
        final stamp = DateTime.now().millisecondsSinceEpoch;
        final team = 'Catalog $stamp';
        final privateBean = 'Private Kenya $stamp';
        final privateGrinder = 'Private Mill $stamp';
        final teamBean = 'Team Ethiopia $stamp';
        const teamOrigin = 'Yirgacheffe';
        final teamGrinder = 'Team Mill $stamp';
        final matchaBean = 'Team Ceremonial $stamp';
        const matchaOrigin = 'Uji';
        final matchaGrinder = 'Matcha Mill $stamp';
        const memberOrigin = 'Member Farm';
        final memberGrinder = 'Member Mill $stamp';
        final viewerTitle = 'Viewer cup $stamp';

        await teams.openTeams(tester);
        await teams.createTeam(tester, team);
        await teams.openMyRecipes(tester);
        await teams.savePersonalRecipe(
          tester,
          title: 'Private V60 $stamp',
          bean: privateBean,
          grinder: privateGrinder,
        );
        await recipes.backToJournal(tester);
        await teams.openTeams(tester);
        await teams.openTeam(tester, team);
        await teams.saveTeamRecipe(
          tester,
          title: 'Shared V60 $stamp',
          bean: teamBean,
          origin: teamOrigin,
          grinder: teamGrinder,
          instructions: const ['bloom'],
        );
        await recipes.backToJournal(tester);
        await teams.saveTeamRecipe(
          tester,
          title: 'Shared matcha $stamp',
          bean: matchaBean,
          kind: recipes.l10n.matcha,
          origin: matchaOrigin,
          grinder: matchaGrinder,
          instructions: const ['whisk'],
        );
        await recipes.backToJournal(tester);
        final viewerUrl = await teams.createInvite(
          tester,
          roleLabel: recipes.l10n.roleViewer,
          ttlLabel: recipes.l10n.inviteTtlOneHour,
        );

        await teams.signOutViaJournal(tester);
        final viewerEmail = auth.freshEmail();
        await auth.signUp(tester, viewerEmail, integrationPassword);
        await auth.signOut(tester);
        await teams.openInviteSignedOut(tester, viewerUrl);
        await auth.signIn(tester, viewerEmail, integrationPassword);
        await teams.expectJoined(tester, team, recipes.l10n.roleViewer);
        await teams.openJoinedTeam(tester, team);
        await teams.openMyRecipes(tester);
        await recipes.startNewRecipe(tester);
        await recipes.waitForIngredient(tester, teamBean);
        recipes.expectIngredients(
          tester,
          present: [teamBean],
          absent: [privateBean, matchaBean],
        );
        recipes.expectIngredientRow(tester, teamBean, origin: teamOrigin);
        await recipes.searchIngredient(tester, 'Team Eth');
        recipes.expectIngredients(
          tester,
          present: [teamBean],
          absent: [privateBean],
        );
        await recipes.searchIngredient(tester, privateBean);
        recipes.expectIngredients(tester, absent: [privateBean, teamBean]);
        expect(find.text(recipes.l10n.noMatches(privateBean)), findsOneWidget);

        await recipes.searchIngredient(tester, '');
        await recipes.selectIngredientKind(tester, recipes.l10n.matcha);
        await recipes.waitForIngredient(tester, matchaBean);
        recipes.expectIngredients(
          tester,
          present: [matchaBean],
          absent: [teamBean, privateBean],
        );
        recipes.expectIngredientRow(tester, matchaBean, origin: matchaOrigin);
        await recipes.selectIngredientResult(tester, matchaBean);
        expect(recipes.selectedOrigin(tester), matchaOrigin);

        await recipes.next(tester, find.text(recipes.l10n.brewParameters));
        await recipes.waitForGrinder(tester, teamGrinder);
        await recipes.waitForGrinder(tester, matchaGrinder);
        recipes.expectGrinders(
          tester,
          present: [teamGrinder, matchaGrinder],
          absent: [privateGrinder],
        );
        await recipes.typeGrinder(tester, 'Matcha');
        recipes.expectGrinders(
          tester,
          present: [matchaGrinder],
          absent: [teamGrinder, privateGrinder],
        );
        await recipes.tapGrinderSuggestion(tester, matchaGrinder);
        await recipes.fillBrewParameters(
          tester,
          title: viewerTitle,
          grinder: memberGrinder,
        );
        await recipes.next(tester, find.text(recipes.l10n.flavorMap));
        await recipes.next(tester, find.text(recipes.l10n.extraSteps));
        await recipes.skipInstructions(tester);
        await recipes.finish(tester);
        await recipes.expectBrewText(tester, viewerTitle);
        await recipes.expectBrewText(tester, matchaBean);
        await recipes.expectBrewText(tester, memberGrinder);
        expect(
          find.descendant(
            of: find.byType(BrewModeScreen),
            matching: find.textContaining(matchaOrigin),
          ),
          findsOneWidget,
        );

        await recipes.backToJournal(tester);
        await recipes.startNewRecipe(tester);
        await recipes.waitForIngredient(tester, teamBean);
        recipes.expectIngredientRow(tester, teamBean, origin: teamOrigin);
        await recipes.registerBean(tester, teamBean, origin: memberOrigin);
        await recipes.searchIngredient(tester, teamBean);
        recipes.expectIngredientRow(
          tester,
          teamBean,
          origin: memberOrigin,
          notOrigin: teamOrigin,
        );
        await recipes.selectIngredientResult(tester, teamBean);
        expect(recipes.selectedOrigin(tester), memberOrigin);

        await recipes.next(tester, find.text(recipes.l10n.brewParameters));
        await recipes.waitForGrinder(tester, memberGrinder);
        await recipes.waitForGrinder(tester, teamGrinder);
        await recipes.waitForGrinder(tester, matchaGrinder);
        recipes.expectGrinders(
          tester,
          present: [memberGrinder, teamGrinder, matchaGrinder],
          absent: [privateGrinder],
        );
        await recipes.typeGrinder(tester, 'Priv');
        recipes.expectGrinders(
          tester,
          absent: [privateGrinder, teamGrinder, matchaGrinder, memberGrinder],
        );
        await recipes.closeWizard(tester);

        await teams.signOutViaJournal(tester);
        await auth.signIn(tester, ownerEmail, integrationPassword);
        await teams.openTeams(tester);
        await teams.openTeam(tester, team);
        await teams.openTeamRecipe(tester, 'Shared V60 $stamp');
        await teams.removeFromTeam(tester);
        await recipes.backToJournal(tester);
        await teams.openTeamRecipe(tester, 'Shared matcha $stamp');
        await teams.removeFromTeam(tester);
        await teams.signOutViaJournal(tester);

        await auth.signIn(tester, viewerEmail, integrationPassword);
        await teams.openMyRecipes(tester);
        await recipes.startNewRecipe(tester);
        await recipes.waitForIngredient(tester, teamBean);
        recipes.expectIngredientRow(
          tester,
          teamBean,
          origin: memberOrigin,
          notOrigin: teamOrigin,
        );
        recipes.expectIngredients(tester, absent: [privateBean, matchaBean]);
        await recipes.selectIngredientKind(tester, recipes.l10n.matcha);
        await recipes.waitForIngredient(tester, matchaBean);
        recipes.expectIngredientRow(tester, matchaBean, origin: matchaOrigin);
        recipes.expectIngredients(tester, absent: [teamBean, privateBean]);
        await recipes.selectIngredientResult(tester, matchaBean);
        expect(recipes.selectedOrigin(tester), matchaOrigin);

        await recipes.next(tester, find.text(recipes.l10n.brewParameters));
        await recipes.waitForGrinder(tester, memberGrinder);
        recipes.expectGrinders(
          tester,
          present: [memberGrinder],
          absent: [teamGrinder, matchaGrinder, privateGrinder],
        );
      },
      timeout: const Timeout(Duration(minutes: 8)),
    );
  });
}
