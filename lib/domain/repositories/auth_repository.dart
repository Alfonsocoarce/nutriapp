abstract class AuthRepository {
  /// Returns the new user's id. Throws [EmailAlreadyExistsException] if taken.
  Future<int> register({required String email, required String password});

  /// Returns the user's id on success. Throws [InvalidCredentialsException]
  /// otherwise.
  Future<int> login({required String email, required String password});

  Future<void> logout();

  /// The currently persisted session's user id, or null if logged out.
  Future<int?> currentUserId();
}

class EmailAlreadyExistsException implements Exception {}

class InvalidCredentialsException implements Exception {}
