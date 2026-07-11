import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/services/gemini_meal_planner_service.dart';
import '../../../data/services/gemini_weekly_recommendations_service.dart';
import '../../../data/services/weekly_report_pdf_service.dart';
import '../../../domain/entities/food_entry.dart';
import '../../../domain/entities/food_frequency.dart';
import '../../../domain/entities/pantry_item.dart';
import '../../../domain/entities/weekly_summary.dart';
import '../../../domain/usecases/compute_top_foods.dart';
import '../../../domain/usecases/compute_weekly_summary_usecase.dart';
import '../../auth/providers/auth_providers.dart';
import '../../food_log/providers/food_log_providers.dart';
import '../../pantry/providers/pantry_providers.dart';
import '../../profile/providers/profile_providers.dart';

final weeklyReportPdfServiceProvider = Provider<WeeklyReportPdfService>((ref) {
  return WeeklyReportPdfService();
});

final weeklyRecommendationsServiceProvider =
    Provider<GeminiWeeklyRecommendationsService>((ref) {
  return GeminiWeeklyRecommendationsService();
});

final mealPlannerServiceProvider = Provider<GeminiMealPlannerService>((ref) {
  return GeminiMealPlannerService();
});

/// Meals logged over the last 30 days regardless of which week is selected
/// on screen — the meal planner uses this wider window to infer the user's
/// habitual food combinations, which a single week is too little data for.
final habitEntriesProvider = FutureProvider<List<FoodEntry>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const [];

  final repository = ref.watch(foodLogRepositoryProvider);
  final now = DateTime.now();
  return repository.entriesForRange(userId, now.subtract(const Duration(days: 30)), now);
});

final currentPantryItemsProvider = FutureProvider<List<PantryItem>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const [];

  return ref.watch(pantryRepositoryProvider).allItems(userId);
});

/// The start (midnight) of the trailing 7-day window currently shown on the
/// report screen. Defaults to the last 7 days ending today — a continuous
/// rolling view of the user's habits, not a calendar Monday-Sunday week
/// that resets every Monday — navigated 7 days at a time with the
/// prev/next arrows.
final selectedWeekStartProvider = StateProvider<DateTime>((ref) {
  return rollingWeekStart(DateTime.now());
});

/// Raw entries for the selected week — fetched once and shared by both the
/// summary and the top-foods analytics below, so switching weeks doesn't
/// trigger two separate DB queries.
final weeklyEntriesProvider = FutureProvider<List<FoodEntry>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const [];

  final weekStart = ref.watch(selectedWeekStartProvider);
  final weekEndExclusive = weekStart.add(const Duration(days: 7));
  final repository = ref.watch(foodLogRepositoryProvider);
  return repository.entriesForRange(userId, weekStart, weekEndExclusive);
});

final weeklySummaryProvider = FutureProvider<WeeklySummary?>((ref) async {
  final profile = ref.watch(profileControllerProvider).valueOrNull;
  if (profile == null) return null;

  final weekStart = ref.watch(selectedWeekStartProvider);
  final entries = await ref.watch(weeklyEntriesProvider.future);

  return ComputeWeeklySummaryUseCase()(
    profile: profile,
    weekStart: weekStart,
    weekEntries: entries,
  );
});

final topFoodsProvider = FutureProvider<List<FoodFrequency>>((ref) async {
  final entries = await ref.watch(weeklyEntriesProvider.future);
  return computeTopFoods(entries);
});

final generatedReportsProvider = FutureProvider<List<File>>((ref) async {
  final service = ref.watch(weeklyReportPdfServiceProvider);
  return service.listGeneratedReports();
});
