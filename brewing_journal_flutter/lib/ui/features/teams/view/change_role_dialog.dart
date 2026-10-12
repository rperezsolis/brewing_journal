import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:flutter/material.dart';

import '../../../core/analytics/screen_names.dart';
import '../../../core/analytics/tracked_button.dart';
import '../../../core/l10n.dart';

/// Asks the owner to switch [role] to the other team role.
///
/// Returns true only when the owner chooses Yes.
Future<bool> showChangeRoleDialog(
  BuildContext context, {
  required String memberName,
  required TeamRole role,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => ChangeRoleDialog(memberName: memberName, role: role),
  ).then((accepted) => accepted ?? false);
}

class ChangeRoleDialog extends StatelessWidget {
  const ChangeRoleDialog({
    super.key,
    required this.memberName,
    required this.role,
  });

  final String memberName;
  final TeamRole role;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final message = role == TeamRole.editor
        ? l10n.changeRoleToViewer(memberName)
        : l10n.changeRoleToEditor(memberName);
    return AlertDialog(
      title: Text(l10n.changeRole),
      content: Text(message),
      actions: [
        TrackedButton(
          buttonLabel: 'no',
          buttonAction: 'dismiss_role_change',
          currentScreen: ScreenNames.teamMembers,
          onPressed: () => Navigator.of(context).pop(false),
          builder: (context, onPressed) => TextButton(
            key: const Key('change-role-no'),
            onPressed: onPressed,
            child: Text(l10n.no),
          ),
        ),
        TrackedButton(
          buttonLabel: 'yes',
          buttonAction: 'confirm_role_change',
          currentScreen: ScreenNames.teamMembers,
          onPressed: () => Navigator.of(context).pop(true),
          builder: (context, onPressed) => TextButton(
            key: const Key('change-role-yes'),
            onPressed: onPressed,
            child: Text(l10n.yes),
          ),
        ),
      ],
    );
  }
}

/// Language tag sent with a role change (`en`, `es_419`, `pt_BR`).
String roleChangeLocale(BuildContext context) {
  return Localizations.localeOf(context).toLanguageTag().replaceAll('-', '_');
}
