import 'dart:typed_data';

import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/l10n.dart';
import '../../../core/validation_messages.dart';
import '../cubit/recipe_creation_cubit.dart';
import '../cubit/recipe_creation_state.dart';
import '../photo_encoder.dart';
import '../recipe_limits.dart';

/// Step 5 (optional): photos of the cup, the crema, or the packaging.
class StepMedia extends StatefulWidget {
  const StepMedia({super.key});

  @override
  State<StepMedia> createState() => _StepMediaState();
}

class _StepMediaState extends State<StepMedia> {
  /// Preview of the photo being uploaded.
  Uint8List? _pendingPreview;

  Future<void> _pickAndUpload() async {
    final cubit = context.read<RecipeCreationCubit>();
    final ByteData bytes;
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );
      if (file == null) return;
      bytes = await encodePhotoAsJpeg(file);
    } on FormatException catch (error, stackTrace) {
      _reportPickFailure(error, stackTrace);
      cubit.reportError(
        BrewingException(
          code: BrewingErrorCode.validation,
          message: validationMessage('photoFormat'),
        ),
      );
      return;
    } catch (error, stackTrace) {
      _reportPickFailure(error, stackTrace);
      cubit.reportError(error);
      return;
    }
    if (!mounted) return;
    setState(() => _pendingPreview = Uint8List.sublistView(bytes));
    await cubit.addPhoto(bytes);
    if (mounted) setState(() => _pendingPreview = null);
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
            child: IconButton.filledTonal(
              tooltip: context.l10n.removePhoto,
              icon: const Icon(Icons.close, size: 18),
              onPressed: onRemove,
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
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: colors.primary, size: 32),
            const SizedBox(height: 8),
            Text(context.l10n.addPhoto),
          ],
        ),
      ),
    );
  }
}
