import 'dart:typed_data';

import 'recipe_validator.dart';

const kJpegContentType = 'image/jpeg';
const kPngContentType = 'image/png';
const kWebpContentType = 'image/webp';

/// Maps an upload content type to the extension stored in the photo path.
///
/// Null and omitted types stay JPEG so older clients keep working.
String photoExtensionForContentType(String? contentType) =>
    switch (contentType) {
      null || kJpegContentType => 'jpg',
      kPngContentType => 'png',
      kWebpContentType => 'webp',
      _ => throw validationError(
        'contentType',
        'must be image/jpeg, image/png, or image/webp',
      ),
    };

/// Extension of a photo path this server issued, or null when it has none.
String? photoExtension(String path) =>
    RegExp(r'\.(jpg|png|webp)$').firstMatch(path)?.group(1);

String contentTypeForPhotoExtension(String extension) => switch (extension) {
  'png' => kPngContentType,
  'webp' => kWebpContentType,
  _ => kJpegContentType,
};

/// True when [bytes] match the format declared by [extension].
bool photoBytesMatchExtension(Uint8List bytes, String extension) =>
    switch (extension) {
      'jpg' => _isJpeg(bytes),
      'png' => _isPng(bytes),
      'webp' => _isWebp(bytes),
      _ => false,
    };

bool _isJpeg(Uint8List bytes) =>
    bytes.length >= 3 &&
    bytes[0] == 0xFF &&
    bytes[1] == 0xD8 &&
    bytes[2] == 0xFF;

bool _isPng(Uint8List bytes) =>
    bytes.length >= 8 &&
    bytes[0] == 0x89 &&
    bytes[1] == 0x50 &&
    bytes[2] == 0x4E &&
    bytes[3] == 0x47 &&
    bytes[4] == 0x0D &&
    bytes[5] == 0x0A &&
    bytes[6] == 0x1A &&
    bytes[7] == 0x0A;

bool _isWebp(Uint8List bytes) =>
    bytes.length >= 12 &&
    bytes[0] == 0x52 &&
    bytes[1] == 0x49 &&
    bytes[2] == 0x46 &&
    bytes[3] == 0x46 &&
    bytes[8] == 0x57 &&
    bytes[9] == 0x45 &&
    bytes[10] == 0x42 &&
    bytes[11] == 0x50;
