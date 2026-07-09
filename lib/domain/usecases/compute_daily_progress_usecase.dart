import '../entities/food_entry.dart';
import '../entities/user_profile.dart';

class DailyProgress {
  final double caloriesConsumed;
  final double caloriesGoal;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final List<FoodEntry> meals;

  const DailyProgress({
    required this.caloriesConsumed,
    required this.caloriesGoal,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.meals,
  });

  double get caloriesRemaining => (caloriesGoal - caloriesConsumed).clamp(0, caloriesGoal);
  double get progressFraction =>
      caloriesGoal <= 0 ? 0 : (caloriesConsumed / caloriesGoal).clamp(0, 1);
}

class ComputeDailyProgressUseCase {
  DailyProgress call({
    required UserProfile profile,
    required List<FoodEntry> todaysEntries,
  }) {
    double calories = 0, protein = 0, carbs = 0, fat = 0;
    for (final entry in todaysEntries) {
      calories += entry.nutrition.calories ?? 0;
      protein += entry.nutrition.proteinGrams ?? 0;
      carbs += entry.nutrition.carbsGrams ?? 0;
      fat += entry.nutrition.fatGrams ?? 0;
    }
    return DailyProgress(
      caloriesConsumed: calories,
      caloriesGoal: profile.dailyCalorieGoal,
      proteinGrams: protein,
      carbsGrams: carbs,
      fatGrams: fat,
      meals: todaysEntries,
    );
  }
}
