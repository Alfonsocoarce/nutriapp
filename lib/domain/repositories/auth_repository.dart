abstract class AuthRepository {
  /// Returns the id of the app's single local user, creating it on first
  /// launch. There is no login/registration — this is a single-person,
  /// on-device app, so the "session" is just whichever user row already
  /// exists locally.
  Future<int> ensureLocalUser();
}
