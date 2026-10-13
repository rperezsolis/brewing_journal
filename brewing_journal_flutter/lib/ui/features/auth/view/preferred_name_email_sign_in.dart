import 'dart:async';
import 'dart:math' as math;

import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../../../core/analytics/screen_names.dart';
import '../../../core/analytics/tracked_button.dart';
import '../../../core/l10n.dart';

/// Email sign-in that asks for a preferred name before creating an account.
///
/// The name is kept on this widget through verification and password setup,
/// then stored as [UserProfile.userName] once registration finishes.
///
/// Extends [EmailSignInWidget] so [SignInWidget] can place it in the email slot.
class PreferredNameEmailSignIn extends EmailSignInWidget {
  const PreferredNameEmailSignIn({
    required Client client,
    super.onError,
    super.key,
  }) : journalClient = client,
       super(client: client);

  /// Project client, which can update the signed-in profile.
  final Client journalClient;

  @override
  State<PreferredNameEmailSignIn> createState() =>
      _PreferredNameEmailSignInState();
}

class _PreferredNameEmailSignInState extends State<PreferredNameEmailSignIn> {
  late final EmailAuthController _controller;
  late final TextEditingController _preferredName;

  @override
  void initState() {
    super.initState();
    _preferredName = TextEditingController()..addListener(_rebuild);
    _controller = EmailAuthController(
      client: widget.journalClient,
      startScreen: EmailFlowScreen.login,
      onAuthenticated: _onAuthenticated,
      onError: (error) => widget.onError?.call(error),
    )..addListener(_rebuild);
  }

  @override
  void dispose() {
    _controller.removeListener(_rebuild);
    _preferredName.removeListener(_rebuild);
    _preferredName.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  void _onAuthenticated() {
    if (_controller.currentScreen != EmailFlowScreen.completeRegistration) {
      return;
    }
    final name = _preferredName.text.trim();
    if (name.isEmpty) return;

    final client = widget.journalClient;
    final report = widget.onError;
    unawaited(() async {
      try {
        await client.userProfileEdit.changeUserName(name);
      } catch (error) {
        report?.call(error);
      }
    }());
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.currentScreen != EmailFlowScreen.startRegistration) {
      return EmailSignInWidget(controller: _controller);
    }
    return _PreferredNameRegistrationForm(
      controller: _controller,
      preferredName: _preferredName,
    );
  }
}

class _PreferredNameRegistrationForm extends StatelessWidget {
  const _PreferredNameRegistrationForm({
    required this.controller,
    required this.preferredName,
  });

  final EmailAuthController controller;
  final TextEditingController preferredName;

  @override
  Widget build(BuildContext context) {
    final texts = context.emailSignInTexts;
    final l10n = context.l10n;
    final name = preferredName.text.trim();
    final canContinue =
        name.isNotEmpty &&
        controller.emailController.text.isNotEmpty &&
        controller.state == EmailAuthState.idle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          texts.signUpTitle,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 24),
        TextField(
          key: const ValueKey('preferred-name'),
          controller: preferredName,
          enabled: !controller.isLoading,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: l10n.authPreferredName,
            contentPadding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller.emailController,
          enabled: !controller.isLoading,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: texts.emailLabel,
            contentPadding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            errorText: controller.error is InvalidEmailException
                ? controller.errorMessage
                : null,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'[\s()<>[\]\\,;:]')),
            _LowerCaseTextFormatter(),
          ],
        ),
        const SizedBox(height: 24),
        TrackedButton(
          buttonLabel: 'continue',
          buttonAction: 'start_registration',
          currentScreen: ScreenNames.signIn,
          onPressed: controller.isLoading || !canContinue
              ? null
              : () => unawaited(controller.startRegistration()),
          builder: (context, onPressed) => ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              backgroundColor: Theme.of(context).colorScheme.primary,
              textStyle: Theme.of(context).textTheme.bodyLarge,
              shape: const StadiumBorder(),
              fixedSize: const Size(double.infinity, 48),
            ),
            onPressed: onPressed,
            child: controller.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(texts.continueAction),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(texts.alreadyHaveAnAccount),
            const SizedBox(width: 4),
            _LinkButton(
              label: texts.signIn,
              buttonLabel: 'sign_in',
              buttonAction: 'open_sign_in',
              onPressed: () => controller.navigateTo(EmailFlowScreen.login),
            ),
          ],
        ),
      ],
    );
  }
}

class _LinkButton extends StatelessWidget {
  const _LinkButton({
    required this.label,
    required this.buttonLabel,
    required this.buttonAction,
    required this.onPressed,
  });

  final String label;
  final String buttonLabel;
  final String buttonAction;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final fontSize = Theme.of(context).textTheme.bodyMedium?.fontSize ?? 0;
    return SizedBox(
      height: math.max(24, fontSize),
      child: TrackedButton(
        buttonLabel: buttonLabel,
        buttonAction: buttonAction,
        currentScreen: ScreenNames.signIn,
        onPressed: onPressed,
        builder: (context, onPressed) => TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toLowerCase());
  }
}
