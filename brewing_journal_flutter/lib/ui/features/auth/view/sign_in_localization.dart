import 'package:brewing_journal_flutter/l10n/app_localizations.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

/// Literal token [PasswordRequirementTexts] replaces with the configured limit.
const authPasswordLengthToken = '{length}';

/// Shared sign-in copy for the active [AppLocalizations] catalog.
BasicSignInTexts basicSignInTextsFor(AppLocalizations l10n) {
  return BasicSignInTexts(
    noAuthenticationProvidersConfigured: l10n.authNoProviders,
    orContinueWith: l10n.authOrContinueWith,
  );
}

/// Email sign-in copy for the active [AppLocalizations] catalog.
EmailSignInTexts emailSignInTextsFor(AppLocalizations l10n) {
  return EmailSignInTexts(
    title: l10n.authSignInWithEmail,
    forgotPassword: l10n.authForgotPassword,
    signIn: l10n.authSignIn,
    dontHaveAnAccount: l10n.authDontHaveAnAccount,
    signUp: l10n.authCreateAccount,
    signUpTitle: l10n.authCreateAccount,
    continueAction: l10n.authContinue,
    alreadyHaveAnAccount: l10n.authAlreadyHaveAnAccount,
    verifyAccountTitle: l10n.authVerifyAccountTitle,
    verifyResetCodeTitle: l10n.authVerifyResetCodeTitle,
    verificationMessage: l10n.authVerificationMessage,
    verify: l10n.authVerify,
    setAccountPasswordTitle: l10n.authSetAccountPasswordTitle,
    passwordLabel: l10n.authPassword,
    backToSignUp: l10n.authBackToSignUp,
    setNewPasswordTitle: l10n.authSetNewPasswordTitle,
    newPasswordLabel: l10n.authNewPassword,
    resetPasswordTitle: l10n.authResetPasswordTitle,
    resetPasswordDescription: l10n.authResetPasswordDescription,
    requestPasswordReset: l10n.authRequestPasswordReset,
    resetPassword: l10n.authResetPassword,
    backToSignIn: l10n.authBackToSignIn,
    emailLabel: l10n.authEmail,
    termsIntro: l10n.authTermsIntro,
    termsAndConditions: l10n.authTermsAndConditions,
    andText: l10n.authAnd,
    privacyPolicy: l10n.authPrivacyPolicy,
  );
}

/// Password-rule labels for the active [AppLocalizations] catalog.
///
/// The auth widget replaces `{length}` itself, so the catalogs keep that token
/// as a placeholder value.
PasswordRequirementTexts passwordRequirementTextsFor(AppLocalizations l10n) {
  return PasswordRequirementTexts(
    minLengthTemplate: l10n.authPasswordMinLength(authPasswordLengthToken),
    maxLengthTemplate: l10n.authPasswordMaxLength(authPasswordLengthToken),
    containsLowercase: l10n.authPasswordLowercase,
    containsUppercase: l10n.authPasswordUppercase,
    containsNumber: l10n.authPasswordNumber,
    containsSpecialCharacter: l10n.authPasswordSpecial,
  );
}
