import 'package:brewing_journal_flutter/l10n/app_localizations.dart';
import 'package:brewing_journal_flutter/main.dart' as app;
import 'package:brewing_journal_flutter/ui/features/brew_mode/view/brew_mode_screen.dart';
import 'package:brewing_journal_flutter/ui/features/recipe_creation/view/recipe_wizard_screen.dart';
import 'package:brewing_journal_flutter/ui/features/recipe_list/view/recipe_list_screen.dart';
import 'package:brewing_journal_flutter/ui/features/teams/view/team_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'auth_harness.dart';
import 'recipe_harness.dart';

/// Drives teams, invites, and brew-mode access against the development server.
class TeamHarness {
  TeamHarness(this.recipes);

  final RecipeHarness recipes;

  AuthHarness get auth => recipes.auth;

  AppLocalizations get l10n => recipes.l10n;

  Future<void> openTeams(WidgetTester tester) async {
    await _selectTab(tester, l10n.teams);
    if (find.byType(TeamDetailScreen).hitTestable().evaluate().isNotEmpty) {
      await backToTeams(tester);
    }
    await recipes.waitFor(
      tester,
      find.byKey(const Key('teams-create')).hitTestable(),
      'the teams list',
    );
  }

  Future<void> openMyRecipes(WidgetTester tester) async {
    await _selectTab(tester, l10n.myRecipes);
    await recipes.waitFor(
      tester,
      find.byType(RecipeListScreen).hitTestable(),
      'my recipes',
    );
  }

  Future<void> expectNoTeams(WidgetTester tester) async {
    await recipes.waitFor(
      tester,
      find.text(l10n.noTeamsYet).hitTestable(),
      'the empty teams list',
    );
  }

