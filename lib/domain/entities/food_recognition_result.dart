import 'nutrition_info.dart';

class FoodRecognitionResult {
  final String foodName;
  final List<String> ingredients;
  final String? cookingMethod;
  final double? estimatedWeightGrams;
  final int? servings;
  final NutritionInfo nutrition;

  const FoodRecognitionResult({
    required this.foodName,
    required this.ingredients,
    required this.nutrition,
    this.cookingMethod,
    this.estimatedWeightGrams,
    this.servings,
  });
}
