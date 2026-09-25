import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

const kPhotoMaxEdge = 2048;
const kPhotoJpegQuality = 85;

/// Reads a picked photo as JPEG bytes, since the server stores every photo
/// under a `.jpg` path. Web keeps PNG input as PNG, so anything that is not
/// already a JPEG is decoded, shrunk to [kPhotoMaxEdge], and re-encoded.
Future<ByteData> encodePhotoAsJpeg(XFile file) async {
  return encodeBytesAsJpeg(await file.readAsBytes());
}

ByteData encodeBytesAsJpeg(Uint8List bytes) {
  if (isJpeg(bytes)) return ByteData.sublistView(bytes);

  img.Image? image;
  try {
    image = img.decodeImage(bytes);
  } catch (_) {
    // Some decoders throw on truncated or unknown data instead of
    // returning null.
    image = null;
  }
  if (image == null) {
    throw const FormatException('This image format is not supported');
  }
  if (image.width > kPhotoMaxEdge || image.height > kPhotoMaxEdge) {
    image = image.width >= image.height
        ? img.copyResize(image, width: kPhotoMaxEdge)
        : img.copyResize(image, height: kPhotoMaxEdge);
  }
  return ByteData.sublistView(img.encodeJpg(image, quality: kPhotoJpegQuality));
}

/// Checks the JPEG magic bytes; `XFile.mimeType` is often null on mobile.
bool isJpeg(Uint8List bytes) =>
    bytes.length > 2 &&
    bytes[0] == 0xFF &&
    bytes[1] == 0xD8 &&
    bytes[2] == 0xFF;
