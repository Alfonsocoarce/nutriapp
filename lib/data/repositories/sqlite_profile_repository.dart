import 'dart:convert';

import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../domain/entities/activity_level.dart';
import '../../domain/entities/nutrition_goal.dart';
import '../../domain/entities/sex.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../local/app_database.dart';

class SqliteProfileRepository implements ProfileRepository {
  @override
  Future<UserProfile?> getProfile(int userId) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'user_profiles',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (rows.isEmpty) return null;

    final row = rows.first;
    return UserProfile(
      userId: row['user_id'] as int,
      name: row['name'] as String,
      birthDate: DateTime.parse(row['birth_date'] as String),
      sex: Sex.values.byName(row['sex'] as String),
      heightCm: row['height_cm'] as double,
      currentWeightKg: row['current_weight_kg'] as double,
      targetWeightKg: row['target_weight_kg'] as double,
      activityLevel: ActivityLevel.values.byName(row['activity_level'] as String),
      goals: (jsonDecode(row['goals'] as String) as List)
          .map((g) => NutritionGoal.values.byName(g as String))
          .toList(),
      restrictions: List<String>.from(jsonDecode(row['restrictions'] as String)),
      allergies: List<String>.from(jsonDecode(row['allergies'] as String)),
      diseases: List<String>.from(jsonDecode(row['diseases'] as String)),
    );
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    final db = await AppDatabase.instance.database;
    await db.insert(
      'user_profiles',
      {
        'user_id': profile.userId,
        'name': profile.name,
        'birth_date': profile.birthDate.toIso8601String(),
        'sex': profile.sex.name,
        'height_cm': profile.heightCm,
        'current_weight_kg': profile.currentWeightKg,
        'target_weight_kg': profile.targetWeightKg,
        'activity_level': profile.activityLevel.name,
        'goals': jsonEncode(profile.goals.map((g) => g.name).toList()),
        'restrictions': jsonEncode(profile.restrictions),
        'allergies': jsonEncode(profile.allergies),
        'diseases': jsonEncode(profile.diseases),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
