import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error_messages.dart';
import '../cubit/teams_cubit.dart';
import '../cubit/teams_state.dart';

Future<void> showInviteSheet(BuildContext context, UuidValue teamId) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _InviteSheet(teamId: teamId),
  );
}

class _InviteSheet extends StatefulWidget {
  const _InviteSheet({required this.teamId});

  final UuidValue teamId;

  @override
  State<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends State<_InviteSheet> {
  var _role = TeamRole.viewer;
  var _ttl = const Duration(hours: 24);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        8,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: BlocConsumer<TeamsCubit, TeamsState>(
        listenWhen: (previous, current) =>
            current.error != null && previous.error != current.error,
        listener: (context, state) {
          final colors = Theme.of(context).colorScheme;
          ScaffoldMessenger.of(context).showSnackBar(
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
          final invite = state.lastInvite;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Invite to team',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              SegmentedButton<TeamRole>(
                segments: const [
                  ButtonSegment(
                    value: TeamRole.viewer,
                    label: Text('Viewer'),
                    icon: Icon(Icons.visibility_outlined),
                  ),
                  ButtonSegment(
                    value: TeamRole.editor,
                    label: Text('Editor'),
                    icon: Icon(Icons.edit_outlined),
                  ),
                ],
                selected: {_role},
                onSelectionChanged: state.creatingInvite
                    ? null
                    : (selected) => setState(() => _role = selected.first),
              ),
              const SizedBox(height: 12),
              SegmentedButton<Duration>(
                segments: const [
                  ButtonSegment(
                    value: Duration(hours: 1),
                    label: Text('1h'),
                  ),
                  ButtonSegment(
                    value: Duration(hours: 24),
                    label: Text('24h'),
                  ),
                  ButtonSegment(
                    value: Duration(days: 7),
                    label: Text('7d'),
                  ),
                ],
                selected: {_ttl},
                onSelectionChanged: state.creatingInvite
                    ? null
                    : (selected) => setState(() => _ttl = selected.first),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: state.creatingInvite
                    ? null
                    : () => context.read<TeamsCubit>().createInvite(
                        widget.teamId,
                        _role,
                        _ttl,
                      ),
                child: state.creatingInvite
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create'),
              ),
              if (invite != null) ...[
                const SizedBox(height: 16),
                SelectableText(invite.url),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: invite.url));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invite link copied')),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Single use',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
