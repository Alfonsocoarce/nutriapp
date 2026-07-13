import 'food_component_breakdown.dart';
import 'nutrition_info.dart';

class FoodRecognitionResult {
  final String foodName;
  final List<String> ingredients;
  final String? cookingMethod;
  final double? estimatedWeightGrams;
  final int? servings;
  final NutritionInfo nutrition;

  /// Set by the recognition service when it suspects part of the plate may
  /// not be fully visible in the photo (e.g. rice/beans hidden under eggs) —
  /// shown to the user as a prompt to double-check or retake the photo.
  final String? visibilityWarning;

  /// Concrete, actionable guidance for getting a more accurate result next
  /// time (better lighting, angle, framing, etc.) — populated whenever
  /// [NutritionInfo.confidence] isn't high, so a low-confidence result comes
  /// with a way to fix it instead of just a blurry number.
  final String? improvementTip;

  /// Per-item nutrition breakdown (e.g. "huevo": 180 kcal, "arroz": 210
  /// kcal...) that sums to [nutrition]. Empty when the model couldn't
  /// separate the plate into distinct components.
  final List<FoodComponentBreakdown> components;

  const FoodRecognitionResult({
    required this.foodName,
    required this.ingredients,
    required this.nutrition,
    this.cookingMethod,
    this.estimatedWeightGrams,
    this.servings,
    this.visibilityWarning,
    this.improvementTip,
    this.components = const [],
  });
}
