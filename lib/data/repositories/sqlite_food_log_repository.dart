import 'dart:convert';

import '../../domain/entities/confidence_level.dart';
import '../../domain/entities/food_entry.dart';
import '../../domain/entities/meal_type.dart';
import '../../domain/entities/nutrition_info.dart';
import '../../domain/repositories/food_log_repository.dart';
import '../local/app_database.dart';

class SqliteFoodLogRepository implements FoodLogRepository {
  @override
  Future<int> addEntry(FoodEntry entry) async {
    final db = await AppDatabase.instance.database;
    return db.insert('food_entries', {
      'user_id': entry.userId,
      'food_name': entry.foodName,
      'logged_at': entry.loggedAt.toIso8601String(),
      'meal_type': entry.mealType.name,
      'calories': entry.nutrition.calories,
      'protein_g': entry.nutrition.proteinGrams,
      'carbs_g': entry.nutrition.carbsGrams,
      'fat_g': entry.nutrition.fatGrams,
      'saturated_fat_g': entry.nutrition.saturatedFatGrams,
      'trans_fat_g': entry.nutrition.transFatGrams,
      'fiber_g': entry.nutrition.fiberGrams,
      'sugars_g': entry.nutrition.sugarsGrams,
      'sodium_mg': entry.nutrition.sodiumMilligrams,
      'cholesterol_mg': entry.nutrition.cholesterolMilligrams,
      'vitamins_json':
          entry.nutrition.vitamins == null ? null : jsonEncode(entry.nutrition.vitamins),
      'minerals_json':
          entry.nutrition.minerals == null ? null : jsonEncode(entry.nutrition.minerals),
      'confidence': entry.nutrition.confidence.name,
      'photo_path': entry.photoPath,
      'estimated_weight_g': entry.estimatedWeightGrams,
      'servings': entry.servings,
      'cooking_method': entry.cookingMethod,
    });
  }

  @override
  Future<void> updateMealType(int entryId, MealType mealType) async {
    final db = await AppDatabase.instance.database;
    await db.update(
      'food_entries',
      {'meal_type': mealType.name},
      where: 'id = ?',
      whereArgs: [entryId],
    );
  }

  @override
  Future<List<FoodEntry>> entriesForDay(int userId, DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return entriesForRange(userId, start, end);
  }

  @override
  Future<List<FoodEntry>> entriesForRange(
      int userId, DateTime start, DateTime end) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'food_entries',
      where: 'user_id = ? AND logged_at >= ? AND logged_at < ?',
      whereArgs: [userId, start.toIso8601String(), end.toIso8601String()],
      orderBy: 'logged_at ASC',
    );
    return rows.map(_rowToEntity).toList();
  }

  @override
  Future<void> deleteEntry(int entryId) async {
    final db = await AppDatabase.instance.database;
    await db.delete('food_entries', where: 'id = ?', whereArgs: [entryId]);
  }

  FoodEntry _rowToEntity(Map<String, Object?> row) {
    return FoodEntry(
      id: row['id'] as int,
      userId: row['user_id'] as int,
      foodName: row['food_name'] as String,
      loggedAt: DateTime.parse(row['logged_at'] as String),
      mealType: MealType.values.byName(row['meal_type'] as String),
      nutrition: NutritionInfo(
        calories: row['calories'] as double?,
        proteinGrams: row['protein_g'] as double?,
        carbsGrams: row['carbs_g'] as double?,
        fatGrams: row['fat_g'] as double?,
        saturatedFatGrams: row['saturated_fat_g'] as double?,
        transFatGrams: row['trans_fat_g'] as double?,
        fiberGrams: row['fiber_g'] as double?,
        sugarsGrams: row['sugars_g'] as double?,
        sodiumMilligrams: row['sodium_mg'] as double?,
        cholesterolMilligrams: row['cholesterol_mg'] as double?,
        vitamins: row['vitamins_json'] == null
            ? null
            : Map<String, double>.from(jsonDecode(row['vitamins_json'] as String)),
        minerals: row['minerals_json'] == null
            ? null
            : Map<String, double>.from(jsonDecode(row['minerals_json'] as String)),
        confidence: ConfidenceLevel.values.byName(row['confidence'] as String),
      ),
      photoPath: row['photo_path'] as String?,
      estimatedWeightGrams: row['estimated_weight_g'] as double?,
      servings: row['servings'] as int?,
      cookingMethod: row['cooking_method'] as String?,
    );
  }
}
