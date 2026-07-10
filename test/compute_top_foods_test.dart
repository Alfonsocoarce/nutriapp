import 'package:flutter_test/flutter_test.dart';
import 'package:nutriapp/domain/entities/confidence_level.dart';
import 'package:nutriapp/domain/entities/food_component_breakdown.dart';
import 'package:nutriapp/domain/entities/food_entry.dart';
import 'package:nutriapp/domain/entities/meal_type.dart';
import 'package:nutriapp/domain/entities/nutrition_info.dart';
import 'package:nutriapp/domain/usecases/compute_top_foods.dart';

FoodEntry _entry({
  required String foodName,
  double? calories,
  List<FoodComponentBreakdown> components = const [],
}) =>
    FoodEntry(
      id: 1,
      userId: 1,
      foodName: foodName,
      loggedAt: DateTime(2026, 7, 6),
      mealType: MealType.lunch,
      nutrition: NutritionInfo(calories: calories, confidence: ConfidenceLevel.high),
      components: components,
    );

void main() {
  group('computeTopFoods', () {
    test('counts per-component occurrences across multiple entries', () {
      final entries = [
        _entry(foodName: 'Desayuno', components: const [
          FoodComponentBreakdown(name: 'Huevo', calories: 180),
          FoodComponentBreakdown(name: 'Arroz', calories: 150),
        ]),
        _entry(foodName: 'Almuerzo', components: const [
          FoodComponentBreakdown(name: 'Huevo', calories: 90),
          FoodComponentBreakdown(name: 'Frijoles', calories: 120),
        ]),
      ];

      final top = computeTopFoods(entries);

      expect(top.first.name, 'Huevo');
      expect(top.first.count, 2);
      expect(top.first.totalCalories, 270);
    });

    test('is case-insensitive when merging the same ingredient', () {
      final entries = [
        _entry(foodName: 'A', components: const [
          FoodComponentBreakdown(name: 'huevo', calories: 100),
        ]),
        _entry(foodName: 'B', components: const [
          FoodComponentBreakdown(name: 'Huevo', calories: 100),
        ]),
      ];

      final top = computeTopFoods(entries);

      expect(top, hasLength(1));
      expect(top.first.count, 2);
    });

    test('falls back to the whole foodName when an entry has no components', () {
      final entries = [
        _entry(foodName: 'Bebida láctea Yes!', calories: 160),
        _entry(foodName: 'Bebida láctea Yes!', calories: 160),
      ];

      final top = computeTopFoods(entries);

      expect(top, hasLength(1));
      expect(top.first.name, 'Bebida láctea Yes!');
      expect(top.first.count, 2);
    });

    test('sorts by count first, then by total calories', () {
      final entries = [
        _entry(foodName: 'A', components: const [
          FoodComponentBreakdown(name: 'Poco frecuente pero calórico', calories: 900),
        ]),
        _entry(foodName: 'B', components: const [
          FoodComponentBreakdown(name: 'Frecuente', calories: 50),
        ]),
        _entry(foodName: 'C', components: const [
          FoodComponentBreakdown(name: 'Frecuente', calories: 50),
        ]),
      ];

      final top = computeTopFoods(entries);

      expect(top.first.name, 'Frecuente');
      expect(top.first.count, 2);
    });

    test('respects the limit parameter', () {
      final entries = List.generate(
        10,
        (i) => _entry(foodName: 'A', components: [
          FoodComponentBreakdown(name: 'Ingrediente $i', calories: 100),
        ]),
      );

      expect(computeTopFoods(entries, limit: 3), hasLength(3));
    });

    test('returns an empty list for no entries', () {
      expect(computeTopFoods(const []), isEmpty);
    });
  });
}
