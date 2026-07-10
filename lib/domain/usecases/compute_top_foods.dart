import '../entities/food_entry.dart';
import '../entities/food_frequency.dart';

/// Ranks the foods logged across a set of entries by how often they
/// appear, so the weekly report can show "most consumed foods". Uses the
/// per-component breakdown when available (e.g. "Huevo", "Arroz" from a
/// composite plate) so repeated ingredients across different meals are
/// correctly counted as the same food; falls back to the entry's whole
/// [FoodEntry.foodName] for entries with no component breakdown (manual
/// entries, packaged-label scans).
List<FoodFrequency> computeTopFoods(List<FoodEntry> entries, {int limit = 5}) {
  final counts = <String, int>{};
  final calories = <String, double>{};
  final displayNames = <String, String>{};

  void tally(String rawName, double? cal) {
    final trimmed = rawName.trim();
    if (trimmed.isEmpty) return;
    final key = trimmed.toLowerCase();
    counts[key] = (counts[key] ?? 0) + 1;
    calories[key] = (calories[key] ?? 0) + (cal ?? 0);
    displayNames.putIfAbsent(key, () => trimmed);
  }

  for (final entry in entries) {
    if (entry.components.isNotEmpty) {
      for (final component in entry.components) {
        tally(component.name, component.calories);
      }
    } else {
      tally(entry.foodName, entry.nutrition.calories);
    }
  }

  final result = counts.keys
      .map((key) => FoodFrequency(
            name: displayNames[key]!,
            count: counts[key]!,
            totalCalories: calories[key] ?? 0,
          ))
      .toList()
    ..sort((a, b) {
      final byCount = b.count.compareTo(a.count);
      return byCount != 0 ? byCount : b.totalCalories.compareTo(a.totalCalories);
    });

  return result.take(limit).toList();
}
