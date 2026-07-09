import 'package:flutter_test/flutter_test.dart';
import 'package:nutriapp/domain/entities/activity_level.dart';
import 'package:nutriapp/domain/entities/confidence_level.dart';
import 'package:nutriapp/domain/entities/food_entry.dart';
import 'package:nutriapp/domain/entities/meal_type.dart';
import 'package:nutriapp/domain/entities/nutrition_info.dart';
import 'package:nutriapp/domain/entities/sex.dart';
import 'package:nutriapp/domain/entities/user_profile.dart';
import 'package:nutriapp/domain/usecases/compute_daily_progress_usecase.dart';

UserProfile _profile({required double weight, required double height}) => UserProfile(
      userId: 1,
      name: 'Test',
      birthDate: DateTime(1995, 1, 1),
      sex: Sex.female,
      heightCm: height,
      currentWeightKg: weight,
      targetWeightKg: weight - 5,
      activityLevel: ActivityLevel.moderate,
    );

FoodEntry _entry({double? calories, double? protein}) => FoodEntry(
      id: 1,
      userId: 1,
      foodName: 'Test food',
      loggedAt: DateTime.now(),
      mealType: MealType.lunch,
      nutrition: NutritionInfo(
        calories: calories,
        proteinGrams: protein,
        confidence: ConfidenceLevel.high,
      ),
    );

void main() {
  group('ComputeDailyProgressUseCase', () {
    test('sums nutrition across entries and computes remaining calories', () {
      final profile = _profile(weight: 65, height: 165);
      final entries = [
        _entry(calories: 400, protein: 20),
        _entry(calories: 350, protein: 15),
      ];

      final progress =
          ComputeDailyProgressUseCase()(profile: profile, todaysEntries: entries);

      expect(progress.caloriesConsumed, 750);
      expect(progress.proteinGrams, 35);
      expect(progress.caloriesRemaining, profile.dailyCalorieGoal - 750);
      expect(progress.meals, entries);
    });

    test('treats missing nutrition fields as zero contribution, not a crash', () {
      final profile = _profile(weight: 70, height: 170);
      final entries = [_entry(calories: null, protein: null)];

      final progress =
          ComputeDailyProgressUseCase()(profile: profile, todaysEntries: entries);

      expect(progress.caloriesConsumed, 0);
      expect(progress.proteinGrams, 0);
    });

    test('caloriesRemaining never goes negative when over goal', () {
      final profile = _profile(weight: 60, height: 160);
      final entries = [_entry(calories: profile.dailyCalorieGoal + 1000)];

      final progress =
          ComputeDailyProgressUseCase()(profile: profile, todaysEntries: entries);

      expect(progress.caloriesRemaining, 0);
    });
  });

  group('MealType.fromHour', () {
    test('classifies common hours into the expected meal type', () {
      expect(MealType.fromHour(7), MealType.breakfast);
      expect(MealType.fromHour(13), MealType.lunch);
      expect(MealType.fromHour(19), MealType.dinner);
      expect(MealType.fromHour(2), MealType.drink);
    });
  });
}
