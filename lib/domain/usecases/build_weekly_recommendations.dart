import '../entities/nutrition_goal.dart';
import '../entities/weekly_summary.dart';

/// Deterministic, rule-based portion/nutrition recommendations for a
/// [WeeklySummary] — no AI call: this is arithmetic against well-known
/// nutrition guidelines (protein per kg body weight, WHO sodium limit,
/// daily fiber target), fast and free to run for every report.
List<String> buildWeeklyRecommendations(WeeklySummary summary) {
  if (summary.daysLogged == 0) {
    return const [
      'No registraste comidas durante esta semana, así que no fue posible '
          'generar recomendaciones basadas en tu consumo real. Registra tus '
          'comidas con más frecuencia para obtener un resumen útil.',
    ];
  }

  final tips = <String>[];
  final profile = summary.profile;
  final avgCal = summary.avgCaloriesConsumed;
  final goalCal = summary.avgCaloriesGoal;

  if (goalCal > 0 && avgCal > goalCal * 1.10) {
    final diff = (avgCal - goalCal).round();
    tips.add(
        'Tu consumo promedio (${avgCal.round()} kcal/día) superó tu meta '
        'calórica (${goalCal.round()} kcal/día) en $diff kcal. Considera '
        'reducir el tamaño de las porciones o la frecuencia de alimentos '
        'altos en calorías.');
  } else if (goalCal > 0 && avgCal < goalCal * 0.85) {
    final diff = (goalCal - avgCal).round();
    tips.add(
        'Tu consumo promedio (${avgCal.round()} kcal/día) estuvo por debajo '
        'de tu meta calórica (${goalCal.round()} kcal/día) en $diff kcal. '
        'Asegúrate de cubrir tus necesidades energéticas diarias.');
  } else {
    tips.add(
        'Tu consumo calórico promedio (${avgCal.round()} kcal/día) estuvo '
        'dentro de un rango saludable respecto a tu meta '
        '(${goalCal.round()} kcal/día).');
  }

  final proteinFactor = profile.goals.contains(NutritionGoal.gainMuscle) ||
          profile.goals.contains(NutritionGoal.improvePerformance)
      ? 1.6
      : profile.goals.contains(NutritionGoal.reduceBodyFat)
          ? 1.2
          : 0.9;
  final recommendedProtein = profile.currentWeightKg * proteinFactor;
  if (summary.avgProteinGrams < recommendedProtein * 0.8) {
    tips.add(
        'Tu ingesta de proteína promedio (${summary.avgProteinGrams.round()} '
        'g/día) está por debajo de lo recomendado (~${recommendedProtein.round()} '
        'g/día) para tu perfil. Incluye más huevos, pollo, pescado, legumbres '
        'o lácteos.');
  }

  if (summary.avgFiberGrams > 0 && summary.avgFiberGrams < 25) {
    tips.add(
        'Tu consumo de fibra promedio (${summary.avgFiberGrams.round()} '
        'g/día) fue menor a los 25 g/día recomendados. Agrega más frutas, '
        'vegetales y granos integrales.');
  }

  if (summary.avgSodiumMilligrams > 2300) {
    tips.add(
        'Tu consumo de sodio promedio (${summary.avgSodiumMilligrams.round()} '
        'mg/día) superó el límite recomendado (2300 mg/día). Reduce alimentos '
        'procesados o con alto contenido de sal.');
  }

  if (summary.daysLogged < 7) {
    tips.add(
        'Registraste comidas en ${summary.daysLogged} de 7 días esta '
        'semana. Un registro más constante te dará recomendaciones más '
        'precisas.');
  }

  return tips.take(5).toList();
}
