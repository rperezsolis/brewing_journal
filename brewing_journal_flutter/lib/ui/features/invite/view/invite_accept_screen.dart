import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../router.dart';
import '../../../core/analytics/screen_names.dart';
import '../../../core/analytics/tracked_button.dart';
import '../../../core/brewing_labels.dart';
import '../../../core/error_messages.dart';
import '../../../core/l10n.dart';
import '../../teams/cubit/teams_cubit.dart';
import '../cubit/invite_accept_cubit.dart';
import '../cubit/invite_accept_state.dart';

class InviteAcceptScreen extends StatelessWidget {
  const InviteAcceptScreen({super.key, required this.token});

  final String token;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocProvider(
      create: (context) => InviteAcceptCubit(context.read())..accept(token),
      child: BlocBuilder<InviteAcceptCubit, InviteAcceptState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.teamInvite),
              leading: Navigator.canPop(context)
                  ? TrackedButton(
                      buttonLabel: 'back',
                      buttonAction: 'navigate_back',
                      currentScreen: ScreenNames.invite,
                      onPressed: () => Navigator.maybePop(context),
                      builder: (context, onPressed) =>
                          BackButton(onPressed: onPressed),
                    )
                  : null,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: switch (state.status) {
                  InviteAcceptStatus.accepting =>
                    const CircularProgressIndicator(),
                  InviteAcceptStatus.success => _Result(
                    title: l10n.youJoined(
                      state.team!.team.name,
                      state.team!.role.label(l10n),
                    ),
                    teamId: state.team!.team.id,
                  ),
                  InviteAcceptStatus.failure => _Result(
                    title: errorMessage(
                      state.error ?? Object(),
                      l10n,
                      overrides: {
                        BrewingErrorCode.notFound: l10n.inviteNotFound,
                      },
                    ),
                    teamId: state.errorCode == BrewingErrorCode.alreadyMember
                        ? state.team?.team.id
                        : null,
                    showOpenTeam:
                        state.errorCode == BrewingErrorCode.alreadyMember,
                  ),
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({
    required this.title,
    this.teamId,
    this.showOpenTeam = true,
  });

  final String title;
  final UuidValue? teamId;
  final bool showOpenTeam;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        if (showOpenTeam)
          TrackedButton(
            buttonLabel: 'open_team',
            buttonAction: 'open_team',
            currentScreen: ScreenNames.invite,
            onPressed: () async {
              await context.read<TeamsCubit>().load();
              if (!context.mounted) return;
              final id = teamId;
              if (id != null) {
                context.go(Routes.team(id));
              } else {
                context.go(Routes.teams);
              }
            },
            builder: (context, onPressed) => FilledButton(
              onPressed: onPressed,
              child: Text(context.l10n.openTeam),
            ),
          )
        else
          TrackedButton(
            buttonLabel: 'go_home',
            buttonAction: 'navigate_home',
            currentScreen: ScreenNames.invite,
            onPressed: () => context.go(Routes.home),
            builder: (context, onPressed) => FilledButton(
              onPressed: onPressed,
              child: Text(context.l10n.goHome),
            ),
          ),
      ],
    );
  }
}
