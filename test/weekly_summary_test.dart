import 'package:flutter_test/flutter_test.dart';
import 'package:nutriapp/domain/entities/activity_level.dart';
import 'package:nutriapp/domain/entities/confidence_level.dart';
import 'package:nutriapp/domain/entities/food_entry.dart';
import 'package:nutriapp/domain/entities/meal_type.dart';
import 'package:nutriapp/domain/entities/nutrition_goal.dart';
import 'package:nutriapp/domain/entities/nutrition_info.dart';
import 'package:nutriapp/domain/entities/sex.dart';
import 'package:nutriapp/domain/entities/user_profile.dart';
import 'package:nutriapp/domain/usecases/build_weekly_recommendations.dart';
import 'package:nutriapp/domain/usecases/compute_weekly_summary_usecase.dart';

UserProfile _profile({
  double weight = 65,
  double height = 165,
  List<NutritionGoal> goals = const [],
}) =>
    UserProfile(
      userId: 1,
      name: 'Test',
      birthDate: DateTime(1995, 1, 1),
      sex: Sex.female,
      heightCm: height,
      currentWeightKg: weight,
      targetWeightKg: weight - 5,
      activityLevel: ActivityLevel.moderate,
      goals: goals,
    );

FoodEntry _entry(DateTime loggedAt, {double? calories, double? protein, double? sodium}) =>
    FoodEntry(
      id: 1,
      userId: 1,
      foodName: 'Test food',
      loggedAt: loggedAt,
      mealType: MealType.lunch,
      nutrition: NutritionInfo(
        calories: calories,
        proteinGrams: protein,
        sodiumMilligrams: sodium,
        confidence: ConfidenceLevel.high,
      ),
    );

void main() {
  final monday = DateTime(2026, 7, 6); // a Monday

  group('ComputeWeeklySummaryUseCase', () {
    test('buckets entries into the correct day of a Monday-Sunday week', () {
      final profile = _profile();
      final entries = [
        _entry(DateTime(2026, 7, 6, 8), calories: 300), // Monday
        _entry(DateTime(2026, 7, 6, 20), calories: 400), // Monday
        _entry(DateTime(2026, 7, 8, 12), calories: 500), // Wednesday
      ];

      final summary = ComputeWeeklySummaryUseCase()(
        profile: profile,
        weekStart: monday,
        weekEntries: entries,
      );

      expect(summary.days, hasLength(7));
      expect(summary.days[0].caloriesConsumed, 700); // Monday
      expect(summary.days[0].mealCount, 2);
      expect(summary.days[2].caloriesConsumed, 500); // Wednesday
      expect(summary.days[1].caloriesConsumed, 0); // Tuesday, untouched
      expect(summary.days[1].mealCount, 0);
    });

    test('excludes entries outside the requested week', () {
      final profile = _profile();
      final entries = [
        _entry(DateTime(2026, 7, 5, 12), calories: 999), // the Sunday before
        _entry(DateTime(2026, 7, 13, 12), calories: 999), // the Monday after
      ];

      final summary = ComputeWeeklySummaryUseCase()(
        profile: profile,
        weekStart: monday,
        weekEntries: entries,
      );

      expect(summary.days.every((d) => d.mealCount == 0), isTrue);
    });

    test('averages are computed only over days that were actually logged', () {
      final profile = _profile();
      final entries = [
        _entry(DateTime(2026, 7, 6, 8), calories: 2000), // Monday only
      ];

      final summary = ComputeWeeklySummaryUseCase()(
        profile: profile,
        weekStart: monday,
        weekEntries: entries,
      );

      expect(summary.daysLogged, 1);
      expect(summary.avgCaloriesConsumed, 2000); // not 2000/7
    });
  });

  group('rollingWeekStart', () {
    test('returns 6 days before the given date', () {
      expect(rollingWeekStart(DateTime(2026, 7, 12)), DateTime(2026, 7, 6));
    });

    test('does not snap to Monday — any weekday just goes back 6 days', () {
      // 2026-07-08 is a Wednesday; the window should start the previous
      // Thursday, not the Monday of that calendar week.
      expect(rollingWeekStart(DateTime(2026, 7, 8)), DateTime(2026, 7, 2));
    });
  });

  group('buildWeeklyRecommendations', () {
    test('flags an unlogged week without crashing', () {
      final summary = ComputeWeeklySummaryUseCase()(
        profile: _profile(),
        weekStart: monday,
        weekEntries: const [],
      );

      final tips = buildWeeklyRecommendations(summary);
      expect(tips, hasLength(1));
      expect(tips.first, contains('No registraste comidas'));
    });

    test('flags average calories well above the daily goal', () {
      final profile = _profile();
      final entries = [
        _entry(DateTime(2026, 7, 6, 8), calories: profile.dailyCalorieGoal * 2),
      ];
      final summary = ComputeWeeklySummaryUseCase()(
        profile: profile,
        weekStart: monday,
        weekEntries: entries,
      );

      final tips = buildWeeklyRecommendations(summary);
      expect(tips.first, contains('superó tu meta calórica'));
    });

    test('flags high average sodium intake', () {
      final profile = _profile();
      final entries = [
        _entry(DateTime(2026, 7, 6, 8),
            calories: profile.dailyCalorieGoal, protein: 100, sodium: 4000),
      ];
      final summary = ComputeWeeklySummaryUseCase()(
        profile: profile,
        weekStart: monday,
        weekEntries: entries,
      );

      final tips = buildWeeklyRecommendations(summary);
      expect(tips.any((t) => t.contains('sodio')), isTrue);
    });

    test('never returns more than 5 recommendations', () {
      final profile = _profile();
      final entries = [
        _entry(DateTime(2026, 7, 6, 8),
            calories: profile.dailyCalorieGoal * 3, protein: 0, sodium: 5000),
      ];
      final summary = ComputeWeeklySummaryUseCase()(
        profile: profile,
        weekStart: monday,
        weekEntries: entries,
      );

      expect(buildWeeklyRecommendations(summary).length, lessThanOrEqualTo(5));
    });
  });
}
