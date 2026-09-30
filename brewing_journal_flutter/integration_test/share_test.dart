import 'dart:io';

import 'package:brewing_journal_flutter/data/services/share_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/auth_harness.dart';
import 'support/recipe_harness.dart';
import 'support/share_harness.dart';
import 'support/team_harness.dart';

/// Feature 5 against the development server (`serverpod start`).
///
/// US-5.1 a V60 card sent as one PNG, US-5.2 the same for matcha, US-5.3
/// extra steps on the card, left off when empty, and summarized when they
/// do not fit. A team viewer can open Share. When the sheet is unavailable
/// the PNG can be downloaded.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final auth = AuthHarness();
  final recipes = RecipeHarness(auth);
  final share = ShareHarness(recipes);
  final teams = TeamHarness(recipes);
  tearDown(share.deleteDownload);
  tearDownAll(() async {
    final leftover = File(shareImageName);
    if (leftover.existsSync()) leftover.deleteSync();
    await recipes.close();
    await auth.close();
  });

  group('Feature 5 — Social sharing', () {
    testWidgets(
      'US-5.1 US-5.3 shares a V60 card and downloads when sharing is unavailable',
      (tester) async {
        share.prepare(tester);
        await recipes.signUpFresh(tester);
        final stamp = DateTime.now().millisecondsSinceEpoch;
        final title = 'Morning V60 $stamp';
        final bean = 'Chelbesa $stamp';
        const steps = [
          'bloom',
          'pour',
          'stir',
          'wait',
          'drawdown',
          'serve',
        ];

        await share.saveRecipe(
          tester,
          title: title,
          bean: bean,
          duration: '3:00',
          tag: 'jasmine',
          instructions: steps,
        );
        await share.openFromBrew(tester);
        share.expectCard(
          tester,
          title: title,
          kind: recipes.l10n.coffee,
          ingredient: bean,
          method: recipes.l10n.methodV60,
          instructions: steps,
          tag: 'jasmine',
          timer: recipes.l10n.timerSummary('3', '00'),
        );

        share.sheetResult = shareSheetSuccess;
        final shared = await share.submit(tester, showsDownload: false);
        share.expectImageOnly(shared, title: title);
        expect(find.text(recipes.l10n.sharingNotSupported), findsNothing);

        share.sheetResult = shareSheetDismissed;
        final dismissed = await share.submit(tester, showsDownload: false);
        share.expectImageOnly(dismissed, title: title);
        expect(find.text(recipes.l10n.sharingNotSupported), findsNothing);

        share.sheetResult = shareSheetUnavailable;
        final unavailable = await share.submit(tester, showsDownload: true);
        share.expectImageOnly(unavailable, title: title);
        await share.downloadAndExpectPng(tester);

        await share.close(tester);
        await share.openFromRecipeUrl(tester);
        share.expectCard(
          tester,
          title: title,
          kind: recipes.l10n.coffee,
          ingredient: bean,
          method: recipes.l10n.methodV60,
          instructions: steps,
          tag: 'jasmine',
          timer: recipes.l10n.timerSummary('3', '00'),
        );
        await share.close(tester);
        await recipes.backToJournal(tester);

        final plainTitle = 'Plain V60 $stamp';
        final plainBean = 'Yirga $stamp';
        await share.saveRecipe(
          tester,
          title: plainTitle,
          bean: plainBean,
        );
        share.sheetResult = shareSheetSuccess;
        await share.openFromBrew(tester);
        share.expectCard(
          tester,
          title: plainTitle,
          kind: recipes.l10n.coffee,
          ingredient: plainBean,
          method: recipes.l10n.methodV60,
          instructions: const [],
        );
        final plain = await share.submit(tester, showsDownload: false);
        share.expectImageOnly(plain, title: plainTitle);
      },
      timeout: const Timeout(Duration(minutes: 8)),
    );

    testWidgets('US-5.2 shares a matcha card as one image', (tester) async {
      share.prepare(tester);
      await recipes.openJournal(tester);
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final title = 'Usucha $stamp';
      final bowl = 'Uji $stamp';
      const steps = ['sift', 'whisk to foam'];

      await share.saveRecipe(
        tester,
        title: title,
        bean: bowl,
        kind: recipes.l10n.matcha,
        method: recipes.l10n.methodMatchaWhisk,
        instructions: steps,
      );
      await share.openFromBrew(tester);
      share.expectCard(
        tester,
        title: title,
        kind: recipes.l10n.matcha,
        ingredient: bowl,
        method: recipes.l10n.methodMatchaWhisk,
        instructions: steps,
      );
      share.sheetResult = shareSheetSuccess;
      final shared = await share.submit(tester, showsDownload: false);
      share.expectImageOnly(shared, title: title);
    }, timeout: const Timeout(Duration(minutes: 4)));

    testWidgets('a team viewer can share the recipe card', (tester) async {
      share.prepare(tester);
      await recipes.signUpFresh(tester);
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final team = 'Share shop $stamp';
      final title = 'Shop V60 $stamp';
      final bean = 'Chelbesa $stamp';
      const steps = ['bloom 30g', 'pour to 250g'];

      await teams.openTeams(tester);
      await teams.createTeam(tester, team);
      await teams.openTeam(tester, team);
      await teams.saveTeamRecipe(
        tester,
        title: title,
        bean: bean,
        instructions: steps,
      );
      teams.expectBrewActions(
        tester,
        canEdit: true,
        canDelete: true,
        onTeam: true,
      );
      await recipes.backToJournal(tester);
      final viewerUrl = await teams.createInvite(
        tester,
        roleLabel: recipes.l10n.roleViewer,
        ttlLabel: recipes.l10n.inviteTtlOneHour,
      );
      await teams.signOutViaJournal(tester);

      await auth.signUp(tester, auth.freshEmail(), integrationPassword);
      await teams.openTeams(tester);
      await teams.joinByPaste(tester, viewerUrl);
      await teams.expectJoined(tester, team, recipes.l10n.roleViewer);
      await teams.openJoinedTeam(tester, team);
      await teams.openTeamRecipe(tester, title);
      teams.expectBrewActions(
        tester,
        canEdit: false,
        canDelete: false,
        onTeam: true,
      );

      share.sheetResult = shareSheetSuccess;
      await share.openFromBrew(tester);
      share.expectCard(
        tester,
        title: title,
        kind: recipes.l10n.coffee,
        ingredient: bean,
        method: recipes.l10n.methodV60,
        instructions: steps,
      );
      final shared = await share.submit(tester, showsDownload: false);
      share.expectImageOnly(shared, title: title);
    }, timeout: const Timeout(Duration(minutes: 8)));
  });
}
