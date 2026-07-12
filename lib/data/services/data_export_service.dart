import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../domain/entities/food_entry.dart';
import '../../domain/entities/pantry_item.dart';
import '../../domain/entities/user_profile.dart';

/// Builds a single portable JSON file with the user's own profile, food
/// log, and pantry data — a raw data export the user can keep or move
/// elsewhere, distinct from the AI-generated weekly PDF report (which is a
/// summary/analysis, not a full dump of their records).
class DataExportService {
  Future<File> export({
    required UserProfile profile,
    required List<FoodEntry> foodEntries,
    required List<PantryItem> pantryItems,
  }) async {
    final json = {
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': {
        'name': profile.name,
        'birthDate': profile.birthDate.toIso8601String(),
        'sex': profile.sex.name,
        'heightCm': profile.heightCm,
        'currentWeightKg': profile.currentWeightKg,
        'targetWeightKg': profile.targetWeightKg,
        'activityLevel': profile.activityLevel.name,
        'goals': profile.goals.map((g) => g.name).toList(),
        'restrictions': profile.restrictions,
        'allergies': profile.allergies,
        'diseases': profile.diseases,
        'dailyCalorieGoal': profile.dailyCalorieGoal,
      },
      'foodEntries': foodEntries
          .map((e) => {
                'foodName': e.foodName,
                'loggedAt': e.loggedAt.toIso8601String(),
                'mealType': e.mealType.name,
                'calories': e.nutrition.calories,
                'proteinGrams': e.nutrition.proteinGrams,
                'carbsGrams': e.nutrition.carbsGrams,
                'fatGrams': e.nutrition.fatGrams,
                'sodiumMilligrams': e.nutrition.sodiumMilligrams,
                'fiberGrams': e.nutrition.fiberGrams,
                'estimatedWeightGrams': e.estimatedWeightGrams,
                'components': e.components.map((c) => c.toJson()).toList(),
              })
          .toList(),
      'pantryItems': pantryItems
          .map((p) => {
                'productName': p.productName,
                'category': p.category.name,
                'quantity': p.quantity,
                'unit': p.unit,
                'purchaseDate': p.purchaseDate.toIso8601String(),
                'expirationDate': p.expirationDate?.toIso8601String(),
              })
          .toList(),
    };

    final dir = await getApplicationDocumentsDirectory();
    final exportsDir = Directory('${dir.path}/exports');
    if (!await exportsDir.exists()) {
      await exportsDir.create(recursive: true);
    }
    final now = DateTime.now();
    final fileName = 'nutriapp_datos_'
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}'
        '.json';
    final file = File('${exportsDir.path}/$fileName');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(json));
    return file;
  }
}
