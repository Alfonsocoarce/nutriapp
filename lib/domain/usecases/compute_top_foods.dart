import '../entities/food_entry.dart';
import '../entities/food_frequency.dart';

/// Generic dish/meal words that aren't foods on their own — filtered out
/// when splitting a whole-plate name into approximate ingredient tokens
/// (see [_splitFallbackTokens]).
const _genericMealWords = {
  'desayuno',
  'almuerzo',
  'cena',
  'merienda',
  'comida',
  'plato',
  'snack',
  'bebida',
  'combo',
};

/// Best-effort split of a whole-dish name (e.g. "Desayuno con huevos,
/// plátano maduro, aguacate, pan y jugo de naranja") into approximate
/// ingredient tokens, for entries that have no per-component breakdown.
/// Splits on "con"/"y" as connectors and on commas, then drops generic
/// meal-type words. Names with no such connectors (typical of manual
/// entries or a packaged product like "Bebida láctea Yes!") come back as
/// a single unchanged token.
List<String> _splitFallbackTokens(String name) {
  final normalized = name
      .replaceAll(RegExp(r'\bcon\b', caseSensitive: false), ',')
      .replaceAll(RegExp(r'\by\b', caseSensitive: false), ',');
  return normalized
      .split(',')
      .map((t) => t.trim())
      .where((t) => t.isNotEmpty && !_genericMealWords.contains(t.toLowerCase()))
      .toList();
}

/// Ranks the foods logged across a set of entries by how often they
/// appear, so the weekly report can show "most consumed foods" at the
/// ingredient level (e.g. "Aguacate", "Arroz", "Gallo pinto") rather than
/// whole dish descriptions. Uses the per-component breakdown when
/// available (composite plates analyzed by AI always produce one); falls
/// back to splitting [FoodEntry.foodName] on "con"/"y"/commas for older
/// entries or ones without a breakdown, so even those don't show up as one
/// giant sentence in the ranking.
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
      continue;
    }

    final tokens = _splitFallbackTokens(entry.foodName);
    if (tokens.length <= 1) {
      // A genuinely single-item entry (manual log, packaged product) —
      // its own calories are meaningful and safe to attribute.
      tally(entry.foodName, entry.nutrition.calories);
    } else {
      // A guessed split of a whole-plate name — don't attribute calories
      // to individual guessed tokens, since we don't actually know the
      // per-ingredient breakdown (missing data beats invented data).
      for (final token in tokens) {
        tally(token, null);
      }
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