  /// A blank name is trimmed and rejected, and the list stays empty.
  Future<void> rejectBlankTeamName(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('teams-create')).hitTestable());
    await tester.pump();
    await recipes.waitFor(
      tester,
      find.byKey(const Key('team-name')),
      'the create-team dialog',
    );
    await tester.enterText(find.byKey(const Key('team-name')), '   ');
    await tester.pump();
    await tester.tap(_dialogButton(l10n.create));
    await tester.pump();
    await recipes.waitUntil(
      tester,
      () =>
          find.byKey(const Key('team-name')).evaluate().isEmpty &&
          find.textContaining('1 to 80').evaluate().isNotEmpty &&
          find.text(l10n.noTeamsYet).hitTestable().evaluate().isNotEmpty,
      'the blank-name error',
    );
    recipes.dismissSnackBars(tester);
    await recipes.waitUntil(
      tester,
      () =>
          find.textContaining('1 to 80').evaluate().isEmpty &&
          find
              .byKey(const Key('teams-create'))
              .hitTestable()
              .evaluate()
              .isNotEmpty,
      'the blank-name error to leave',
    );
  }

  Future<void> createTeam(WidgetTester tester, String name) async {
    await recipes.waitFor(
      tester,
      find.byKey(const Key('teams-create')).hitTestable(),
      'the create-team button',
    );
    await tester.tap(find.byKey(const Key('teams-create')).hitTestable());
    await tester.pump();
    await recipes.waitFor(
      tester,
      find.byKey(const Key('team-name')),
      'the create-team dialog',
    );
    await tester.enterText(find.byKey(const Key('team-name')), name);
    await tester.pump();
    await tester.tap(_dialogButton(l10n.create));
    await tester.pump();
    await expectMembership(tester, name, l10n.roleEditor, owner: true);
  }

  Future<void> expectMembership(
    WidgetTester tester,
    String team,
    String role, {
    required bool owner,
  }) async {
    await recipes.waitFor(tester, find.text(team).hitTestable(), team);
    final badge = owner ? l10n.ownerRole(role) : role;
    expect(find.text(badge).hitTestable(), findsOneWidget);
    if (!owner) {
      expect(find.text(l10n.ownerRole(role)).hitTestable(), findsNothing);
    }
  }

  Future<void> expectTeamAbsent(WidgetTester tester, String team) async {
    await expectNoTeams(tester);
    expect(find.text(team).hitTestable(), findsNothing);
  }

  Future<void> openTeam(WidgetTester tester, String name) async {
    await tester.tap(find.text(name).hitTestable());
    await tester.pump();
    await recipes.waitFor(
      tester,
      find.byType(TeamDetailScreen).hitTestable(),
      name,
    );
    await recipes.waitFor(tester, find.text(name).hitTestable(), name);
  }

  Future<void> backToTeams(WidgetTester tester) async {
    await tester.tap(find.byType(BackButton).hitTestable());
    await tester.pump();
    await recipes.waitFor(
      tester,
      find.byKey(const Key('teams-join')).hitTestable(),
      'the teams list',
    );
  }

  void expectInviteButton(WidgetTester tester, {required bool visible}) {
    expect(
      find.byKey(const Key('team-invite')).hitTestable(),
      visible ? findsOneWidget : findsNothing,
    );
  }

  void expectNewRecipeButton(WidgetTester tester, {required bool visible}) {
    expect(
      find.byKey(const Key('team-new-recipe')).hitTestable(),
      visible ? findsOneWidget : findsNothing,
    );
  }

  void expectRoleChip(WidgetTester tester, String role) {
    expect(
      find.descendant(
        of: find.byType(TeamDetailScreen).hitTestable(),
        matching: find.widgetWithText(Chip, role),
      ),
      findsOneWidget,
    );
  }

  Future<void> expectNoRecipes(WidgetTester tester) async {
    await recipes.waitFor(
      tester,
      find.text(l10n.noRecipesOnTeam).hitTestable(),
      'the empty team',
    );
  }

  Future<void> expectRecipe(WidgetTester tester, String title) async {
    await recipes.waitFor(
      tester,
      find
          .descendant(
            of: find.byType(TeamDetailScreen),
            matching: find.text(title),
          )
          .hitTestable(),
      title,
    );
  }

  Future<void> expectRecipeGone(WidgetTester tester, String title) async {
    await recipes.waitUntil(
      tester,
      () =>
          find.text(l10n.noRecipesOnTeam).hitTestable().evaluate().isNotEmpty &&
          find.text(title).hitTestable().evaluate().isEmpty,
      'the recipe to leave the team',
      timeout: const Duration(seconds: 30),
    );
  }

  Future<void> openTeamRecipe(WidgetTester tester, String title) async {
    final tile = find
        .descendant(
          of: find.byType(TeamDetailScreen),
          matching: find.text(title),
        )
        .hitTestable();
    await recipes.waitFor(tester, tile, title);
    // Versions share a title. The list is newest first.
    await tester.ensureVisible(tile.first);
    await tester.tap(tile.first);
    await tester.pump();
    await recipes.expectBrewText(tester, title);
  }

  /// Creates the invite currently selected in the sheet and returns its URL.
  Future<String> createInvite(
    WidgetTester tester, {
    required String roleLabel,
    required String ttlLabel,
  }) async {
    await tester.tap(find.byKey(const Key('team-invite')).hitTestable());
    await tester.pump();
    await recipes.waitFor(
      tester,
      find.byKey(const Key('invite-create')),
      'the invite sheet',
    );
    final previous = _inviteUrl(tester);
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('invite-role')),
        matching: find.text(roleLabel),
      ),
    );
    await tester.pump();
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('invite-ttl')),
        matching: find.text(ttlLabel),
      ),
    );
    await tester.pump();
    final create = find.byKey(const Key('invite-create'));
    expect(tester.widget<FilledButton>(create).onPressed, isNotNull);
    await tester.tap(create);
    await tester.pump();

    String? url;
    await recipes.waitUntil(
      tester,
      () {
        url = _inviteUrl(tester);
        return url != null && url != previous && url!.contains('/invite/');
      },
      'the invite link',
      timeout: const Duration(seconds: 30),
    );
    expect(find.text(l10n.singleUse), findsOneWidget);
    await tester.tap(find.byKey(const Key('invite-copy')));
    await tester.pump();
    await recipes.waitFor(
      tester,
      find.text(l10n.inviteLinkCopied),
      'the copied confirmation',
    );
    recipes.dismissSnackBars(tester);
    await tester.pump();
    Navigator.of(tester.element(find.byKey(const Key('invite-url')))).pop();
    await tester.pump();
    await recipes.waitUntil(
      tester,
      () => find.byKey(const Key('invite-create')).evaluate().isEmpty,
      'the invite sheet to close',
    );
    return url!;
  }

  Future<void> joinByPaste(WidgetTester tester, String urlOrToken) async {
    await tester.tap(find.byKey(const Key('teams-join')).hitTestable());
    await tester.pump();
    await recipes.waitFor(
      tester,
      find.byKey(const Key('join-invite-input')),
      'join with invite',
    );
    await tester.enterText(
      find.byKey(const Key('join-invite-input')),
      urlOrToken,
    );
    await tester.pump();
    await tester.tap(_dialogButton(l10n.join));
    await tester.pump();
  }

  /// Opens an invite while signed out and stops on the sign-in screen.
  ///
  /// The original path is kept as `from`, so the next sign-in returns to it.
  Future<void> openInviteSignedOut(WidgetTester tester, String url) async {
    final path = invitePath(url);
    await go(tester, path);
    await recipes.waitFor(
      tester,
      find.byKey(const ValueKey('sign-in')),
      'sign-in',
    );
    expect(uri(tester).path, '/sign-in');
    expect(uri(tester).queryParameters['from'], path);
    expect(find.text(l10n.teamInvite), findsNothing);
  }

  Future<void> expectJoined(
    WidgetTester tester,
    String team,
    String role,
  ) async {
    await _expectInviteOutcome(
      tester,
      l10n.youJoined(team, role),
      openTeam: true,
    );
  }

  Future<void> expectAlreadyMember(WidgetTester tester) async {
    await _expectInviteOutcome(tester, l10n.alreadyMember, openTeam: true);
  }

  Future<void> expectInviteUsed(WidgetTester tester) async {
    await _expectInviteOutcome(tester, l10n.inviteUsed, openTeam: false);
  }

  Future<void> expectInviteExpired(WidgetTester tester) async {
    await _expectInviteOutcome(tester, l10n.inviteExpired, openTeam: false);
  }

  Future<void> expectInviteNotFound(WidgetTester tester) async {
    await _expectInviteOutcome(tester, l10n.inviteNotFound, openTeam: false);
  }

  Future<void> openJoinedTeam(WidgetTester tester, String team) async {
    await tester.tap(find.text(l10n.openTeam).hitTestable());
    await tester.pump();
    await recipes.waitFor(
      tester,
      find.byType(TeamDetailScreen).hitTestable(),
      team,
    );
    await recipes.waitFor(tester, find.text(team).hitTestable(), team);
  }

  Future<void> goHomeFromInvite(WidgetTester tester) async {
    await tester.tap(find.text(l10n.goHome).hitTestable());
    await tester.pump();
    await recipes.waitFor(
      tester,
      find.byType(RecipeListScreen).hitTestable(),
      'the journal',
    );
  }

  Future<void> saveTeamRecipe(
    WidgetTester tester, {
    required String title,
    required String bean,
    required List<String> instructions,
  }) async {
    await tester.tap(find.byKey(const Key('team-new-recipe')).hitTestable());
    await tester.pump();
    await recipes.waitFor(
      tester,
      find.text(l10n.whatAreYouBrewing),
      'the new recipe wizard',
    );
    await _saveRecipe(
      tester,
      title: title,
      bean: bean,
      instructions: instructions,
    );
  }

  Future<void> savePersonalRecipe(
    WidgetTester tester, {
    required String title,
    required String bean,
  }) async {
    await recipes.startNewRecipe(tester);
    await _saveRecipe(tester, title: title, bean: bean, instructions: const []);
  }

  Future<void> replaceInstructions(
    WidgetTester tester,
    List<String> steps,
  ) async {
    await recipes.editRecipe(tester);
    await recipes.openStep(
      tester,
      l10n.stepSteps,
      find.byKey(const Key('instruction-input')),
    );
    await recipes.waitUntil(
      tester,
      () => recipes.instructionLines(tester).isNotEmpty,
      'the saved steps',
    );
    await recipes.removeAllInstructions(tester);
    for (final step in steps) {
      await recipes.addInstruction(tester, step);
    }
    await recipes.next(tester, find.byKey(const Key('media-add')));
    await recipes.finish(tester);
  }

  Future<void> assignToTeam(WidgetTester tester, String team) async {
    expect(find.byKey(const Key('brew-add-to-team')), findsOneWidget);
    expect(find.byKey(const Key('brew-remove-from-team')), findsNothing);
    await tester.tap(find.byKey(const Key('brew-add-to-team')));
    await tester.pump();
    final option = find.descendant(
      of: find.byType(SimpleDialog),
      matching: find.text(team),
    );
    await recipes.waitFor(tester, option, team);
    await tester.tap(option);
    await tester.pump();
    await recipes.waitFor(
      tester,
      find.byKey(const Key('brew-remove-from-team')),
      'remove from team',
      timeout: const Duration(seconds: 30),
    );
    expect(find.byKey(const Key('brew-add-to-team')), findsNothing);
  }

  Future<void> removeFromTeam(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('brew-remove-from-team')));
    await tester.pump();
    await recipes.waitFor(
      tester,
      find.byKey(const Key('brew-add-to-team')),
      'add to team',
      timeout: const Duration(seconds: 30),
    );
    expect(find.byKey(const Key('brew-remove-from-team')), findsNothing);
  }

  /// Share is visible to every reader. Edit, delete, and team moves follow
  /// the caller's role.
  void expectBrewActions(
    WidgetTester tester, {
    required bool canEdit,
    required bool canDelete,
    required bool onTeam,
  }) {
    expect(find.byKey(const Key('brew-share')), findsOneWidget);
    expect(
      find.byKey(const Key('brew-edit')),
      canEdit ? findsOneWidget : findsNothing,
    );
    expect(
      find.byKey(const Key('brew-delete')),
      canDelete ? findsOneWidget : findsNothing,
    );
    expect(
      find.byKey(const Key('brew-add-to-team')),
      !onTeam && canDelete ? findsOneWidget : findsNothing,
    );
    expect(
      find.byKey(const Key('brew-remove-from-team')),
      onTeam && (canDelete || canEdit) ? findsOneWidget : findsNothing,
    );
  }

  /// A viewer who opens the editor is sent back to Brew Mode with no edit
  /// controls. The redirect can finish inside one frame, so the editor is
  /// recorded before the next pump.
  Future<void> expectEditRouteIsReadOnly(WidgetTester tester) async {
    final path = uri(tester).path;
    expect(path, startsWith('/recipes/'));
    final router = tester
        .widget<app.BrewSyncApp>(find.byType(app.BrewSyncApp))
        .router;
    var sawEdit = false;
    void record() {
      if (router.state.uri.path.endsWith('/edit')) sawEdit = true;
    }

    router.routerDelegate.addListener(record);
    try {
      router.go('$path/edit');
      await tester.pump();
      if (find.byType(RecipeWizardScreen).evaluate().isNotEmpty) {
        sawEdit = true;
      }
      record();

      final deadline = DateTime.now().add(const Duration(seconds: 30));
      while (DateTime.now().isBefore(deadline)) {
        final backOnBrew =
            sawEdit &&
            find.byType(RecipeWizardScreen).evaluate().isEmpty &&
            find.byKey(const Key('brew-share')).evaluate().isNotEmpty &&
            find.byKey(const Key('brew-edit')).evaluate().isEmpty &&
            uri(tester).path == path;
        if (backOnBrew) return;
        await tester.pump(const Duration(milliseconds: 50));
        if (find.byType(RecipeWizardScreen).evaluate().isNotEmpty) {
          sawEdit = true;
        }
        record();
      }
      fail(
        'Viewer edit route stayed at ${uri(tester)}. '
        'Editor route appeared: $sawEdit.',
      );
    } finally {
      router.routerDelegate.removeListener(record);
    }
  }

  Future<void> expectRecipeHidden(WidgetTester tester, String title) async {
    await recipes.waitFor(
      tester,
      find.text(l10n.recipeNotFoundOrUnshared).hitTestable(),
      'the hidden-recipe message',
      timeout: const Duration(seconds: 30),
    );
    expect(find.text(title).hitTestable(), findsNothing);
    expect(find.byKey(const Key('brew-share')), findsNothing);
    expect(find.byKey(const Key('brew-edit')), findsNothing);
  }

  Future<void> leaveHiddenRecipe(WidgetTester tester) async {
    await tester.tap(
      find.widgetWithText(FilledButton, l10n.back).hitTestable(),
    );
    await tester.pump();
    await recipes.waitUntil(
      tester,
      () => find.byType(BrewModeScreen).hitTestable().evaluate().isEmpty,
      'the journal',
    );
  }

  Future<void> expectJournalDoesNotList(
    WidgetTester tester,
    String title,
  ) async {
    await recipes.waitFor(
      tester,
      find.text(l10n.noRecipesYet).hitTestable(),
      'an empty journal',
    );
    expect(find.text(title).hitTestable(), findsNothing);
  }

  Future<void> signOutViaJournal(WidgetTester tester) async {
    if (find.byType(BrewModeScreen).hitTestable().evaluate().isNotEmpty ||
        find.byType(RecipeWizardScreen).hitTestable().evaluate().isNotEmpty) {
      await recipes.backToJournal(tester);
    }
    if (find
        .byKey(const ValueKey('sign-out'))
        .hitTestable()
        .evaluate()
        .isEmpty) {
      await openMyRecipes(tester);
    }
    await auth.signOut(tester);
  }

  Future<void> go(WidgetTester tester, String location) async {
    tester
        .widget<app.BrewSyncApp>(find.byType(app.BrewSyncApp))
        .router
        .go(location);
    await tester.pump();
  }

  Uri uri(WidgetTester tester) {
    return tester
        .widget<app.BrewSyncApp>(find.byType(app.BrewSyncApp))
        .router
        .state
        .uri;
  }

  String invitePath(String url) => Uri.parse(url).path;

  String inviteToken(String url) => Uri.parse(url).pathSegments.last;

  Future<void> _saveRecipe(
    WidgetTester tester, {
    required String title,
    required String bean,
    required List<String> instructions,
  }) async {
    await recipes.registerBean(tester, bean);
    await recipes.next(tester, find.text(l10n.brewParameters));
    await recipes.fillBrewParameters(tester, title: title);
    await recipes.next(tester, find.text(l10n.flavorMap));
    await recipes.next(tester, find.text(l10n.extraSteps));
    if (instructions.isEmpty) {
      await recipes.skipInstructions(tester);
    } else {
      for (final step in instructions) {
        await recipes.addInstruction(tester, step);
      }
      await recipes.next(tester, find.byKey(const Key('media-add')));
    }
    await recipes.finish(tester);
  }

  Future<void> _selectTab(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(label),
      ),
    );
    await tester.pump();
  }

  Future<void> _expectInviteOutcome(
    WidgetTester tester,
    String message, {
    required bool openTeam,
  }) async {
    await recipes.waitFor(
      tester,
      find.text(message).hitTestable(),
      message,
      timeout: const Duration(seconds: 30),
    );
    expect(
      find.text(l10n.openTeam).hitTestable(),
      openTeam ? findsOneWidget : findsNothing,
    );
    expect(
      find.text(l10n.goHome).hitTestable(),
      openTeam ? findsNothing : findsOneWidget,
    );
  }

  Finder _dialogButton(String label) {
    return find.descendant(
      of: find.byType(AlertDialog),
      matching: find.widgetWithText(FilledButton, label),
    );
  }

  String? _inviteUrl(WidgetTester tester) {
    final finder = find.byKey(const Key('invite-url'));
    if (finder.evaluate().isEmpty) return null;
    return tester.widget<SelectableText>(finder).data;
  }
}
