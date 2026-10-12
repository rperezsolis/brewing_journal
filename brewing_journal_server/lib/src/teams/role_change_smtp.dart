import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

/// Sends one plain-text notice through the configured SMTP server.
Future<void> deliverRoleChangeSmtp({
  required String host,
  required int port,
  required String username,
  required String password,
  required bool useSsl,
  required String fromAddress,
  required String recipient,
  required String subject,
  required String text,
}) {
  final server = SmtpServer(
    host,
    port: port,
    ssl: useSsl,
    username: username,
    password: password,
  );
  final mail = Message()
    ..from = Address(fromAddress, 'Cata Café')
    ..recipients.add(recipient)
    ..subject = subject
    ..text = text;
  return send(mail, server);
}
