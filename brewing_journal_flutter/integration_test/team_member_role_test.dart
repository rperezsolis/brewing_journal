import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/auth_harness.dart';
import 'support/recipe_harness.dart';
import 'support/team_harness.dart';

/// Feature 9 against the development server (`serverpod start`).
///
/// US-4.11 every member sees preferred name, email, and role.
/// US-4.12 the owner confirms a switch, and No leaves the role alone.
/// US-4.13 the logged email names the team, the member, and the new role's
/// limits in the language the owner was using.
/// US-4.14 anyone else gets the same list with no edit icon, and a role
/// change from that account is rejected.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final auth = AuthHarness();
  final recipes = RecipeHarness(auth);
  final teams = TeamHarness(recipes);
  tearDownAll(() async {
    await recipes.close();
    await auth.close();
  });

  group('Feature 9 — Change a team member\'s role', () {
    testWidgets(
      'US-4.11 through US-4.14 lists members, confirms the switch, and keeps the control with the owner',
      (tester) async {
        const ownerName = 'Nia Owner';
        const adaName = 'Ada Member';
        await recipes.signUpFresh(tester, preferredName: ownerName);
        final ownerEmail = auth.accountEmail!;
        final stamp = DateTime.now().millisecondsSinceEpoch;
        final team = 'Role shop $stamp';

        await teams.openTeams(tester);
        await teams.createTeam(tester, team);
        await teams.openTeam(tester, team);
        final editorUrl = await teams.createInvite(
          tester,
          roleLabel: recipes.l10n.roleEditor,
          ttlLabel: recipes.l10n.inviteTtlOneHour,
        );

        await teams.signOutViaJournal(tester);
        final adaEmail = auth.freshEmail();
        await auth.signUp(
          tester,
          adaEmail,
          integrationPassword,
          preferredName: adaName,
        );
        await auth.signOut(tester);
        await teams.openInviteSignedOut(tester, editorUrl);
        await auth.signIn(tester, adaEmail, integrationPassword);
        await teams.expectJoined(tester, team, recipes.l10n.roleEditor);
        await teams.openJoinedTeam(tester, team);
        await teams.signOutViaJournal(tester);

        await auth.signIn(tester, ownerEmail, integrationPassword);
        await teams.openTeams(tester);
        await teams.openTeam(tester, team);
        await teams.openMembers(tester);
        await teams.expectMember(
          tester,
          name: ownerName,
          email: ownerEmail,
          role: recipes.l10n.roleEditor,
          canEdit: true,
        );
        await teams.expectMember(
          tester,
          name: adaName,
          email: adaEmail,
          role: recipes.l10n.roleEditor,
          canEdit: true,
        );
        expect(find.byIcon(Icons.edit_outlined), findsNWidgets(2));

        final toViewer = recipes.l10n.changeRoleToViewer(adaName);
        await teams.declineRoleChange(
          tester,
          name: adaName,
          question: toViewer,
        );
        await teams.expectMember(
          tester,
          name: adaName,
          email: adaEmail,
          role: recipes.l10n.roleEditor,
          canEdit: true,
        );
        expect(await auth.roleChangeNoticeCount(adaEmail), 0);

        await teams.confirmRoleChange(
          tester,
          name: adaName,
          question: toViewer,
        );
        await teams.expectMember(
          tester,
          name: adaName,
          email: adaEmail,
          role: recipes.l10n.roleViewer,
          canEdit: true,
        );
        await _expectRoleNotice(
          auth,
          teams,
          email: adaEmail,
          name: adaName,
          team: team,
          question: toViewer,
        );
        expect(await auth.roleChangeNoticeCount(adaEmail), 1);
        await teams.backFromMembers(tester);
        teams.expectRoleChip(tester, recipes.l10n.roleEditor);
        teams.expectNewRecipeButton(tester, visible: true);
        await teams.signOutViaJournal(tester);

        await auth.signIn(tester, adaEmail, integrationPassword);
        await teams.openTeams(tester);
        await teams.openTeam(tester, team);
        teams.expectRoleChip(tester, recipes.l10n.roleViewer);
        teams.expectNewRecipeButton(tester, visible: false);
        teams.expectInviteButton(tester, visible: false);
        await teams.openMembers(tester);
        await teams.expectMember(
          tester,
          name: ownerName,
          email: ownerEmail,
          role: recipes.l10n.roleEditor,
          canEdit: false,
        );
        await teams.expectMember(
          tester,
          name: adaName,
          email: adaEmail,
          role: recipes.l10n.roleViewer,
          canEdit: false,
        );
        expect(find.byIcon(Icons.edit_outlined), findsNothing);
        await teams.expectRoleChangeForbidden(
          tester,
          targetName: ownerName,
          role: TeamRole.viewer,
        );
        await teams.backFromMembers(tester);
        await teams.signOutViaJournal(tester);

        await auth.signIn(tester, ownerEmail, integrationPassword);
        await teams.openTeams(tester);
        await teams.openTeam(tester, team);
        await teams.openMembers(tester);
        final toEditor = recipes.l10n.changeRoleToEditor(adaName);
        await teams.confirmRoleChange(
          tester,
          name: adaName,
          question: toEditor,
        );
        await teams.expectMember(
          tester,
          name: adaName,
          email: adaEmail,
          role: recipes.l10n.roleEditor,
          canEdit: true,
        );
        await _expectRoleNotice(
          auth,
          teams,
          email: adaEmail,
          name: adaName,
          team: team,
          question: toEditor,
        );
        expect(await auth.roleChangeNoticeCount(adaEmail), 2);

        final ownerToViewer = recipes.l10n.changeRoleToViewer(ownerName);
        await teams.confirmRoleChange(
          tester,
          name: ownerName,
          question: ownerToViewer,
        );
        await teams.expectMember(
          tester,
          name: ownerName,
          email: ownerEmail,
          role: recipes.l10n.roleViewer,
          canEdit: true,
        );
        await _expectRoleNotice(
          auth,
          teams,
          email: ownerEmail,
          name: ownerName,
          team: team,
          question: ownerToViewer,
        );
        await teams.backFromMembers(tester);
        await teams.waitForRoleChip(tester, recipes.l10n.roleViewer);
        teams.expectNewRecipeButton(tester, visible: false);
        teams.expectInviteButton(tester, visible: true);
        await teams.signOutViaJournal(tester);

        await auth.signIn(tester, adaEmail, integrationPassword);
        await teams.openTeams(tester);
        await teams.openTeam(tester, team);
        teams.expectRoleChip(tester, recipes.l10n.roleEditor);
        teams.expectNewRecipeButton(tester, visible: true);
        teams.expectInviteButton(tester, visible: false);
        await teams.openMembers(tester);
        await teams.expectMember(
          tester,
          name: ownerName,
          email: ownerEmail,
          role: recipes.l10n.roleViewer,
          canEdit: false,
        );
        await teams.expectMember(
          tester,
          name: adaName,
          email: adaEmail,
          role: recipes.l10n.roleEditor,
          canEdit: false,
        );
        expect(find.byIcon(Icons.edit_outlined), findsNothing);
      },
      timeout: const Timeout(Duration(minutes: 8)),
    );
  });
}

/// The development log for one confirmed change.
///
/// The dialog and the email share the sentence after the question mark.
Future<void> _expectRoleNotice(
  AuthHarness auth,
  TeamHarness teams, {
  required String email,
  required String name,
  required String team,
  required String question,
}) async {
  final split = question.lastIndexOf('? ');
  expect(split, greaterThan(-1), reason: question);
  final notice = await auth.roleChangeNotice(
    email,
    contains: question.substring(split + 2),
  );
  expect(notice, contains('[${teams.roleChangeLocaleTag()}]'));
  expect(notice, contains(name));
  expect(notice, contains(team));
}
