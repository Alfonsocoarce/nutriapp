import '../../domain/entities/food_recognition_result.dart';

/// Identifies food from a photo (ERS RF-05).
///
/// [GeminiFoodRecognitionService] is the implementation wired up today,
/// calling the Gemini Vision API directly with a user-supplied API key
/// (see docs/ERS.md Section 3 for the tradeoff vs. a backend proxy).
/// Swapping in a different provider means adding a new class here and
/// changing the single provider override in food_log providers.
abstract class FoodRecognitionService {
  Future<FoodRecognitionResult> analyze(String photoPath);
}
