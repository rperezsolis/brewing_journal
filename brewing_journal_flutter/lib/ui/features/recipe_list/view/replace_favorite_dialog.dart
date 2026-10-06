import 'package:flutter/material.dart';

import '../../../core/analytics/tracked_button.dart';
import '../../../core/l10n.dart';

/// Asks whether to replace the favorite that already uses this recipe name.
///
/// Returns true only when the user accepts the replacement.
Future<bool> showReplaceFavoriteDialog(
  BuildContext context, {
  bool team = false,
  required String currentScreen,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => ReplaceFavoriteDialog(
      team: team,
      currentScreen: currentScreen,
    ),
  ).then((accepted) => accepted ?? false);
}

class ReplaceFavoriteDialog extends StatelessWidget {
  const ReplaceFavoriteDialog({
    super.key,
    this.team = false,
    required this.currentScreen,
  });

  /// Uses the team-favorites copy when the save belongs to a team.
  final bool team;

  /// Screen that opened the dialog, recorded with each button event.
  final String currentScreen;

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
          TrackedButton(
            buttonLabel: 'close',
            buttonAction: 'dismiss_favorite_conflict',
            currentScreen: currentScreen,
            onPressed: () => Navigator.of(context).pop(false),
            builder: (context, onPressed) => IconButton(
              key: const Key('favorite-conflict-close'),
              tooltip: l10n.close,
              icon: const Icon(Icons.close),
              onPressed: onPressed,
            ),
          ),
        ],
      ),
      content: Text(
        team ? l10n.favoriteNameTakenBodyTeam : l10n.favoriteNameTakenBody,
      ),
      actions: [
        TrackedButton(
          buttonLabel: 'cancel',
          buttonAction: 'dismiss_favorite_conflict',
          currentScreen: currentScreen,
          onPressed: () => Navigator.of(context).pop(false),
          builder: (context, onPressed) => TextButton(
            key: const Key('favorite-conflict-cancel'),
            onPressed: onPressed,
            child: Text(l10n.cancel),
          ),
        ),
        TrackedButton(
          buttonLabel: 'accept',
          buttonAction: 'replace_favorite',
          currentScreen: currentScreen,
          onPressed: () => Navigator.of(context).pop(true),
          builder: (context, onPressed) => FilledButton(
            key: const Key('favorite-conflict-accept'),
            onPressed: onPressed,
            child: Text(l10n.accept),
          ),
        ),
      ],
    );
  }
}
