import '../../domain/entities/food_recognition_result.dart';

/// Identifies food from a photo (ERS RF-05). The production implementation
/// must call a vision model through a stateless backend proxy so the API key
/// never ships inside the mobile app — see docs/ERS.md Section 3.
///
/// [MockFoodRecognitionService] is the only implementation wired up today;
/// swapping in a real provider means adding a new class here and changing
/// the single provider override in food_log providers.
abstract class FoodRecognitionService {
  Future<FoodRecognitionResult> analyze(String photoPath);
}
