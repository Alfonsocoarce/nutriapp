import 'dart:math';

import '../../domain/entities/confidence_level.dart';
import '../../domain/entities/food_recognition_result.dart';
import '../../domain/entities/nutrition_info.dart';
import 'food_recognition_service.dart';

/// Returns plausible sample results so the photo -> recognition -> log flow
/// is fully wired end to end before a real vision API key is available.
class MockFoodRecognitionService implements FoodRecognitionService {
  static const _samples = [
    FoodRecognitionResult(
      foodName: 'Ensalada de pollo a la parrilla',
      ingredients: ['Pechuga de pollo', 'Lechuga', 'Tomate', 'Pepino', 'Aceite de oliva'],
      cookingMethod: 'A la parrilla',
      estimatedWeightGrams: 350,
      servings: 1,
      nutrition: NutritionInfo(
        calories: 420,
        proteinGrams: 38,
        carbsGrams: 18,
        fatGrams: 22,
        saturatedFatGrams: 4,
        fiberGrams: 5,
        sodiumMilligrams: 380,
        confidence: ConfidenceLevel.medium,
      ),
    ),
    FoodRecognitionResult(
      foodName: 'Arroz con frijoles y plátano',
      ingredients: ['Arroz', 'Frijoles negros', 'Plátano maduro'],
      cookingMethod: 'Hervido',
      estimatedWeightGrams: 450,
      servings: 1,
      nutrition: NutritionInfo(
        calories: 610,
        proteinGrams: 15,
        carbsGrams: 112,
        fatGrams: 9,
        fiberGrams: 12,
        sugarsGrams: 14,
        confidence: ConfidenceLevel.high,
      ),
    ),
    FoodRecognitionResult(
      foodName: 'Batido de frutas',
      ingredients: ['Banano', 'Fresas', 'Leche'],
      estimatedWeightGrams: 300,
      servings: 1,
      nutrition: NutritionInfo(
        calories: 250,
        proteinGrams: 7,
        carbsGrams: 45,
        fatGrams: 4,
        sugarsGrams: 32,
        // Micronutrient data not modeled for this sample: left null rather
        // than guessed, per the ERS RF-05/RF-06 data-integrity principle.
        confidence: ConfidenceLevel.low,
      ),
    ),
  ];

  @override
  Future<FoodRecognitionResult> analyze(String photoPath) async {
    await Future.delayed(const Duration(milliseconds: 900));
    return _samples[Random().nextInt(_samples.length)];
  }
}
