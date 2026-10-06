import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

/// Saves the signed-in user's preferred name.
///
/// [UserProfile.userName] is the first name or nickname. [UserProfile.fullName]
/// is a separate full name. Email registration creates the profile with only
/// the email, so sign-up writes the preferred name here.
class UserProfileEditEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  final UserProfiles _profiles = const UserProfiles();

  /// Stores [userName] as the signed-in user's preferred name.
  ///
  /// Blank values are rejected. Surrounding whitespace is removed.
  Future<UserProfileModel> changeUserName(
    Session session,
    String userName,
  ) async {
    final trimmed = userName.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(
        userName,
        'userName',
        'must not be empty',
      );
    }
    final authUserId = session.authenticated!.authUserId;
    return _profiles.changeUserName(session, authUserId, trimmed);
  }
}
