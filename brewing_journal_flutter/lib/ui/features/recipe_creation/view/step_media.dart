import 'dart:async';
import 'dart:typed_data';

import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/analytics/tracked_button.dart';
import '../../../core/l10n.dart';
import '../../../core/validation_messages.dart';
import 'wizard_screen_name.dart';
import '../cubit/recipe_creation_cubit.dart';
import '../cubit/recipe_creation_state.dart';
import '../photo_encoder.dart';
import '../recipe_limits.dart';

/// Step 5 (optional): photos of the cup, the crema, or the packaging.
class StepMedia extends StatefulWidget {
  const StepMedia({super.key, this.encodeWebp});

  /// Replaces the platform WebP encoder. Production leaves this null.
  final WebpEncoder? encodeWebp;

  @override
  State<StepMedia> createState() => _StepMediaState();
}

class _StepMediaState extends State<StepMedia> {
  /// Preview of the photo being uploaded.
  Uint8List? _pendingPreview;

  Future<void> _pickAndUpload() async {
    final cubit = context.read<RecipeCreationCubit>();
    final XFile? file;
    try {
      file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: kPhotoMaxEdge.toDouble(),
        maxHeight: kPhotoMaxEdge.toDouble(),
        imageQuality: kPhotoJpegQuality,
      );
    } catch (error, stackTrace) {
      _reportPickFailure(error, stackTrace);
      if (!mounted) return;
      cubit.reportError(error);
      return;
    }
    if (file == null || !mounted) return;

    final PreparedPhoto prepared;
    try {
      final raw = await file.readAsBytes();
      if (!mounted) return;
      prepared = await _prepareForUpload(raw);
    } on FormatException catch (error, stackTrace) {
      _reportPickFailure(error, stackTrace);
      if (!mounted) return;
      cubit.reportError(
        BrewingException(
          code: BrewingErrorCode.validation,
          message: validationMessage('photoFormat'),
        ),
      );
      return;
    } catch (error, stackTrace) {
      _reportPickFailure(error, stackTrace);
      if (!mounted) return;
      cubit.reportError(error);
      return;
    }
    if (!mounted) return;
    setState(() => _pendingPreview = Uint8List.sublistView(prepared.bytes));
    await cubit.addPhoto(prepared.bytes, contentType: prepared.contentType);
    if (mounted) setState(() => _pendingPreview = null);
  }

  /// JPEG and PNG upload as picked. Other formats are converted to WebP
  /// while a dialog explains the wait; the original bytes are not uploaded.
  Future<PreparedPhoto> _prepareForUpload(Uint8List raw) async {
    if (storesWithoutConversion(raw)) {
      return preparePhotoBytes(raw, encodeWebp: widget.encodeWebp);
    }

    final navigator = Navigator.of(context, rootNavigator: true);
    final route = DialogRoute<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PopScope(
        canPop: false,
        child: _ProcessingImagesDialog(),
      ),
    );
    unawaited(navigator.push(route));
    await WidgetsBinding.instance.endOfFrame;
    try {
      return await preparePhotoBytes(raw, encodeWebp: widget.encodeWebp);
    } finally {
      if (route.isActive && navigator.mounted) {
        navigator.removeRoute(route);
      }
    }
  }

  void _reportPickFailure(Object error, StackTrace stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'recipe photos',
        context: ErrorDescription('while picking or encoding a photo'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<RecipeCreationCubit>();
    return BlocBuilder<RecipeCreationCubit, RecipeCreationState>(
      buildWhen: (previous, current) =>
          previous.photos != current.photos ||
          previous.pendingUpload != current.pendingUpload ||
          previous.saveStatus != current.saveStatus,
      builder: (context, state) {
        final l10n = context.l10n;
        final canAdd =
            state.photos.length < kMaxPhotos &&
            !state.pendingUpload &&
            !state.isSaving;
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              sliver: SliverList.list(
                children: [
                  Text(l10n.photos, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    l10n.photosHelp(kMaxPhotos),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid.extent(
                maxCrossAxisExtent: 180,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: [
                  for (final photo in state.photos)
                    _PhotoTile(
                      key: ValueKey(photo.id),
                      photo: photo,
                      onRemove: state.pendingUpload
                          ? null
                          : () => cubit.removePhoto(photo.id!),
                    ),
                  if (state.pendingUpload && _pendingPreview != null)
                    _PendingTile(bytes: _pendingPreview!),
                  if (canAdd)
                    _AddTile(
                      key: const Key('media-add'),
                      onTap: _pickAndUpload,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProcessingImagesDialog extends StatelessWidget {
  const _ProcessingImagesDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            context.l10n.processingImages,
            key: const Key('processing-images'),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({super.key, required this.photo, required this.onRemove});

  final RecipePhoto photo;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final url = photo.publicUrl;
    final placeholder = ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Icon(Icons.local_cafe_outlined, color: colors.onSurfaceVariant),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (url == null)
            placeholder
          else
            Image.network(
              url.toString(),
              fit: BoxFit.cover,
              // Falls back to an <img> element on web when the storage URL
              // has no CORS headers for the app's origin.
              webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
              errorBuilder: (_, _, _) => placeholder,
            ),
          Positioned(
            top: 4,
            right: 4,
            child: TrackedButton(
              buttonLabel: 'remove_photo',
              buttonAction: 'remove_photo',
              currentScreen: wizardScreenName(context),
              onPressed: onRemove,
              builder: (context, onPressed) => IconButton.filledTonal(
                tooltip: context.l10n.removePhoto,
                icon: const Icon(Icons.close, size: 18),
                onPressed: onPressed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingTile extends StatelessWidget {
  const _PendingTile({required this.bytes});

  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(bytes, fit: BoxFit.cover),
          const ColoredBox(
            color: Colors.black45,
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
      child: TrackedButton(
        buttonLabel: 'add_photo',
        buttonAction: 'pick_photo',
        currentScreen: wizardScreenName(context),
        onPressed: onTap,
        builder: (context, onPressed) => InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo_outlined, color: colors.primary, size: 32),
              const SizedBox(height: 8),
              Text(context.l10n.addPhoto),
            ],
          ),
        ),
      ),
    );
  }
}
