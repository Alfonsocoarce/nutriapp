import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/security/password_hasher.dart';
import '../../domain/repositories/auth_repository.dart';
import '../local/app_database.dart';

class SqliteAuthRepository implements AuthRepository {
  SqliteAuthRepository({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;
  static const _sessionUserIdKey = 'nutriapp_session_user_id';

  @override
  Future<int> register({required String email, required String password}) async {
    final db = await AppDatabase.instance.database;
    final normalizedEmail = email.trim().toLowerCase();

    final existing = await db.query(
      'app_users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
      limit: 1,
    );
    if (existing.isNotEmpty) throw EmailAlreadyExistsException();

    final salt = PasswordHasher.generateSalt();
    final hash = PasswordHasher.hash(password, salt);

    final userId = await db.insert('app_users', {
      'email': normalizedEmail,
      'password_hash': hash,
      'password_salt': salt,
      'created_at': DateTime.now().toIso8601String(),
    });

    await _secureStorage.write(key: _sessionUserIdKey, value: userId.toString());
    return userId;
  }

  @override
  Future<int> login({required String email, required String password}) async {
    final db = await AppDatabase.instance.database;
    final normalizedEmail = email.trim().toLowerCase();

    final rows = await db.query(
      'app_users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
      limit: 1,
    );
    if (rows.isEmpty) throw InvalidCredentialsException();

    final row = rows.first;
    final expectedHash =
        PasswordHasher.hash(password, row['password_salt'] as String);
    if (expectedHash != row['password_hash']) {
      throw InvalidCredentialsException();
    }

    final userId = row['id'] as int;
    await _secureStorage.write(key: _sessionUserIdKey, value: userId.toString());
    return userId;
  }

  @override
  Future<void> logout() async {
    await _secureStorage.delete(key: _sessionUserIdKey);
  }

  @override
  Future<int?> currentUserId() async {
    final value = await _secureStorage.read(key: _sessionUserIdKey);
    return value == null ? null : int.tryParse(value);
  }
}
