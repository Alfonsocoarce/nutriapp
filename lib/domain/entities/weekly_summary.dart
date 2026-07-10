import 'user_profile.dart';

/// One day's calorie/macro totals within a [WeeklySummary].
class DailySummary {
  final DateTime date;
  final double caloriesGoal;
  final double caloriesConsumed;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final double sodiumMilligrams;
  final double fiberGrams;
  final int mealCount;

  const DailySummary({
    required this.date,
    required this.caloriesGoal,
    required this.caloriesConsumed,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.sodiumMilligrams,
    required this.fiberGrams,
    required this.mealCount,
  });

  double get calorieDifference => caloriesConsumed - caloriesGoal;
}

/// A Monday-to-Sunday window of [DailySummary]s for one user, used to
/// generate the weekly PDF report.
class WeeklySummary {
  final DateTime weekStart;
  final DateTime weekEnd;
  final List<DailySummary> days;
  final UserProfile profile;

  const WeeklySummary({
    required this.weekStart,
    required this.weekEnd,
    required this.days,
    required this.profile,
  });

  int get daysLogged => days.where((d) => d.mealCount > 0).length;

  double get avgCaloriesGoal => profile.dailyCalorieGoal;

  double _avg(double Function(DailySummary) select) {
    if (daysLogged == 0) return 0;
    final loggedDays = days.where((d) => d.mealCount > 0);
    return loggedDays.map(select).reduce((a, b) => a + b) / daysLogged;
  }

  double get avgCaloriesConsumed => _avg((d) => d.caloriesConsumed);
  double get avgProteinGrams => _avg((d) => d.proteinGrams);
  double get avgCarbsGrams => _avg((d) => d.carbsGrams);
  double get avgFatGrams => _avg((d) => d.fatGrams);
  double get avgSodiumMilligrams => _avg((d) => d.sodiumMilligrams);
  double get avgFiberGrams => _avg((d) => d.fiberGrams);
}
