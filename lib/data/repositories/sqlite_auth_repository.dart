import '../../core/security/password_hasher.dart';
import '../../domain/repositories/auth_repository.dart';
import '../local/app_database.dart';

/// No login/registration: this is a single-person, on-device app, so
/// there's exactly one local user row, created transparently on first
/// launch. The email/password columns are legacy schema — filled with a
/// fixed placeholder, never shown or used to authenticate anything.
class SqliteAuthRepository implements AuthRepository {
  static const _localEmail = 'local@nutriapp.device';

  @override
  Future<int> ensureLocalUser() async {
    final db = await AppDatabase.instance.database;

    final existing = await db.query('app_users', limit: 1);
    if (existing.isNotEmpty) return existing.first['id'] as int;

    final salt = PasswordHasher.generateSalt();
    return db.insert('app_users', {
      'email': _localEmail,
      'password_hash': PasswordHasher.hash(salt, salt),
      'password_salt': salt,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
