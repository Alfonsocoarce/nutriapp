import 'package:flutter_test/flutter_test.dart';
import 'package:nutriapp/data/services/gemini_meal_planner_service.dart';

void main() {
  group('mealPlanFromGeminiJson', () {
    test('maps a fully-populated multi-day response', () {
      final plan = mealPlanFromGeminiJson([
        {
          'date': '2026-07-11',
          'meals': [
            {'mealLabel': 'Desayuno', 'description': 'Gallo pinto con huevo y aguacate'},
            {'mealLabel': 'Almuerzo', 'description': 'Arroz con pollo y ensalada'},
          ],
        },
        {
          'date': '2026-07-12',
          'meals': [
            {'mealLabel': 'Cena', 'description': 'Sopa de vegetales con tortilla'},
          ],
        },
      ]);

      expect(plan.days, hasLength(2));
      expect(plan.days[0].date, DateTime(2026, 7, 11));
      expect(plan.days[0].meals, hasLength(2));
      expect(plan.days[0].meals[0].mealLabel, 'Desayuno');
      expect(plan.days[0].meals[0].description, 'Gallo pinto con huevo y aguacate');
      expect(plan.days[1].meals[0].mealLabel, 'Cena');
    });

    test('drops a day with an unparsable date', () {
      final plan = mealPlanFromGeminiJson([
        {
          'date': 'not-a-date',
          'meals': [
            {'mealLabel': 'Desayuno', 'description': 'Algo'},
          ],
        },
        {
          'date': '2026-07-11',
          'meals': [
            {'mealLabel': 'Almuerzo', 'description': 'Algo más'},
          ],
        },
      ]);

      expect(plan.days, hasLength(1));
      expect(plan.days[0].date, DateTime(2026, 7, 11));
    });

    test('drops a day whose meals are all missing a label or description', () {
      final plan = mealPlanFromGeminiJson([
        {
          'date': '2026-07-11',
          'meals': [
            {'mealLabel': '', 'description': 'Algo'},
            {'mealLabel': 'Cena', 'description': ''},
          ],
        },
      ]);

      expect(plan.days, isEmpty);
    });

    test('returns an empty plan for an empty response', () {
      final plan = mealPlanFromGeminiJson([]);
      expect(plan.days, isEmpty);
    });
  });
}
