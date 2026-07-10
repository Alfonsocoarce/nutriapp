/// Nutrition estimate for a single identifiable component of a plate (e.g.
/// "huevo frito", "arroz", "frijoles") as part of a photo analysis result.
class FoodComponentBreakdown {
  final String name;
  final double? estimatedWeightGrams;
  final double? calories;
  final double? proteinGrams;
  final double? carbsGrams;
  final double? fatGrams;

  const FoodComponentBreakdown({
    required this.name,
    this.estimatedWeightGrams,
    this.calories,
    this.proteinGrams,
    this.carbsGrams,
    this.fatGrams,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'estimatedWeightGrams': estimatedWeightGrams,
        'calories': calories,
        'proteinGrams': proteinGrams,
        'carbsGrams': carbsGrams,
        'fatGrams': fatGrams,
      };

  factory FoodComponentBreakdown.fromJson(Map<String, dynamic> json) {
    return FoodComponentBreakdown(
      name: (json['name'] as String?)?.trim() ?? '',
      estimatedWeightGrams: (json['estimatedWeightGrams'] as num?)?.toDouble(),
      calories: (json['calories'] as num?)?.toDouble(),
      proteinGrams: (json['proteinGrams'] as num?)?.toDouble(),
      carbsGrams: (json['carbsGrams'] as num?)?.toDouble(),
      fatGrams: (json['fatGrams'] as num?)?.toDouble(),
    );
  }
}
