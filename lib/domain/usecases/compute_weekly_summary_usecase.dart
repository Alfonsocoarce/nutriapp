import '../entities/food_entry.dart';
import '../entities/user_profile.dart';
import '../entities/weekly_summary.dart';

/// Buckets a week's worth of [FoodEntry] rows into 7 [DailySummary]s
/// (Monday..Sunday) against the user's daily calorie goal.
class ComputeWeeklySummaryUseCase {
  WeeklySummary call({
    required UserProfile profile,
    required DateTime weekStart,
    required List<FoodEntry> weekEntries,
  }) {
    final days = List.generate(7, (i) {
      final date = DateTime(weekStart.year, weekStart.month, weekStart.day)
          .add(Duration(days: i));
      final dayEntries = weekEntries.where((e) =>
          e.loggedAt.year == date.year &&
          e.loggedAt.month == date.month &&
          e.loggedAt.day == date.day);

      double calories = 0, protein = 0, carbs = 0, fat = 0, sodium = 0, fiber = 0;
      for (final e in dayEntries) {
        calories += e.nutrition.calories ?? 0;
        protein += e.nutrition.proteinGrams ?? 0;
        carbs += e.nutrition.carbsGrams ?? 0;
        fat += e.nutrition.fatGrams ?? 0;
        sodium += e.nutrition.sodiumMilligrams ?? 0;
        fiber += e.nutrition.fiberGrams ?? 0;
      }

      return DailySummary(
        date: date,
        caloriesGoal: profile.dailyCalorieGoal,
        caloriesConsumed: calories,
        proteinGrams: protein,
        carbsGrams: carbs,
        fatGrams: fat,
        sodiumMilligrams: sodium,
        fiberGrams: fiber,
        mealCount: dayEntries.length,
      );
    });

    return WeeklySummary(
      weekStart: days.first.date,
      weekEnd: days.last.date,
      days: days,
      profile: profile,
    );
  }
}

/// Returns the Monday (midnight) of the week containing [date].
DateTime mondayOfWeek(DateTime date) {
  final d = DateTime(date.year, date.month, date.day);
  return d.subtract(Duration(days: d.weekday - DateTime.monday));
}
