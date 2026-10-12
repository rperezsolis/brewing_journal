import 'dart:async';

import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/team_repository.dart';
import '../../../core/analytics/screen_names.dart';
import '../../../core/analytics/tracked_button.dart';
import '../../../core/brewing_labels.dart';
import '../../../core/error_messages.dart';
import '../../../core/l10n.dart';
import '../cubit/team_members_cubit.dart';
import '../cubit/team_members_state.dart';
import '../cubit/teams_cubit.dart';
import 'change_role_dialog.dart';

class TeamMembersScreen extends StatelessWidget {
  const TeamMembersScreen({super.key, required this.teamId});

  final UuidValue teamId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TeamMembersCubit(context.read<TeamRepository>(), teamId: teamId)
            ..load(),
      child: _TeamMembersView(teamId: teamId),
    );
  }
}

class _TeamMembersView extends StatelessWidget {
  const _TeamMembersView({required this.teamId});

  final UuidValue teamId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final userId = context.read<AuthRepository>().currentUserId;
    final isOwner = context.select(
      (TeamsCubit cubit) =>
          cubit.state.teamById(teamId)?.team.ownerId == userId,
    );

    return BlocListener<TeamMembersCubit, TeamMembersState>(
      listenWhen: (previous, current) =>
          current.error != null &&
          current.error != previous.error &&
          current.status == TeamMembersStatus.success,
      listener: (context, state) {
        final error = state.error;
        if (error == null) return;
        final colors = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                errorMessage(
                  error,
                  context.l10n,
                  overrides: {
                    BrewingErrorCode.forbidden: l10n.cantChangeMemberRole,
                    BrewingErrorCode.notFound: l10n.teamNotFound,
                  },
                ),
                style: TextStyle(color: colors.onErrorContainer),
              ),
              backgroundColor: colors.errorContainer,
            ),
          );
      },
      child: BlocListener<TeamMembersCubit, TeamMembersState>(
        listenWhen: (previous, current) =>
            previous.revision != current.revision,
        listener: (context, state) {
          final mine = state.members
              .where((member) => member.userId == userId)
              .firstOrNull;
          final summary = context.read<TeamsCubit>().state.teamById(teamId);
          if (mine == null || summary == null || mine.role == summary.role) {
            return;
          }
          unawaited(context.read<TeamsCubit>().load());
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(l10n.teamMembers),
            leading: _backButton(context),
          ),
          body: BlocBuilder<TeamMembersCubit, TeamMembersState>(
            builder: (context, state) {
              if (state.members.isEmpty) {
                return switch (state.status) {
                  TeamMembersStatus.initial || TeamMembersStatus.loading =>
                    const Center(child: CircularProgressIndicator()),
                  TeamMembersStatus.failure => Center(
                    child: TrackedButton(
                      buttonLabel: 'retry',
                      buttonAction: 'reload_members',
                      currentScreen: ScreenNames.teamMembers,
                      onPressed: context.read<TeamMembersCubit>().load,
                      builder: (context, onPressed) => FilledButton(
                        onPressed: onPressed,
                        child: Text(
                          errorMessage(state.error ?? Object(), l10n),
                        ),
                      ),
                    ),
                  ),
                  TeamMembersStatus.success => Center(
                    child: Text(l10n.noTeamMembers),
                  ),
                };
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.members.length,
                itemBuilder: (context, index) {
                  final member = state.members[index];
                  return _MemberTile(
                    member: member,
                    isOwner: isOwner,
                    busy: state.changingUserId == member.userId,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget? _backButton(BuildContext context) {
    if (!Navigator.canPop(context)) return null;
    return TrackedButton(
      buttonLabel: 'back',
      buttonAction: 'navigate_back',
      currentScreen: ScreenNames.teamMembers,
      onPressed: () => Navigator.maybePop(context),
      builder: (context, onPressed) => BackButton(onPressed: onPressed),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.isOwner,
    required this.busy,
  });

  final TeamMember member;
  final bool isOwner;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = memberDisplayName(l10n, member.preferredName);
    final details = [
      if (member.email.isNotEmpty) member.email,
      member.role.label(l10n),
    ].join('\n');
    return ListTile(
      key: Key('team-member-${member.userId.uuid}'),
      title: Text(name),
      subtitle: Text(details),
      isThreeLine: member.email.isNotEmpty,
      trailing: isOwner
          ? TrackedButton(
              buttonLabel: 'edit_role',
              buttonAction: 'open_change_role_dialog',
              currentScreen: ScreenNames.teamMembers,
              onPressed: busy ? null : () => _edit(context, name),
              builder: (context, onPressed) => IconButton(
                key: Key('team-member-edit-${member.userId.uuid}'),
                tooltip: l10n.changeRole,
                icon: const Icon(Icons.edit_outlined),
                onPressed: onPressed,
              ),
            )
          : null,
    );
  }

  Future<void> _edit(BuildContext context, String name) async {
    final accepted = await showChangeRoleDialog(
      context,
      memberName: name,
      role: member.role,
    );
    if (!accepted || !context.mounted) return;
    final next = member.role == TeamRole.editor
        ? TeamRole.viewer
        : TeamRole.editor;
    await context.read<TeamMembersCubit>().changeRole(
      member,
      next,
      roleChangeLocale(context),
    );
  }
}

/// Preferred name, or the localized fallback when the profile has none.
String memberDisplayName(AppLocalizations l10n, String preferredName) {
  final name = preferredName.trim();
  if (name.isEmpty) return l10n.memberNameFallback;
  return name;
}
