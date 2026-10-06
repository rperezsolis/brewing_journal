import 'dart:ui' as ui;

import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/services/share_service.dart';
import '../../../../router.dart';
import '../../../core/analytics/screen_names.dart';
import '../../../core/analytics/tracked_button.dart';
import '../../../core/error_messages.dart';
import '../../../core/l10n.dart';
import '../../recipe_detail/cubit/recipe_detail_cubit.dart';
import '../../recipe_detail/cubit/recipe_detail_state.dart';
import '../cubit/share_cubit.dart';
import '../cubit/share_state.dart';
import 'recipe_share_card.dart';

/// Preview of the share card for [recipeId].
///
/// [initialDetail] is the recipe Brew Mode already loaded. A web refresh has
/// no extra, so the screen loads the recipe again.
class ShareScreen extends StatelessWidget {
  const ShareScreen({super.key, required this.recipeId, this.initialDetail});

  final UuidValue recipeId;
  final RecipeDetail? initialDetail;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ShareCubit(context.read<ShareService>()),
      child: initialDetail != null
          ? SharePreview(detail: initialDetail!)
          : BlocProvider(
              create: (context) =>
                  RecipeDetailCubit(context.read())..load(recipeId),
              child: const _LoadedSharePreview(),
            ),
    );
  }
}

class _LoadedSharePreview extends StatelessWidget {
  const _LoadedSharePreview();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecipeDetailCubit, RecipeDetailState>(
      builder: (context, state) {
        final detail = state.detail;
        if (detail != null) return SharePreview(detail: detail);
        if (state.status == RecipeDetailStatus.failure) {
          return _ShareLoadError(
            error: state.error ?? Object(),
            onRetry: state.recipeId == null
                ? null
                : () => context.read<RecipeDetailCubit>().load(state.recipeId!),
          );
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class _ShareLoadError extends StatelessWidget {
  const _ShareLoadError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final failure = error;
    final isNotFound =
        failure is BrewingException &&
        failure.code == BrewingErrorCode.notFound;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.share),
        leading: _shareBackButton(context),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                errorMessage(
                  error,
                  l10n,
                  overrides: {
                    BrewingErrorCode.notFound: l10n.recipeNotFoundOrUnshared,
                  },
                ),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              if (isNotFound || onRetry == null)
                TrackedButton(
                  buttonLabel: 'back',
                  buttonAction: 'leave_share',
                  currentScreen: ScreenNames.recipeShare,
                  onPressed: () => context.canPop()
                      ? context.pop()
                      : context.go(Routes.home),
                  builder: (context, onPressed) => FilledButton(
                    onPressed: onPressed,
                    child: Text(l10n.back),
                  ),
                )
              else
                TrackedButton(
                  buttonLabel: 'retry',
                  buttonAction: 'reload_recipe',
                  currentScreen: ScreenNames.recipeShare,
                  onPressed: onRetry,
                  builder: (context, onPressed) => FilledButton(
                    onPressed: onPressed,
                    child: Text(l10n.retry),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SharePreview extends StatefulWidget {
  const SharePreview({super.key, required this.detail});

  final RecipeDetail detail;

  @override
  State<SharePreview> createState() => _SharePreviewState();
}

class _SharePreviewState extends State<SharePreview> {
  final _cardKey = GlobalKey();
  final _shareButtonKey = GlobalKey();

  Rect? _sharePositionOrigin() {
    final box = _shareButtonKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  Future<void> _share() async {
    final origin = _sharePositionOrigin();
    final cubit = context.read<ShareCubit>();
    cubit.beginRender();
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    try {
      final boundary = _cardKey.currentContext?.findRenderObject();
      if (boundary is! RenderRepaintBoundary) {
        cubit.abortRender();
        _showMessage(context.l10n.couldNotCreateShareImage);
        return;
      }
      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (!mounted) return;
      if (data == null) {
        cubit.abortRender();
        _showMessage(context.l10n.couldNotCreateShareImage);
        return;
      }
      await cubit.share(
        data.buffer.asUint8List(),
        widget.detail.recipe.title,
        sharePositionOrigin: origin,
      );
    } catch (error) {
      if (!mounted) return;
      cubit.abortRender();
      _showMessage(context.l10n.couldNotCreateShareImage);
    }
  }

  void _showMessage(String message) {
    final colors = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(color: colors.onErrorContainer),
          ),
          backgroundColor: colors.errorContainer,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return BlocListener<ShareCubit, ShareState>(
      listenWhen: (previous, current) =>
          current.status == ShareStatus.failure &&
          previous.error != current.error,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                context.l10n.couldNotSaveImage,
                style: TextStyle(color: colors.onErrorContainer),
              ),
              backgroundColor: colors.errorContainer,
              action: SnackBarAction(
                label: context.l10n.retry,
                textColor: colors.onErrorContainer,
                onPressed: () {
                  trackButtonPress(
                    context,
                    buttonLabel: 'retry',
                    buttonAction: 'download_share_image',
                    currentScreen: ScreenNames.recipeShare,
                    onPressed: () => context.read<ShareCubit>().download(),
                  )?.call();
                },
              ),
            ),
          );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.share),
          leading: _shareBackButton(context),
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: FittedBox(
                    child: RepaintBoundary(
                      key: _cardKey,
                      child: RecipeShareCard(detail: widget.detail),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: BlocBuilder<ShareCubit, ShareState>(
                builder: (context, state) {
                  final l10n = context.l10n;
                  final busy =
                      state.status == ShareStatus.rendering ||
                      state.status == ShareStatus.sharing;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (state.status == ShareStatus.unavailable) ...[
                        Text(
                          l10n.sharingNotSupported,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        TrackedButton(
                          buttonLabel: 'download',
                          buttonAction: 'download_share_image',
                          currentScreen: ScreenNames.recipeShare,
                          onPressed: () =>
                              context.read<ShareCubit>().download(),
                          builder: (context, onPressed) => OutlinedButton.icon(
                            key: const Key('share-download'),
                            onPressed: onPressed,
                            icon: const Icon(Icons.download_outlined),
                            label: Text(l10n.downloadImage),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      TrackedButton(
                        buttonLabel: 'share',
                        buttonAction: 'share_recipe_image',
                        currentScreen: ScreenNames.recipeShare,
                        onPressed: busy ? null : _share,
                        builder: (context, onPressed) => KeyedSubtree(
                          key: const Key('share-submit'),
                          child: FilledButton.icon(
                            key: _shareButtonKey,
                            onPressed: onPressed,
                            icon: busy
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.ios_share),
                            label: Text(l10n.share),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget? _shareBackButton(BuildContext context) {
  if (!Navigator.canPop(context)) return null;
  return TrackedButton(
    buttonLabel: 'back',
    buttonAction: 'navigate_back',
    currentScreen: ScreenNames.recipeShare,
    onPressed: () => Navigator.maybePop(context),
    builder: (context, onPressed) => BackButton(onPressed: onPressed),
  );
}
