import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

/// Opens the app's single encrypted SQLite (SQLCipher) database.
///
/// The AES key is generated once, stored in the OS Keychain/Keystore via
/// [FlutterSecureStorage], and passed as the SQLCipher password on every
/// open — the on-disk .db file itself is unreadable without it.
class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const _secureStorage = FlutterSecureStorage();
  static const _dbKeyStorageKey = 'nutriapp_db_encryption_key';

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<String> _getOrCreateEncryptionKey() async {
    final existing = await _secureStorage.read(key: _dbKeyStorageKey);
    if (existing != null) return existing;

    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    final key = base64UrlEncode(bytes);
    await _secureStorage.write(key: _dbKeyStorageKey, value: key);
    return key;
  }

  Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'nutriapp_encrypted.db');
    final password = await _getOrCreateEncryptionKey();

    return openDatabase(
      dbPath,
      password: password,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE app_users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE NOT NULL,
            password_hash TEXT NOT NULL,
            password_salt TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE user_profiles (
            user_id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            birth_date TEXT NOT NULL,
            sex TEXT NOT NULL,
            height_cm REAL NOT NULL,
            current_weight_kg REAL NOT NULL,
            target_weight_kg REAL NOT NULL,
            activity_level TEXT NOT NULL,
            goals TEXT NOT NULL,
            restrictions TEXT NOT NULL,
            allergies TEXT NOT NULL,
            diseases TEXT NOT NULL,
            FOREIGN KEY(user_id) REFERENCES app_users(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE food_entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            food_name TEXT NOT NULL,
            logged_at TEXT NOT NULL,
            meal_type TEXT NOT NULL,
            calories REAL,
            protein_g REAL,
            carbs_g REAL,
            fat_g REAL,
            saturated_fat_g REAL,
            trans_fat_g REAL,
            fiber_g REAL,
            sugars_g REAL,
            sodium_mg REAL,
            cholesterol_mg REAL,
            vitamins_json TEXT,
            minerals_json TEXT,
            confidence TEXT NOT NULL,
            photo_path TEXT,
            estimated_weight_g REAL,
            servings INTEGER,
            cooking_method TEXT,
            FOREIGN KEY(user_id) REFERENCES app_users(id)
          )
        ''');
        await db.execute(
            'CREATE INDEX idx_food_entries_user_date ON food_entries(user_id, logged_at)');

        await db.execute('''
          CREATE TABLE pantry_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            product_name TEXT NOT NULL,
            category TEXT NOT NULL,
            quantity REAL NOT NULL,
            unit TEXT NOT NULL,
            purchase_date TEXT NOT NULL,
            expiration_date TEXT,
            FOREIGN KEY(user_id) REFERENCES app_users(id)
          )
        ''');
      },
    );
  }

  Future<void> deleteAllData() async {
    final db = await database;
    await db.delete('food_entries');
    await db.delete('pantry_items');
    await db.delete('user_profiles');
    await db.delete('app_users');
    await _secureStorage.deleteAll();
  }
}
