import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../../../../client.dart';
import '../../../core/l10n.dart';
import 'preferred_name_email_sign_in.dart';
import 'sign_in_localization.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    void showError(Object error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // SignInWidget only forwards user-facing exceptions,
          // whose toString() is the message to display.
          content: Text(
            error.toString(),
            style: TextStyle(color: colors.onErrorContainer),
          ),
          backgroundColor: colors.errorContainer,
          duration: const Duration(seconds: 5),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        // The email flow is taller than a short window, so the page scrolls
        // there and stays centered on a tall one.
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                // SignInLocalizationProvider does not read Locale. Rebuilding
                // these text objects from context.l10n follows the active catalog.
                child: SignInLocalizationProvider(
                  basic: basicSignInTextsFor(l10n),
                  email: emailSignInTextsFor(l10n),
                  passwordRequirementTexts: passwordRequirementTextsFor(l10n),
                  child: SignInWidget(
                    client: client,
                    onError: showError,
                    emailSignInWidget: PreferredNameEmailSignIn(
                      client: client,
                      onError: showError,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
