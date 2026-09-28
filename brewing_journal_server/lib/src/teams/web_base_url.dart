import 'package:serverpod/serverpod.dart';

/// Public origin of the web server, used in invite URLs.
///
/// Omits the port when it is the scheme default (80 / 443). Throws if the
/// web server is not configured, so a broken `null` host is never issued.
String webBaseUrl(Session session) {
  final web = session.serverpod.config.webServer;
  if (web == null) {
    throw StateError(
      'Cannot build an invite URL: webServer is not configured.',
    );
  }
  final omitPort =
      (web.publicScheme == 'http' && web.publicPort == 80) ||
      (web.publicScheme == 'https' && web.publicPort == 443);
  final host = omitPort
      ? web.publicHost
      : '${web.publicHost}:${web.publicPort}';
  return '${web.publicScheme}://$host';
}
