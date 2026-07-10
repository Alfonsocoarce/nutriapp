/// How often a food (or plate component) was logged within a week, used
/// for the "most consumed foods" analytics on the weekly report.
class FoodFrequency {
  final String name;
  final int count;
  final double totalCalories;

  const FoodFrequency({
    required this.name,
    required this.count,
    required this.totalCalories,
  });
}
