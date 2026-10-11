import 'package:brewing_journal_flutter/data/repositories/fake_team_repository.dart';
import 'package:brewing_journal_flutter/l10n/app_localizations.dart';
import 'package:brewing_journal_flutter/ui/features/teams/cubit/teams_cubit.dart';
import 'package:brewing_journal_flutter/ui/features/teams/view/invite_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeTeamRepository teams;
  late TeamsCubit cubit;

  setUp(() async {
    teams = FakeTeamRepository();
    cubit = TeamsCubit(teams);
    await teams.create('Morning crew');
    await cubit.load();
  });

  tearDown(() => cubit.close());

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('copies a localized invitation for $locale', (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      final team = cubit.state.teams.single;
      await tester.pumpWidget(
        BlocProvider<TeamsCubit>.value(
          value: cubit,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: locale,
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => showInviteSheet(context, team.team.id!),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('invite-create')));
      await tester.pumpAndSettle();

      final url = tester
          .widget<SelectableText>(find.byKey(const Key('invite-url')))
          .data!;
      await tester.tap(find.byKey(const Key('invite-copy')));
      await tester.pumpAndSettle();

      final l10n = lookupAppLocalizations(locale);
      expect(copied, l10n.inviteClipboardMessage(team.team.name, url));
      expect(copied, contains('\n\n$url'));
      expect(find.text(l10n.inviteLinkCopied), findsOneWidget);
    });
  }
}
