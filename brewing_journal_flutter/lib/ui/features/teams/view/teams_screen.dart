import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../../router.dart';
import '../../../core/brewing_labels.dart';
import '../../../core/error_messages.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../invite/invite_token.dart';
import '../cubit/teams_cubit.dart';
import '../cubit/teams_state.dart';

class TeamsScreen extends StatelessWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teams'),
        actions: [
          IconButton(
            tooltip: 'Join with invite',
            icon: const Icon(Icons.mail_outline),
            onPressed: () => _joinWithInvite(context),
          ),
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('teams-create'),
        onPressed: () => _createTeam(context),
        icon: const Icon(Icons.add),
        label: const Text('Create team'),
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
                  errorMessage(state.error!),
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
                  child: const Text('Retry'),
                ),
              ),
              TeamsStatus.success => const Center(
                child: Text('No teams yet. Create one or join with an invite.'),
              ),
            };
          }
          final userId = context.read<AuthRepository>().currentUserId;
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
                        ? 'Owner · ${summary.role.label}'
                        : summary.role.label,
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
    return AlertDialog(
      title: const Text('Create team'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 80,
        decoration: const InputDecoration(labelText: 'Name'),
        onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: const Text('Create'),
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
    return AlertDialog(
      title: const Text('Join with invite'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Invite URL or token',
        ),
        onSubmitted: (value) =>
            Navigator.of(context).pop(inviteTokenFromInput(value)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(inviteTokenFromInput(_controller.text)),
          child: const Text('Join'),
        ),
      ],
    );
  }
}
