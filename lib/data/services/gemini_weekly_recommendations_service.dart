import '../../domain/entities/food_frequency.dart';
import '../../domain/entities/nutrition_goal.dart';
import '../../domain/entities/weekly_summary.dart';
import '../../domain/usecases/build_weekly_recommendations.dart';
import 'gemini_food_recognition_service.dart';

String _goalLabel(NutritionGoal g) => switch (g) {
      NutritionGoal.loseWeight => 'Perder peso',
      NutritionGoal.gainMuscle => 'Aumentar masa muscular',
      NutritionGoal.maintainWeight => 'Mantener peso',
      NutritionGoal.reduceCholesterol => 'Reducir colesterol',
      NutritionGoal.controlDiabetes => 'Controlar diabetes',
      NutritionGoal.regulateSugar => 'Regular el azúcar en sangre',
      NutritionGoal.healthyEating => 'Alimentación saludable',
      NutritionGoal.reduceBodyFat => 'Reducir grasa corporal',
      NutritionGoal.improvePerformance => 'Mejorar rendimiento físico',
    };

/// Generates concrete, portion-level weekly nutrition recommendations with
/// Gemini — acting as an AI nutritionist that reasons over the user's
/// goals/restrictions/allergies and their actual week of logged food,
/// rather than the generic rule-of-thumb tips in [buildWeeklyRecommendations].
///
/// Falls back to the deterministic rule-based recommendations if the AI
/// call fails for any reason (no API key configured, offline, malformed
/// response) so PDF generation never hard-fails on a network problem.
class GeminiWeeklyRecommendationsService {
  static const _responseSchema = {
    'type': 'ARRAY',
    'items': {'type': 'STRING'},
  };

  Future<List<String>> generate(
    WeeklySummary summary,
    List<FoodFrequency> topFoods,
  ) async {
    try {
      final json = await callGeminiTextJson(
        prompt: _buildPrompt(summary, topFoods),
        responseSchema: _responseSchema,
      );
      final tips = (json as List).cast<String>().where((t) => t.trim().isNotEmpty).toList();
      if (tips.isEmpty) throw const FormatException('empty recommendations');
      return tips.take(6).toList();
    } catch (_) {
      return buildWeeklyRecommendations(summary);
    }
  }

  String _buildPrompt(WeeklySummary summary, List<FoodFrequency> topFoods) {
    final profile = summary.profile;
    final goalsText = profile.goals.isEmpty
        ? 'Ninguno especificado'
        : profile.goals.map(_goalLabel).join(', ');
    final restrictionsText =
        profile.restrictions.isEmpty ? 'Ninguna' : profile.restrictions.join(', ');
    final allergiesText = profile.allergies.isEmpty ? 'Ninguna' : profile.allergies.join(', ');
    final diseasesText = profile.diseases.isEmpty ? 'Ninguna' : profile.diseases.join(', ');
    final topFoodsText = topFoods.isEmpty
        ? 'Sin datos suficientes'
        : topFoods
            .map((f) => '${f.name} (registrado ${f.count} ${f.count == 1 ? 'vez' : 'veces'})')
            .join(', ');

    return '''
Eres un nutricionista profesional experto. Analiza los datos reales de la
semana de un usuario y responde ÚNICAMENTE con un arreglo JSON de 4 a 6
strings (sin texto adicional), cada uno una recomendación nutricional para
la próxima semana.

Perfil del usuario:
- Objetivo(s): $goalsText
- Restricciones alimentarias: $restrictionsText
- Alergias: $allergiesText
- Condiciones de salud: $diseasesText
- Peso actual: ${profile.currentWeightKg} kg, peso objetivo: ${profile.targetWeightKg} kg
- Meta calórica diaria estimada: ${profile.dailyCalorieGoal.round()} kcal

Resumen de la semana pasada (lunes a domingo, ${summary.daysLogged} de 7
días con registros):
- Calorías promedio consumidas: ${summary.avgCaloriesConsumed.round()} kcal/día
- Proteína promedio: ${summary.avgProteinGrams.round()} g/día
- Carbohidratos promedio: ${summary.avgCarbsGrams.round()} g/día
- Grasas promedio: ${summary.avgFatGrams.round()} g/día
- Sodio promedio: ${summary.avgSodiumMilligrams.round()} mg/día
- Fibra promedio: ${summary.avgFiberGrams.round()} g/día
- Alimentos más consumidos esta semana: $topFoodsText

Instrucciones para cada recomendación:
- Debe ser específica y accionable, no genérica: menciona porciones en
  gramos, onzas o unidades concretas (ej. "reduce el arroz a 150 g por
  comida", "agrega 100 g de pechuga de pollo a la cena"), tipos de
  alimentos concretos, y en qué comida del día aplicarla cuando tenga
  sentido.
- NUNCA recomiendes un alimento que aparezca en las restricciones o
  alergias del usuario.
- Ajusta el enfoque al objetivo principal del usuario (ej. si el objetivo
  incluye "Perder peso", prioriza déficit calórico moderado y control de
  porciones; si incluye "Aumentar masa muscular", prioriza proteína
  suficiente bien distribuida en el día; si incluye condiciones como
  diabetes o colesterol, ajusta azúcares/grasas saturadas en consecuencia).
- Basa al menos una recomendación en los alimentos más consumidos de la
  semana (por ejemplo, sugerir una alternativa o ajuste de porción a uno
  de ellos si aplica).
- Si hubo pocos días con registros (menos de 4 de 7), incluye una
  recomendación sobre registrar con más constancia.
- Responde en español, en un arreglo JSON de strings simples, sin
  markdown ni numeración dentro del texto.
''';
  }
}
