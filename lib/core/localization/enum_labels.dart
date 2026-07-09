import '../../domain/entities/activity_level.dart';
import '../../domain/entities/meal_type.dart';
import '../../domain/entities/nutrition_goal.dart';
import '../../domain/entities/pantry_category.dart';
import '../../domain/entities/sex.dart';
import '../../l10n/app_localizations.dart';

extension SexLabel on Sex {
  String label(AppLocalizations l10n) => switch (this) {
        Sex.male => l10n.profileSexMale,
        Sex.female => l10n.profileSexFemale,
        Sex.other => l10n.profileSexOther,
      };
}

extension ActivityLevelLabel on ActivityLevel {
  String label(AppLocalizations l10n) => switch (this) {
        ActivityLevel.sedentary => l10n.profileActivitySedentary,
        ActivityLevel.light => l10n.profileActivityLight,
        ActivityLevel.moderate => l10n.profileActivityModerate,
        ActivityLevel.active => l10n.profileActivityActive,
        ActivityLevel.veryActive => l10n.profileActivityVeryActive,
      };
}

extension NutritionGoalLabel on NutritionGoal {
  String label(AppLocalizations l10n) => switch (this) {
        NutritionGoal.loseWeight => l10n.goalLoseWeight,
        NutritionGoal.gainMuscle => l10n.goalGainMuscle,
        NutritionGoal.maintainWeight => l10n.goalMaintainWeight,
        NutritionGoal.reduceCholesterol => l10n.goalReduceCholesterol,
        NutritionGoal.controlDiabetes => l10n.goalControlDiabetes,
        NutritionGoal.regulateSugar => l10n.goalRegulateSugar,
        NutritionGoal.healthyEating => l10n.goalHealthyEating,
        NutritionGoal.reduceBodyFat => l10n.goalReduceBodyFat,
        NutritionGoal.improvePerformance => l10n.goalImprovePerformance,
      };
}

extension MealTypeLabel on MealType {
  String label(AppLocalizations l10n) => switch (this) {
        MealType.breakfast => l10n.mealTypeBreakfast,
        MealType.morningSnack => l10n.mealTypeMorningSnack,
        MealType.lunch => l10n.mealTypeLunch,
        MealType.afternoonSnack => l10n.mealTypeAfternoonSnack,
        MealType.dinner => l10n.mealTypeDinner,
        MealType.drink => l10n.mealTypeDrink,
        MealType.dessert => l10n.mealTypeDessert,
      };
}

extension PantryCategoryLabel on PantryCategory {
  String label(AppLocalizations l10n) => switch (this) {
        PantryCategory.fruits => l10n.pantryCategoryFruits,
        PantryCategory.vegetables => l10n.pantryCategoryVegetables,
        PantryCategory.meats => l10n.pantryCategoryMeats,
        PantryCategory.fish => l10n.pantryCategoryFish,
        PantryCategory.seafood => l10n.pantryCategorySeafood,
        PantryCategory.dairy => l10n.pantryCategoryDairy,
        PantryCategory.grains => l10n.pantryCategoryGrains,
        PantryCategory.legumes => l10n.pantryCategoryLegumes,
        PantryCategory.snacks => l10n.pantryCategorySnacks,
        PantryCategory.beverages => l10n.pantryCategoryBeverages,
        PantryCategory.frozen => l10n.pantryCategoryFrozen,
        PantryCategory.condiments => l10n.pantryCategoryCondiments,
      };
}
