/// Where a [FoodExchangeGroup]'s portions came from — shown in the UI so
/// the family always knows which numbers are the nutritionist's actual
/// prescription versus a conservative general guideline filling a gap she
/// didn't cover.
enum FoodExchangeSource { nutritionist, generalReference }

/// One food item and the portion that counts as "one exchange" within its
/// group (e.g. "Arroz blanco o integral" → "1/2 taza").
class FoodExchangeItem {
  final String food;
  final String portion;

  const FoodExchangeItem({required this.food, required this.portion});
}

/// A food group from the nutritionist's exchange-list diet plan (e.g.
/// "Harinas"), each item within it being an interchangeable portion.
class FoodExchangeGroup {
  final String name;
  final String icon;
  final String guidance;
  final FoodExchangeSource source;
  final List<FoodExchangeItem> items;

  const FoodExchangeGroup({
    required this.name,
    required this.icon,
    required this.guidance,
    required this.source,
    required this.items,
  });
}
