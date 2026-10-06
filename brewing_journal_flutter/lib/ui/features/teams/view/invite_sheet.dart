import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/analytics/screen_names.dart';
import '../../../core/analytics/tracked_button.dart';
import '../../../core/error_messages.dart';
import '../../../core/l10n.dart';
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
                errorMessage(state.error!, context.l10n),
                style: TextStyle(color: colors.onErrorContainer),
              ),
              backgroundColor: colors.errorContainer,
            ),
          );
        },
        builder: (context, state) {
          final l10n = context.l10n;
          final invite = state.lastInvite;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.inviteToTeam,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              SegmentedButton<TeamRole>(
                key: const Key('invite-role'),
                segments: [
                  ButtonSegment(
                    value: TeamRole.viewer,
                    label: Text(l10n.roleViewer),
                    icon: const Icon(Icons.visibility_outlined),
                  ),
                  ButtonSegment(
                    value: TeamRole.editor,
                    label: Text(l10n.roleEditor),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ],
                selected: {_role},
                onSelectionChanged: state.creatingInvite
                    ? null
                    : (selected) {
                        final role = selected.first;
                        trackButtonPress(
                          context,
                          buttonLabel: 'invite_role',
                          buttonAction: 'select_${role.name}',
                          currentScreen: ScreenNames.teamDetail,
                          onPressed: () => setState(() => _role = role),
                        )?.call();
                      },
              ),
              const SizedBox(height: 12),
              SegmentedButton<Duration>(
                key: const Key('invite-ttl'),
                segments: [
                  ButtonSegment(
                    value: const Duration(hours: 1),
                    label: Text(l10n.inviteTtlOneHour),
                  ),
                  ButtonSegment(
                    value: const Duration(hours: 24),
                    label: Text(l10n.inviteTtlOneDay),
                  ),
                  ButtonSegment(
                    value: const Duration(days: 7),
                    label: Text(l10n.inviteTtlOneWeek),
                  ),
                ],
                selected: {_ttl},
                onSelectionChanged: state.creatingInvite
                    ? null
                    : (selected) {
                        final ttl = selected.first;
                        trackButtonPress(
                          context,
                          buttonLabel: 'invite_ttl',
                          buttonAction: _ttlAction(ttl),
                          currentScreen: ScreenNames.teamDetail,
                          onPressed: () => setState(() => _ttl = ttl),
                        )?.call();
                      },
              ),
              const SizedBox(height: 16),
              TrackedButton(
                buttonLabel: 'create_invite',
                buttonAction: 'create_invite',
                currentScreen: ScreenNames.teamDetail,
                onPressed: state.creatingInvite
                    ? null
                    : () => context.read<TeamsCubit>().createInvite(
                        widget.teamId,
                        _role,
                        _ttl,
                      ),
                builder: (context, onPressed) => FilledButton(
                  key: const Key('invite-create'),
                  onPressed: onPressed,
                  child: state.creatingInvite
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.create),
                ),
              ),
              if (invite != null) ...[
                const SizedBox(height: 16),
                SelectableText(invite.url, key: const Key('invite-url')),
                const SizedBox(height: 8),
                TrackedButton(
                  buttonLabel: 'copy_invite',
                  buttonAction: 'copy_invite_link',
                  currentScreen: ScreenNames.teamDetail,
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: invite.url));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.l10n.inviteLinkCopied)),
                    );
                  },
                  builder: (context, onPressed) => OutlinedButton.icon(
                    key: const Key('invite-copy'),
                    onPressed: onPressed,
                    icon: const Icon(Icons.copy),
                    label: Text(l10n.copyLink),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.singleUse,
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

String _ttlAction(Duration ttl) {
  return switch (ttl) {
    const Duration(hours: 1) => 'select_one_hour',
    const Duration(hours: 24) => 'select_one_day',
    const Duration(days: 7) => 'select_one_week',
    _ => 'select_ttl',
  };
}
