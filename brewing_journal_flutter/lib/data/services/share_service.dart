import 'dart:typed_data';
import 'dart:ui';

import 'package:share_plus/share_plus.dart';

/// Hands a rendered recipe card to the platform share sheet, or saves the
/// same PNG when sharing is not available.
abstract class ShareService {
  /// Shares [bytes] as a PNG. Returns the platform result.
  ///
  /// [sharePositionOrigin] anchors the popover on iPad. It comes from the
  /// Share button's [RenderBox].
  Future<ShareResultStatus> share(
    Uint8List bytes,
    String title, {
    Rect? sharePositionOrigin,
  });

  /// Saves [bytes] as `brewsync-recipe.png`. On web this starts a download.
  Future<void> saveToDownloads(Uint8List bytes);
}

const shareImageName = 'brewsync-recipe.png';

/// [ShareService] backed by `share_plus`.
class SharePlusShareService implements ShareService {
  @override
  Future<ShareResultStatus> share(
    Uint8List bytes,
    String title, {
    Rect? sharePositionOrigin,
  }) async {
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            bytes,
            mimeType: 'image/png',
            name: shareImageName,
          ),
        ],
        // `XFile.name` is ignored off web; this keeps the PNG name everywhere.
        fileNameOverrides: const [shareImageName],
        subject: title,
        sharePositionOrigin: sharePositionOrigin,
        // The share screen shows its own download button when sharing is
        // unavailable. The plugin's web download and mailto fallbacks would
        // save or email the image before that button appears.
        downloadFallbackEnabled: false,
        mailToFallbackEnabled: false,
      ),
    );
    return result.status;
  }

  @override
  Future<void> saveToDownloads(Uint8List bytes) {
    return XFile.fromData(
      bytes,
      mimeType: 'image/png',
      name: shareImageName,
    ).saveTo(shareImageName);
  }
}

/// Records calls, for tests and previews.
class FakeShareService implements ShareService {
  ShareResultStatus nextStatus = ShareResultStatus.success;
  Object? shareError;
  Object? downloadError;

  int shareCount = 0;
  int downloadCount = 0;
  Uint8List? lastBytes;
  String? lastTitle;
  Rect? lastOrigin;

  @override
  Future<ShareResultStatus> share(
    Uint8List bytes,
    String title, {
    Rect? sharePositionOrigin,
  }) async {
    shareCount++;
    lastBytes = bytes;
    lastTitle = title;
    lastOrigin = sharePositionOrigin;
    final error = shareError;
    if (error != null) throw error;
    return nextStatus;
  }

  @override
  Future<void> saveToDownloads(Uint8List bytes) async {
    downloadCount++;
    lastBytes = bytes;
    final error = downloadError;
    if (error != null) throw error;
  }
}
