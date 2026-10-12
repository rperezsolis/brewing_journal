import 'package:brewing_journal_server/src/generated/protocol.dart';
import 'package:brewing_journal_server/src/teams/role_change_email.dart';
import 'package:test/test.dart';

void main() {
  const viewerSentence =
      'Viewers cannot add recipes to the team, remove them, or mark them as favorites.';

  RoleChangeEmailMessage notice({
    String locale = 'en',
    String preferredName = 'Ada',
    String recipient = 'ada@example.com',
    TeamRole from = TeamRole.editor,
    TeamRole to = TeamRole.viewer,
  }) {
    return composeRoleChangeEmail(
      recipient: recipient,
      locale: locale,
      preferredName: preferredName,
      teamName: 'Shop Recipes',
      from: from,
      to: to,
    )!;
  }

  test('english notice names the team and the viewer limits', () {
    final message = notice();
    expect(message.locale, 'en');
    expect(message.subject, 'Your role on Shop Recipes changed');
    expect(message.text, contains('Hello Ada'));
    expect(message.text, contains('from Editor to Viewer'));
    expect(message.text, contains(viewerSentence));
  });

  test('spanish and latin american spanish share the editor sentence', () {
    const sentence =
        'Los editores pueden agregar recetas al equipo, quitarlas y marcarlas como favoritas.';
    for (final locale in ['es', 'es_419']) {
      final message = notice(
        locale: locale,
        from: TeamRole.viewer,
        to: TeamRole.editor,
      );
      expect(message.locale, locale);
      expect(message.subject, 'Tu rol en Shop Recipes cambió');
      expect(message.text, contains('de Lector a Editor'));
      expect(message.text, contains(sentence));
    }
  });

  test('portuguese tags share the viewer sentence', () {
    const sentence =
        'Leitores não podem adicionar receitas à equipe, removê-las nem marcá-las como favoritas.';
    for (final locale in ['pt', 'pt_BR', 'pt-BR']) {
      final message = notice(locale: locale);
      expect(message.text, contains('de Editor para Leitor'));
      expect(message.text, contains(sentence));
    }
    expect(notice(locale: 'pt-BR').locale, 'pt_BR');
  });

  test('an unknown locale uses english', () {
    final message = notice(locale: 'fr');
    expect(message.locale, 'en');
    expect(message.text, contains(viewerSentence));
  });

  test('a blank preferred name uses the localized fallback', () {
    expect(notice(preferredName: '  ').text, contains('Hello Member'));
    expect(
      notice(locale: 'es', preferredName: '').text,
      contains('Hola Miembro'),
    );
    expect(
      notice(locale: 'pt', preferredName: '').text,
      contains('Olá Membro'),
    );
  });

  test('a blank email is not sent', () {
    expect(
      composeRoleChangeEmail(
        recipient: '   ',
        locale: 'en',
        preferredName: 'Ada',
        teamName: 'Shop Recipes',
        from: TeamRole.editor,
        to: TeamRole.viewer,
      ),
      isNull,
    );
  });
}
