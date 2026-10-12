import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:brewing_journal_flutter/data/repositories/auth_repository.dart';
import 'package:brewing_journal_flutter/data/repositories/fake_auth_repository.dart';
import 'package:brewing_journal_flutter/data/repositories/fake_team_repository.dart';
import 'package:brewing_journal_flutter/data/repositories/team_repository.dart';
import 'package:brewing_journal_flutter/l10n/app_localizations.dart';
import 'package:brewing_journal_flutter/ui/features/teams/cubit/teams_cubit.dart';
import 'package:brewing_journal_flutter/ui/features/teams/view/team_members_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const viewerQuestion =
      "Do you want to change Ada's role from Editor to Viewer? Viewers cannot add recipes to the team, remove them, or mark them as favorites.";
  const editorQuestion =
      "Do you want to change Ada's role from Viewer to Editor? Editors can add recipes to the team, remove them, and mark them as favorites.";

  late FakeTeamRepository teams;
  late FakeAuthRepository auth;
  late TeamsCubit teamsCubit;
  late UuidValue teamId;
  late UuidValue adaId;

  setUp(() async {
    teams = FakeTeamRepository();
    auth = FakeAuthRepository(currentUserId: teams.ownerId);
    teamsCubit = TeamsCubit(teams);
    final team = await teams.create('Shop Recipes');
    teamId = team.team.id!;
    adaId = const Uuid().v7obj();
    teams.addMember(
      teamId: teamId,
      userId: adaId,
      preferredName: 'Ada',
      email: 'ada@example.com',
    );
    await teamsCubit.load();
  });

  tearDown(() => teamsCubit.close());

  Future<void> pumpMembers(
    WidgetTester tester, {
    Locale? locale,
  }) async {
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<TeamRepository>.value(value: teams),
          RepositoryProvider<AuthRepository>.value(value: auth),
        ],
        child: BlocProvider<TeamsCubit>.value(
          value: teamsCubit,
          child: MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: TeamMembersScreen(teamId: teamId),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  test('english dialog copy matches the product sentences', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(l10n.changeRoleToViewer('Ada'), viewerQuestion);
    expect(l10n.changeRoleToEditor('Ada'), editorQuestion);
    expect(l10n.yes, 'Yes');
    expect(l10n.no, 'No');
  });

  testWidgets('the owner sees name, email, and role, and No leaves the role', (
    tester,
  ) async {
    await pumpMembers(tester);

    expect(find.text('Ada'), findsOneWidget);
    expect(find.textContaining('ada@example.com'), findsOneWidget);
    expect(find.textContaining('Viewer'), findsWidgets);
    expect(
      find.byKey(Key('team-member-edit-${adaId.uuid}')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(Key('team-member-edit-${adaId.uuid}')));
    await tester.pumpAndSettle();
    expect(find.text(editorQuestion), findsOneWidget);

    await tester.tap(find.byKey(const Key('change-role-no')));
    await tester.pumpAndSettle();

    expect(find.text(editorQuestion), findsNothing);
    expect(teams.roleChangeEmails, isEmpty);
    expect(
      teams.members[teamId]!
          .singleWhere((member) => member.userId == adaId)
          .role,
      TeamRole.viewer,
    );
  });

  testWidgets('Yes switches the member to editor', (tester) async {
    await pumpMembers(tester);

    await tester.tap(find.byKey(Key('team-member-edit-${adaId.uuid}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('change-role-yes')));
    await tester.pump();
    await tester.pump();

    expect(
      teams.members[teamId]!
          .singleWhere((member) => member.userId == adaId)
          .role,
      TeamRole.editor,
    );
    expect(teams.roleChangeEmails.single.locale, 'en');
    expect(find.textContaining('Editor'), findsWidgets);
  });

  testWidgets('a member who is not the owner has no edit icon', (tester) async {
    auth.currentUserId = const Uuid().v7obj();
    await pumpMembers(tester);

    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('Owner'), findsOneWidget);
    expect(find.byIcon(Icons.edit_outlined), findsNothing);
  });

  testWidgets('the spanish dialog asks in spanish', (tester) async {
    await pumpMembers(tester, locale: const Locale('es'));

    await tester.tap(find.byKey(Key('team-member-edit-${adaId.uuid}')));
    await tester.pumpAndSettle();

    expect(
      find.text(
        '¿Quieres cambiar el rol de Ada de Lector a Editor? Los editores pueden agregar recetas al equipo, quitarlas y marcarlas como favoritas.',
      ),
      findsOneWidget,
    );
    expect(find.text('Sí'), findsOneWidget);
    expect(find.text('No'), findsOneWidget);
  });
}
