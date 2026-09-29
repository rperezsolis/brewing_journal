import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../data/services/share_service.dart';
import 'share_state.dart';

/// Renders a recipe card to a PNG and hands it to [ShareService].
///
/// Capture itself stays in the share screen: it needs the widget tree.
class ShareCubit extends Cubit<ShareState> {
  ShareCubit(this._share) : super(const ShareState());

  final ShareService _share;

  /// Marks the card as being painted. The view calls this before capture.
  void beginRender() {
    emit(state.copyWith(status: ShareStatus.rendering, clearError: true));
  }

  /// Returns to idle when capture fails before [share] is called.
  void abortRender() {
    if (isClosed) return;
    emit(state.copyWith(status: ShareStatus.idle, clearError: true));
  }

  /// Stores [png] and shares it. A dismissal returns to idle. An unavailable
  /// result or a thrown error shows the download fallback.
  Future<void> share(
    Uint8List png,
    String title, {
    Rect? sharePositionOrigin,
  }) async {
    emit(
      state.copyWith(
        status: ShareStatus.sharing,
        pngBytes: png,
        clearError: true,
      ),
    );
    try {
      final result = await _share.share(
        png,
        title,
        sharePositionOrigin: sharePositionOrigin,
      );
      if (isClosed) return;
      switch (result) {
        case ShareResultStatus.success:
          emit(state.copyWith(status: ShareStatus.shared));
        case ShareResultStatus.dismissed:
          emit(state.copyWith(status: ShareStatus.idle));
        case ShareResultStatus.unavailable:
          emit(state.copyWith(status: ShareStatus.unavailable));
      }
    } catch (error) {
      if (isClosed) return;
      emit(state.copyWith(status: ShareStatus.unavailable, error: error));
    }
  }

  /// Saves the last rendered PNG. A failure sets [ShareStatus.failure].
  Future<void> download() async {
    final bytes = state.pngBytes;
    if (bytes == null) {
      emit(
        state.copyWith(
          status: ShareStatus.failure,
          error: StateError('No image to download'),
        ),
      );
      return;
    }
    try {
      await _share.saveToDownloads(bytes);
      if (isClosed) return;
      emit(state.copyWith(status: ShareStatus.shared, clearError: true));
    } catch (error) {
      if (isClosed) return;
      emit(state.copyWith(status: ShareStatus.failure, error: error));
    }
  }
}
