import 'food_component_breakdown.dart';
import 'meal_type.dart';
import 'nutrition_info.dart';

class FoodEntry {
  final int id;
  final int userId;
  final String foodName;
  final DateTime loggedAt;
  final MealType mealType;
  final NutritionInfo nutrition;
  final String? photoPath;
  final double? estimatedWeightGrams;
  final int? servings;
  final String? cookingMethod;
  final List<FoodComponentBreakdown> components;

  const FoodEntry({
    required this.id,
    required this.userId,
    required this.foodName,
    required this.loggedAt,
    required this.mealType,
    required this.nutrition,
    this.photoPath,
    this.estimatedWeightGrams,
    this.servings,
    this.cookingMethod,
    this.components = const [],
  });
}
