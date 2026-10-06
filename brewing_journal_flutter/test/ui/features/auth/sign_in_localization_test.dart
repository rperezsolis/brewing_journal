import 'package:brewing_journal_flutter/l10n/app_localizations.dart';
import 'package:brewing_journal_flutter/ui/features/auth/view/sign_in_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('english sign-in labels match the auth widget copy', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    final email = emailSignInTextsFor(l10n);

    expect(email.title, 'Sign in with Email');
    expect(email.emailLabel, 'Email');
    expect(l10n.authPreferredName, 'Preferred name');
    expect(email.passwordLabel, 'Password');
    expect(email.forgotPassword, 'Forgot Password');
    expect(email.signUp, 'Create Account');
    expect(email.signUpTitle, 'Create Account');
    expect(
      passwordRequirementTextsFor(l10n).minLength(8),
      'At least 8 characters',
    );
  });

  test('spanish catalogs use Latin American Spanish', () {
    for (final locale in const [Locale('es'), Locale('es', '419')]) {
      final email = emailSignInTextsFor(lookupAppLocalizations(locale));
      expect(email.title, 'Iniciar sesión con correo electrónico');
      expect(email.emailLabel, 'Correo electrónico');
      expect(
        lookupAppLocalizations(locale).authPreferredName,
        'Nombre preferido',
      );
      expect(email.passwordLabel, 'Contraseña');
      expect(email.forgotPassword, 'Olvidé mi contraseña');
      expect(email.signUp, 'Crear cuenta');
    }
  });

  test('portuguese catalogs use Brazilian Portuguese', () {
    for (final locale in const [Locale('pt'), Locale('pt', 'BR')]) {
      final email = emailSignInTextsFor(lookupAppLocalizations(locale));
      expect(email.title, 'Entrar com e-mail');
      expect(email.emailLabel, 'E-mail');
      expect(
        lookupAppLocalizations(locale).authPreferredName,
        'Nome preferido',
      );
      expect(email.passwordLabel, 'Senha');
      expect(email.forgotPassword, 'Esqueci a senha');
      expect(email.signUp, 'Criar conta');
    }
  });
}
