import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'role_change_smtp.dart';

/// A role-change notice ready to deliver.
class RoleChangeEmailMessage {
  const RoleChangeEmailMessage({
    required this.recipient,
    required this.subject,
    required this.text,
    required this.locale,
  });

  final String recipient;
  final String subject;
  final String text;
  final String locale;
}

/// Messages recorded while the server runs tests. Production does not use it.
abstract final class RoleChangeEmailOutbox {
  static final messages = <RoleChangeEmailMessage>[];
}

/// Builds the notice, or returns null when [recipient] has no address.
///
/// [locale] is a language tag with `-` already acceptable (`en`, `es_419`).
/// Unknown tags use English. `es` and `es_419` share Spanish. `pt` and
/// `pt_BR` share Portuguese.
RoleChangeEmailMessage? composeRoleChangeEmail({
  required String recipient,
  required String locale,
  required String preferredName,
  required String teamName,
  required TeamRole from,
  required TeamRole to,
}) {
  final email = recipient.trim();
  if (email.isEmpty) return null;

  final tag = _normalizeLocale(locale);
  final name = _displayName(tag, preferredName);
  final fromLabel = _roleLabel(tag, from);
  final toLabel = _roleLabel(tag, to);
  final capability = _capability(tag, to);
  final copy = _copy(tag);

  return RoleChangeEmailMessage(
    recipient: email,
    locale: tag,
    subject: copy.subject(teamName),
    text: copy.body(
      name: name,
      team: teamName,
      from: fromLabel,
      to: toLabel,
      capability: capability,
    ),
  );
}

/// Logs the notice and, outside tests, sends it when SMTP is configured.
///
/// A missing address is the caller's concern: pass a composed message.
/// A send failure is logged and does not throw, so the role update stands.
Future<void> deliverRoleChangeEmail(
  Session session,
  RoleChangeEmailMessage message,
) async {
  final runMode = session.serverpod.runMode;
  if (runMode == ServerpodRunMode.test) {
    RoleChangeEmailOutbox.messages.add(message);
  }

  final rendered = '${message.subject}\n\n${message.text}';
  session.log(
    'Role change email to ${message.recipient} [${message.locale}]\n$rendered',
    level: LogLevel.info,
  );
  if (runMode == ServerpodRunMode.development) {
    session.alert(
      'Role change email for ${message.recipient}: <${message.subject}>',
    );
  }
  if (runMode == ServerpodRunMode.test) return;

  await _sendSmtp(session, message);
}

String _normalizeLocale(String raw) {
  final tag = raw.trim().replaceAll('-', '_');
  return switch (tag) {
    'en' || 'es' || 'es_419' || 'pt' || 'pt_BR' => tag,
    _ => 'en',
  };
}

String _displayName(String locale, String preferredName) {
  final name = preferredName.trim();
  if (name.isNotEmpty) return name;
  return switch (locale) {
    'es' || 'es_419' => 'Miembro',
    'pt' || 'pt_BR' => 'Membro',
    _ => 'Member',
  };
}

String _roleLabel(String locale, TeamRole role) {
  if (role == TeamRole.editor) return 'Editor';
  return switch (locale) {
    'es' || 'es_419' => 'Lector',
    'pt' || 'pt_BR' => 'Leitor',
    _ => 'Viewer',
  };
}

String _capability(String locale, TeamRole role) {
  final spanish = locale == 'es' || locale == 'es_419';
  final portuguese = locale == 'pt' || locale == 'pt_BR';
  if (role == TeamRole.viewer) {
    if (spanish) {
      return 'Los lectores no pueden agregar recetas al equipo, quitarlas ni marcarlas como favoritas.';
    }
    if (portuguese) {
      return 'Leitores não podem adicionar receitas à equipe, removê-las nem marcá-las como favoritas.';
    }
    return 'Viewers cannot add recipes to the team, remove them, or mark them as favorites.';
  }
  if (spanish) {
    return 'Los editores pueden agregar recetas al equipo, quitarlas y marcarlas como favoritas.';
  }
  if (portuguese) {
    return 'Editores podem adicionar receitas à equipe, removê-las e marcá-las como favoritas.';
  }
  return 'Editors can add recipes to the team, remove them, and mark them as favorites.';
}

typedef _Subject = String Function(String team);

class _Copy {
  const _Copy({required this.subject, required this.body});

  final _Subject subject;
  final String Function({
    required String name,
    required String team,
    required String from,
    required String to,
    required String capability,
  })
  body;
}

_Copy _copy(String locale) {
  if (locale == 'es' || locale == 'es_419') {
    return _Copy(
      subject: (team) => 'Tu rol en $team cambió',
      body:
          ({
            required name,
            required team,
            required from,
            required to,
            required capability,
          }) =>
              'Hola $name,\n\n'
              'Tu rol en $team cambió de $from a $to.\n\n'
              '$capability\n\n'
              '— Cata Café',
    );
  }
  if (locale == 'pt' || locale == 'pt_BR') {
    return _Copy(
      subject: (team) => 'Seu papel em $team mudou',
      body:
          ({
            required name,
            required team,
            required from,
            required to,
            required capability,
          }) =>
              'Olá $name,\n\n'
              'Seu papel em $team mudou de $from para $to.\n\n'
              '$capability\n\n'
              '— Cata Café',
    );
  }
  return _Copy(
    subject: (team) => 'Your role on $team changed',
    body:
        ({
          required name,
          required team,
          required from,
          required to,
          required capability,
        }) =>
            'Hello $name,\n\n'
            'Your role on $team changed from $from to $to.\n\n'
            '$capability\n\n'
            '— Cata Café',
  );
}

Future<void> _sendSmtp(Session session, RoleChangeEmailMessage message) async {
  final host = Serverpod.instance.getPassword('smtpHost');
  final username = Serverpod.instance.getPassword('smtpUsername');
  final password = Serverpod.instance.getPassword('smtpPassword');
  final fromAddress = Serverpod.instance.getPassword('smtpFromAddress');
  if (host == null ||
      username == null ||
      password == null ||
      fromAddress == null) {
    if (session.serverpod.runMode != ServerpodRunMode.development) {
      session.log(
        'Role change email to ${message.recipient} was not sent: SMTP is not configured.',
        level: LogLevel.warning,
      );
    }
    return;
  }

  final port =
      int.tryParse(Serverpod.instance.getPassword('smtpPort') ?? '') ?? 587;
  final useSsl = Serverpod.instance.getPassword('smtpUseSsl') == 'true';
  try {
    await deliverRoleChangeSmtp(
      host: host,
      port: port,
      username: username,
      password: password,
      useSsl: useSsl,
      fromAddress: fromAddress,
      recipient: message.recipient,
      subject: message.subject,
      text: message.text,
    );
  } catch (error, stackTrace) {
    session.log(
      'Failed to send role change email to ${message.recipient}.',
      level: LogLevel.error,
      exception: error,
      stackTrace: stackTrace,
    );
  }
}
