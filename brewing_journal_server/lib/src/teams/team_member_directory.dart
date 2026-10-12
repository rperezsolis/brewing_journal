import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

/// Preferred name and email for one auth user.
class MemberIdentity {
  const MemberIdentity({required this.preferredName, required this.email});

  /// `UserProfile.userName`, trimmed, or empty when the profile has no name.
  final String preferredName;

  /// Profile email, then the email account, or empty when neither exists.
  final String email;
}

/// Loads [MemberIdentity] for each id. Missing profiles become empty fields.
Future<Map<UuidValue, MemberIdentity>> memberIdentities(
  Session session,
  Set<UuidValue> userIds, {
  Transaction? transaction,
}) async {
  if (userIds.isEmpty) return {};

  final profiles = await UserProfile.db.find(
    session,
    where: (t) => t.authUserId.inSet(userIds),
    transaction: transaction,
  );
  final byUser = {for (final profile in profiles) profile.authUserId: profile};

  final missingEmail = userIds.where((id) {
    final email = byUser[id]?.email?.trim();
    return email == null || email.isEmpty;
  }).toSet();
  final accounts = missingEmail.isEmpty
      ? const <EmailAccount>[]
      : await EmailAccount.db.find(
          session,
          where: (t) => t.authUserId.inSet(missingEmail),
          transaction: transaction,
        );
  final emailByUser = {
    for (final account in accounts) account.authUserId: account.email,
  };

  return {
    for (final id in userIds)
      id: MemberIdentity(
        preferredName: _preferredName(byUser[id]),
        email: _email(byUser[id], emailByUser[id]),
      ),
  };
}

String _preferredName(UserProfile? profile) {
  final name = profile?.userName?.trim();
  if (name == null || name.isEmpty) return '';
  return name;
}

String _email(UserProfile? profile, String? accountEmail) {
  final profileEmail = profile?.email?.trim();
  if (profileEmail != null && profileEmail.isNotEmpty) return profileEmail;
  final fallback = accountEmail?.trim();
  if (fallback != null && fallback.isNotEmpty) return fallback;
  return '';
}
