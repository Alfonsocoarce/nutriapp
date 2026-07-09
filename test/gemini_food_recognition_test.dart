import 'package:flutter_test/flutter_test.dart';
import 'package:nutriapp/data/services/gemini_food_recognition_service.dart';
import 'package:nutriapp/domain/entities/confidence_level.dart';

void main() {
  group('foodRecognitionResultFromGeminiJson', () {
    test('maps a fully-populated response', () {
      final result = foodRecognitionResultFromGeminiJson({
        'foodName': 'Ensalada César con pollo',
        'ingredients': ['Lechuga', 'Pollo', 'Queso parmesano', 'Crutones'],
        'cookingMethod': 'A la parrilla',
        'estimatedWeightGrams': 350,
        'servings': 1,
        'confidence': 'high',
        'calories': 420,
        'proteinGrams': 32,
        'carbsGrams': 18,
        'fatGrams': 24,
      });

      expect(result.foodName, 'Ensalada César con pollo');
      expect(result.ingredients, hasLength(4));
      expect(result.cookingMethod, 'A la parrilla');
      expect(result.estimatedWeightGrams, 350);
      expect(result.servings, 1);
      expect(result.nutrition.confidence, ConfidenceLevel.high);
      expect(result.nutrition.calories, 420);
      expect(result.nutrition.proteinGrams, 32);
    });

    test('leaves nutrition fields the model omitted as null, not zero', () {
      final result = foodRecognitionResultFromGeminiJson({
        'foodName': 'Plato no identificado con certeza',
        'ingredients': <String>[],
        'confidence': 'low',
        'calories': 300,
        // proteinGrams/carbsGrams/fatGrams intentionally absent
      });

      expect(result.nutrition.calories, 300);
      expect(result.nutrition.proteinGrams, isNull);
      expect(result.nutrition.carbsGrams, isNull);
      expect(result.nutrition.fatGrams, isNull);
      expect(result.nutrition.confidence, ConfidenceLevel.low);
    });

    test('defaults confidence to medium for an unrecognized value', () {
      final result = foodRecognitionResultFromGeminiJson({
        'foodName': 'Comida',
        'ingredients': <String>[],
        'confidence': 'unexpected',
      });

      expect(result.nutrition.confidence, ConfidenceLevel.medium);
    });

    test('falls back to a placeholder name if foodName is missing', () {
      final result = foodRecognitionResultFromGeminiJson({
        'ingredients': <String>[],
        'confidence': 'low',
      });

      expect(result.foodName, isNotEmpty);
    });
  });

  group('mimeTypeForImagePath', () {
    test('maps common extensions to their MIME type', () {
      expect(mimeTypeForImagePath('/tmp/photo.jpg'), 'image/jpeg');
      expect(mimeTypeForImagePath('/tmp/photo.JPEG'), 'image/jpeg');
      expect(mimeTypeForImagePath('/tmp/photo.png'), 'image/png');
      expect(mimeTypeForImagePath('/tmp/photo.webp'), 'image/webp');
      expect(mimeTypeForImagePath('/tmp/photo.heic'), 'image/heic');
      expect(mimeTypeForImagePath('/tmp/photo.unknownext'), 'image/jpeg');
    });
  });
}
