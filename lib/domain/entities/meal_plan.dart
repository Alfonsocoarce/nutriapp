/// One suggested meal within a [MealPlanDay] (e.g. "Desayuno: Gallo pinto
/// con huevo y aguacate"), generated to match the user's current pantry
/// stock and recent logging habits rather than a generic recipe.
class PlannedMeal {
  final String mealLabel;
  final String description;

  const PlannedMeal({required this.mealLabel, required this.description});
}

/// All the meals suggested for a single upcoming day.
class MealPlanDay {
  final DateTime date;
  final List<PlannedMeal> meals;

  const MealPlanDay({required this.date, required this.meals});
}

/// AI-generated short-horizon meal plan built from the user's current
/// pantry stock and recent logging habits (see [GeminiMealPlannerService]
/// in `data/services/gemini_meal_planner_service.dart`). An empty [days]
/// list means no plan could be generated this time (no API key, empty
/// pantry, request failure) — the UI/PDF show that explicitly instead of
/// inventing a plan.
class MealPlan {
  final List<MealPlanDay> days;

  const MealPlan({required this.days});

  static const empty = MealPlan(days: []);
}
