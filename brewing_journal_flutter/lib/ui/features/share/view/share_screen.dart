import 'dart:ui' as ui;

import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/services/share_service.dart';
import '../../../../router.dart';
import '../../../core/error_messages.dart';
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

  static const _overrides = {
    BrewingErrorCode.notFound: 'Recipe not found or no longer shared with you',
  };

  @override
  Widget build(BuildContext context) {
    final failure = error;
    final isNotFound =
        failure is BrewingException &&
        failure.code == BrewingErrorCode.notFound;
    return Scaffold(
      appBar: AppBar(title: const Text('Share')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                errorMessage(error, overrides: _overrides),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              if (isNotFound || onRetry == null)
                FilledButton(
                  onPressed: () => context.canPop()
                      ? context.pop()
                      : context.go(Routes.home),
                  child: const Text('Back'),
                )
              else
                FilledButton(onPressed: onRetry, child: const Text('Retry')),
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
        _showMessage('Could not create the share image.');
        return;
      }
      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (!mounted) return;
      if (data == null) {
        cubit.abortRender();
        _showMessage('Could not create the share image.');
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
      _showMessage('Could not create the share image.');
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
                'Could not save the image.',
                style: TextStyle(color: colors.onErrorContainer),
              ),
              backgroundColor: colors.errorContainer,
              action: SnackBarAction(
                label: 'Retry',
                textColor: colors.onErrorContainer,
                onPressed: () => context.read<ShareCubit>().download(),
              ),
            ),
          );
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Share')),
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
                  final busy =
                      state.status == ShareStatus.rendering ||
                      state.status == ShareStatus.sharing;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (state.status == ShareStatus.unavailable) ...[
                        Text(
                          "Sharing isn't supported here — download the image instead",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          key: const Key('share-download'),
                          onPressed: () =>
                              context.read<ShareCubit>().download(),
                          icon: const Icon(Icons.download_outlined),
                          label: const Text('Download image'),
                        ),
                        const SizedBox(height: 8),
                      ],
                      FilledButton.icon(
                        key: _shareButtonKey,
                        onPressed: busy ? null : _share,
                        icon: busy
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.ios_share),
                        label: const Text('Share'),
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
