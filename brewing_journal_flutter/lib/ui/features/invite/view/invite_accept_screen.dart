import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../router.dart';
import '../../../core/brewing_labels.dart';
import '../../../core/error_messages.dart';
import '../../teams/cubit/teams_cubit.dart';
import '../cubit/invite_accept_cubit.dart';
import '../cubit/invite_accept_state.dart';

class InviteAcceptScreen extends StatelessWidget {
  const InviteAcceptScreen({super.key, required this.token});

  final String token;

  static const _notFoundOverride = {
    BrewingErrorCode.notFound: 'Invite not found.',
  };

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InviteAcceptCubit(context.read())..accept(token),
      child: BlocBuilder<InviteAcceptCubit, InviteAcceptState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Team invite')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: switch (state.status) {
                  InviteAcceptStatus.accepting =>
                    const CircularProgressIndicator(),
                  InviteAcceptStatus.success => _Result(
                    title:
                        'You joined ${state.team!.team.name} as ${state.team!.role.label}.',
                    teamId: state.team!.team.id,
                  ),
                  InviteAcceptStatus.failure => _Result(
                    title: errorMessage(
                      state.error ?? Object(),
                      overrides: _notFoundOverride,
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
          FilledButton(
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
            child: const Text('Open team'),
          )
        else
          FilledButton(
            onPressed: () => context.go(Routes.home),
            child: const Text('Go home'),
          ),
      ],
    );
  }
}
