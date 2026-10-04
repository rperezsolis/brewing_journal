import 'package:flutter/material.dart';

import '../../../core/l10n.dart';

/// Asks whether to replace the favorite that already uses this recipe name.
///
/// Returns true only when the user accepts the replacement.
Future<bool> showReplaceFavoriteDialog(
  BuildContext context, {
  bool team = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => ReplaceFavoriteDialog(team: team),
  ).then((accepted) => accepted ?? false);
}

class ReplaceFavoriteDialog extends StatelessWidget {
  const ReplaceFavoriteDialog({super.key, this.team = false});

  /// Uses the team-favorites copy when the save belongs to a team.
  final bool team;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 12, 8, 0),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                team
                    ? l10n.favoriteNameTakenTitleTeam
                    : l10n.favoriteNameTakenTitle,
              ),
            ),
          ),
          IconButton(
            key: const Key('favorite-conflict-close'),
            tooltip: l10n.close,
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
      content: Text(
        team ? l10n.favoriteNameTakenBodyTeam : l10n.favoriteNameTakenBody,
      ),
      actions: [
        TextButton(
          key: const Key('favorite-conflict-cancel'),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: const Key('favorite-conflict-accept'),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.accept),
        ),
      ],
    );
  }
}
