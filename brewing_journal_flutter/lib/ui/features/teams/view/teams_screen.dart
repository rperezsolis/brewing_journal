import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../../router.dart';
import '../../../core/brewing_labels.dart';
import '../../../core/error_messages.dart';
import '../../../core/l10n.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../invite/invite_token.dart';
import '../cubit/teams_cubit.dart';
import '../cubit/teams_state.dart';

class TeamsScreen extends StatelessWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.teams),
        actions: [
          IconButton(
            tooltip: l10n.joinWithInvite,
            icon: const Icon(Icons.mail_outline),
            onPressed: () => _joinWithInvite(context),
          ),
          IconButton(
            tooltip: l10n.signOut,
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('teams-create'),
        onPressed: () => _createTeam(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.createTeam),
      ),
      body: BlocConsumer<TeamsCubit, TeamsState>(
        listenWhen: (previous, current) =>
            current.error != null && previous.error != current.error,
        listener: (context, state) {
          final colors = Theme.of(context).colorScheme;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  errorMessage(state.error!, context.l10n),
                  style: TextStyle(color: colors.onErrorContainer),
                ),
                backgroundColor: colors.errorContainer,
              ),
            );
        },
        builder: (context, state) {
          final cubit = context.read<TeamsCubit>();
          if (state.teams.isEmpty) {
            return switch (state.status) {
              TeamsStatus.initial || TeamsStatus.loading => const Center(
                child: CircularProgressIndicator(),
              ),
              TeamsStatus.failure => Center(
                child: FilledButton(
                  onPressed: cubit.load,
                  child: Text(context.l10n.retry),
                ),
              ),
              TeamsStatus.success => Center(
                child: Text(context.l10n.noTeamsYet),
              ),
            };
          }
          final userId = context.read<AuthRepository>().currentUserId;
          final l10n = context.l10n;
          return RefreshIndicator(
            onRefresh: cubit.load,
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 96),
              itemCount: state.teams.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final summary = state.teams[index];
                final owned = summary.team.ownerId == userId;
                return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.groups_outlined),
                  ),
                  title: Text(summary.team.name),
                  subtitle: Text(
                    owned
                        ? l10n.ownerRole(summary.role.label(l10n))
                        : summary.role.label(l10n),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(Routes.team(summary.team.id!)),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _createTeam(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => const _CreateTeamDialog(),
    );
    if (name == null || !context.mounted) return;
    await context.read<TeamsCubit>().create(name);
  }

  Future<void> _joinWithInvite(BuildContext context) async {
    final token = await showDialog<String>(
      context: context,
      builder: (context) => const _JoinInviteDialog(),
    );
    if (token == null || token.isEmpty || !context.mounted) return;
    await context.push(Routes.invite(token));
    if (!context.mounted) return;
    await context.read<TeamsCubit>().load();
  }
}

class _CreateTeamDialog extends StatefulWidget {
  const _CreateTeamDialog();

  @override
  State<_CreateTeamDialog> createState() => _CreateTeamDialogState();
}

class _CreateTeamDialogState extends State<_CreateTeamDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.createTeam),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 80,
        decoration: InputDecoration(labelText: l10n.nameLabel),
        onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: Text(l10n.create),
        ),
      ],
    );
  }
}

class _JoinInviteDialog extends StatefulWidget {
  const _JoinInviteDialog();

  @override
  State<_JoinInviteDialog> createState() => _JoinInviteDialogState();
}

class _JoinInviteDialogState extends State<_JoinInviteDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.joinWithInvite),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(labelText: l10n.inviteUrlOrToken),
        onSubmitted: (value) =>
            Navigator.of(context).pop(inviteTokenFromInput(value)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(inviteTokenFromInput(_controller.text)),
          child: Text(l10n.join),
        ),
      ],
    );
  }
}
