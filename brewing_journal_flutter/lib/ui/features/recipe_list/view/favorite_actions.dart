import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:flutter/material.dart';

import '../../../core/error_messages.dart';
import '../../../core/l10n.dart';
import 'replace_favorite_dialog.dart';

/// Adds or removes [recipe] from favorites.
///
/// When the name is already saved, a dialog asks whether to replace that
/// favorite. [save] and [remove] talk to the cubit that owns the visible list
/// or the open recipe. [onChanged] updates any other list that is showing it.
Future<void> toggleRecipeFavorite({
  required BuildContext context,
  required Recipe recipe,
  required Future<FavoriteSaveResult?> Function({required bool replace}) save,
  required Future<bool> Function() remove,
  void Function({required bool isFavorite, UuidValue? replacedRecipeId})?
  onChanged,
  required void Function(Object error) onError,
  required Object? Function() readError,
}) async {
  final id = recipe.id;
  if (id == null) return;

  if (recipe.isFavorite) {
    final removed = await remove();
    if (!context.mounted) return;
    if (removed) {
      onChanged?.call(isFavorite: false);
      return;
    }
    _report(context, readError, onError);
    return;
  }

  final result = await save(replace: false);
  if (!context.mounted) return;
  if (result == null) {
    _report(context, readError, onError);
    return;
  }
  if (result.saved) {
    onChanged?.call(
      isFavorite: true,
      replacedRecipeId: result.replacedRecipeId,
    );
    return;
  }

  final replace = await showReplaceFavoriteDialog(context);
  if (!replace || !context.mounted) return;
  final replaced = await save(replace: true);
  if (!context.mounted) return;
  if (replaced == null) {
    _report(context, readError, onError);
    return;
  }
  if (replaced.saved) {
    onChanged?.call(
      isFavorite: true,
      replacedRecipeId: replaced.replacedRecipeId,
    );
  }
}

void _report(
  BuildContext context,
  Object? Function() readError,
  void Function(Object error) onError,
) {
  final error = readError();
  if (error != null) onError(error);
}

void showFavoriteError(BuildContext context, Object error) {
  final colors = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          errorMessage(error, context.l10n),
          style: TextStyle(color: colors.onErrorContainer),
        ),
        backgroundColor: colors.errorContainer,
      ),
    );
}
