import 'dart:convert';
import 'dart:math';

/// 32 cryptographically random bytes, base64url without padding.
String generateInviteToken() {
  final bytes = List<int>.generate(32, (_) => Random.secure().nextInt(256));
  return base64Url.encode(bytes).replaceAll('=', '');
}
