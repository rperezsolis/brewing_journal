import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/auth_harness.dart';
import 'support/recipe_harness.dart';
import 'support/team_harness.dart';

/// Feature 4 against the development server (`serverpod start`).
///
/// US-4.1 create a team and put a recipe on it, US-4.2 a viewer invite,
/// US-4.3 an editor invite, US-4.4 a viewer can read steps but not change
/// them, US-4.5 used, unknown, and expired invites, US-4.6 an editor's save
/// stores a new version and the owner's later save stores another. Brew Mode
/// opens the version that was just saved.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final auth = AuthHarness();
  final recipes = RecipeHarness(auth);
  final teams = TeamHarness(recipes);
  tearDownAll(() async {
    await recipes.close();
    await auth.close();
  });

  group('Feature 4 — Collaborative teams and RBAC', () {
    testWidgets(
      'US-4.1 through US-4.6 shares one recipe across three accounts',
      (
        tester,
      ) async {
        await recipes.signUpFresh(tester);
        final ownerEmail = auth.accountEmail!;
        final stamp = DateTime.now().millisecondsSinceEpoch;
        final team = 'Shop Recipes $stamp';
        final title = 'Shop V60 $stamp';
        final bean = 'Chelbesa $stamp';
        const original = ['bloom 30g', 'pour to 250g'];
        const edited = ['stir the crust', 'draw down'];
        const ownersFinal = ['final pour'];

        await teams.openTeams(tester);
        await teams.expectNoTeams(tester);
        await teams.rejectBlankTeamName(tester);
        await teams.createTeam(tester, team);
        await teams.openTeam(tester, team);
        await teams.expectNoRecipes(tester);
        teams.expectInviteButton(tester, visible: true);
        teams.expectNewRecipeButton(tester, visible: true);
        teams.expectRoleChip(tester, recipes.l10n.roleEditor);

        await teams.saveTeamRecipe(
          tester,
          title: title,
          bean: bean,
          instructions: original,
        );
        await recipes.expectBrewInstructions(tester, original);
        expect(find.text(recipes.l10n.prepAndExtraSteps), findsOneWidget);
        teams.expectBrewActions(
          tester,
          canEdit: true,
          canDelete: true,
          onTeam: true,
        );
        final recipePath = teams.uri(tester).path;
        await recipes.backToJournal(tester);
        await teams.expectRecipe(tester, title);

        final viewerUrl = await teams.createInvite(
          tester,
          roleLabel: recipes.l10n.roleViewer,
          ttlLabel: recipes.l10n.inviteTtlOneHour,
        );

        await teams.signOutViaJournal(tester);
        final viewerEmail = auth.freshEmail();
        await auth.signUp(tester, viewerEmail, integrationPassword);
        await auth.signOut(tester);
        final editorEmail = auth.freshEmail();
        await auth.signUp(tester, editorEmail, integrationPassword);
        await auth.signOut(tester);

        await teams.openInviteSignedOut(tester, viewerUrl);
        await auth.signIn(tester, viewerEmail, integrationPassword);
        await teams.expectJoined(tester, team, recipes.l10n.roleViewer);
        await teams.openJoinedTeam(tester, team);
        teams.expectRoleChip(tester, recipes.l10n.roleViewer);
        teams.expectInviteButton(tester, visible: false);
        teams.expectNewRecipeButton(tester, visible: false);
        await teams.openTeamRecipe(tester, title);
        await recipes.expectBrewText(tester, bean);
        await recipes.expectBrewInstructions(tester, original);
        expect(find.text(recipes.l10n.prepAndExtraSteps), findsOneWidget);
        teams.expectBrewActions(
          tester,
          canEdit: false,
          canDelete: false,
          onTeam: true,
        );
        await teams.expectEditRouteIsReadOnly(tester);

        await recipes.backToJournal(tester);
        await teams.openMyRecipes(tester);
        await teams.expectJournalDoesNotList(tester, title);

        await teams.go(tester, teams.invitePath(viewerUrl));
        await teams.expectAlreadyMember(tester);
        await teams.openJoinedTeam(tester, team);
        await teams.backToTeams(tester);
        await teams.expectMembership(
          tester,
          team,
          recipes.l10n.roleViewer,
          owner: false,
        );
        await teams.signOutViaJournal(tester);

        await teams.openInviteSignedOut(tester, viewerUrl);
        await auth.signIn(tester, editorEmail, integrationPassword);
        await teams.expectInviteUsed(tester);
        await teams.goHomeFromInvite(tester);
        await teams.openTeams(tester);
        await teams.expectTeamAbsent(tester, team);
        await teams.go(tester, recipePath);
        await teams.expectRecipeHidden(tester, title);
        await teams.leaveHiddenRecipe(tester);
        await auth.signOut(tester);

        await auth.signIn(tester, ownerEmail, integrationPassword);
        await teams.openTeams(tester);
        await teams.openTeam(tester, team);
        final editorUrl = await teams.createInvite(
          tester,
          roleLabel: recipes.l10n.roleEditor,
          ttlLabel: recipes.l10n.inviteTtlOneWeek,
        );
        await teams.signOutViaJournal(tester);

        await auth.signIn(tester, editorEmail, integrationPassword);
        await teams.openTeams(tester);
        await teams.joinByPaste(tester, editorUrl);
        await teams.expectJoined(tester, team, recipes.l10n.roleEditor);
        await teams.openJoinedTeam(tester, team);
        teams.expectRoleChip(tester, recipes.l10n.roleEditor);
        teams.expectInviteButton(tester, visible: false);
        teams.expectNewRecipeButton(tester, visible: true);
        await teams.openTeamRecipe(tester, title);
        teams.expectBrewActions(
          tester,
          canEdit: true,
          canDelete: false,
          onTeam: true,
        );
        await teams.replaceInstructions(tester, edited);
        await recipes.expectBrewInstructions(tester, edited);
        await teams.signOutViaJournal(tester);

        await auth.signIn(tester, ownerEmail, integrationPassword);
        await teams.openTeams(tester);
        await teams.openTeam(tester, team);
        await teams.openTeamRecipe(tester, title);
        await recipes.expectBrewInstructions(tester, edited);
        await teams.replaceInstructions(tester, ownersFinal);
        await recipes.expectBrewInstructions(tester, ownersFinal);
      },
      timeout: const Timeout(Duration(minutes: 8)),
    );

    testWidgets('moves a personal recipe onto a team and back off it', (
      tester,
    ) async {
      await recipes.signUpFresh(tester);
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final team = 'Bar team $stamp';
      final title = 'House espresso $stamp';

      await teams.savePersonalRecipe(
        tester,
        title: title,
        bean: 'Espresso blend $stamp',
      );
      teams.expectBrewActions(
        tester,
        canEdit: true,
        canDelete: true,
        onTeam: false,
      );
      await recipes.backToJournal(tester);
      await recipes.expectOnList(tester, title);

      await teams.openTeams(tester);
      await teams.createTeam(tester, team);
      await teams.openMyRecipes(tester);
      await recipes.openRecipe(tester, title);
      await teams.assignToTeam(tester, team);
      teams.expectBrewActions(
        tester,
        canEdit: true,
        canDelete: true,
        onTeam: true,
      );

      await recipes.backToJournal(tester);
      await teams.openTeams(tester);
      await teams.openTeam(tester, team);
      await teams.expectRecipe(tester, title);
      await teams.openTeamRecipe(tester, title);
      await teams.removeFromTeam(tester);
      teams.expectBrewActions(
        tester,
        canEdit: true,
        canDelete: true,
        onTeam: false,
      );
      await recipes.backToJournal(tester);
      await teams.expectRecipeGone(tester, title);
      await teams.openMyRecipes(tester);
      await recipes.expectOnList(tester, title);
    }, timeout: const Timeout(Duration(minutes: 5)));

    testWidgets('US-4.5 unknown and expired invites do not join', (
      tester,
    ) async {
      await recipes.signUpFresh(tester);
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final team = 'Closed shop $stamp';

      await teams.openTeams(tester);
      await teams.createTeam(tester, team);
      await teams.openTeam(tester, team);
      final url = await teams.createInvite(
        tester,
        roleLabel: recipes.l10n.roleViewer,
        ttlLabel: recipes.l10n.inviteTtlOneDay,
      );
      await auth.expireInvite(teams.inviteToken(url));
      await teams.backToTeams(tester);

      await teams.joinByPaste(tester, 'missing-invite-token');
      await teams.expectInviteNotFound(tester);
      await teams.goHomeFromInvite(tester);

      await auth.signOut(tester);
      await auth.signUp(tester, auth.freshEmail(), integrationPassword);
      await teams.openTeams(tester);
      await teams.joinByPaste(tester, teams.inviteToken(url));
      await teams.expectInviteExpired(tester);
      await teams.goHomeFromInvite(tester);
      await teams.openTeams(tester);
      await teams.expectTeamAbsent(tester, team);
    }, timeout: const Timeout(Duration(minutes: 5)));
  });
}
