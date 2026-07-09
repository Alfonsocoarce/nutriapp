import 'confidence_level.dart';

/// Nutritional breakdown for a food entry. Fields are nullable: a null value
/// means the data is genuinely unknown and must be shown as such in the UI,
/// never silently treated as zero (see ERS RF-05/RF-06).
class NutritionInfo {
  final double? calories;
  final double? proteinGrams;
  final double? carbsGrams;
  final double? fatGrams;
  final double? saturatedFatGrams;
  final double? transFatGrams;
  final double? fiberGrams;
  final double? sugarsGrams;
  final double? sodiumMilligrams;
  final double? cholesterolMilligrams;
  final Map<String, double>? vitamins;
  final Map<String, double>? minerals;
  final ConfidenceLevel confidence;

  const NutritionInfo({
    this.calories,
    this.proteinGrams,
    this.carbsGrams,
    this.fatGrams,
    this.saturatedFatGrams,
    this.transFatGrams,
    this.fiberGrams,
    this.sugarsGrams,
    this.sodiumMilligrams,
    this.cholesterolMilligrams,
    this.vitamins,
    this.minerals,
    this.confidence = ConfidenceLevel.high,
  });

  static const empty = NutritionInfo();
}
