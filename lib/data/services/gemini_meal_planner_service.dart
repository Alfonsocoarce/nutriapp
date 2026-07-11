import '../../domain/entities/food_entry.dart';
import '../../domain/entities/meal_plan.dart';
import '../../domain/entities/nutrition_goal.dart';
import '../../domain/entities/pantry_item.dart';
import '../../domain/entities/weekly_summary.dart';
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

/// Converts Gemini's structured-output JSON into a [MealPlan]. Split out so
/// it's unit-testable without a real network call.
MealPlan mealPlanFromGeminiJson(List<dynamic> json) {
  final days = <MealPlanDay>[];
  for (final rawDay in json) {
    final dayMap = rawDay as Map<String, dynamic>;
    final date = DateTime.tryParse(dayMap['date'] as String? ?? '');
    if (date == null) continue;
    final meals = (dayMap['meals'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map((m) => PlannedMeal(
              mealLabel: (m['mealLabel'] as String?)?.trim() ?? '',
              description: (m['description'] as String?)?.trim() ?? '',
            ))
        .where((m) => m.mealLabel.isNotEmpty && m.description.isNotEmpty)
        .toList();
    if (meals.isEmpty) continue;
    days.add(MealPlanDay(date: date, meals: meals));
  }
  return MealPlan(days: days);
}

/// Generates a short-horizon (3-day) meal plan with Gemini, built primarily
/// from the food the user already has in their pantry — favoring items
/// closest to expiring — and shaped to match how the user actually combines
/// foods, inferred from their recent logged meals rather than a generic
/// recipe book. Returns [MealPlan.empty] if the AI call fails for any
/// reason (no API key, offline, malformed response, nothing in the pantry
/// to plan around) so the weekly report never hard-fails on this section —
/// it just shows "not available this time" instead of a guessed plan.
class GeminiMealPlannerService {
  static const _planDays = 3;

  static const _responseSchema = {
    'type': 'ARRAY',
    'items': {
      'type': 'OBJECT',
      'properties': {
        'date': {'type': 'STRING'},
        'meals': {
          'type': 'ARRAY',
          'items': {
            'type': 'OBJECT',
            'properties': {
              'mealLabel': {'type': 'STRING'},
              'description': {'type': 'STRING'},
            },
            'required': ['mealLabel', 'description'],
          },
        },
      },
      'required': ['date', 'meals'],
    },
  };

  Future<MealPlan> generate(
    WeeklySummary summary,
    List<PantryItem> pantryItems,
    List<FoodEntry> recentEntries,
  ) async {
    if (pantryItems.isEmpty) return MealPlan.empty;
    try {
      final json = await callGeminiTextJson(
        prompt: _buildPrompt(summary, pantryItems, recentEntries),
        responseSchema: _responseSchema,
      );
      final plan = mealPlanFromGeminiJson(json as List);
      return plan.days.isEmpty ? MealPlan.empty : plan;
    } catch (_) {
      return MealPlan.empty;
    }
  }

  String _buildPrompt(
    WeeklySummary summary,
    List<PantryItem> pantryItems,
    List<FoodEntry> recentEntries,
  ) {
    final profile = summary.profile;
    final goalsText = profile.goals.isEmpty
        ? 'Ninguno especificado'
        : profile.goals.map(_goalLabel).join(', ');
    final restrictionsText =
        profile.restrictions.isEmpty ? 'Ninguna' : profile.restrictions.join(', ');
    final allergiesText = profile.allergies.isEmpty ? 'Ninguna' : profile.allergies.join(', ');

    final pantryText = pantryItems
        .map((item) {
          final expiry = item.daysRemaining == null
              ? ''
              : item.isExpired
                  ? ' [YA VENCIDO]'
                  : item.isExpiringSoon
                      ? ' [vence en ${item.daysRemaining} días, usar primero]'
                      : '';
          return '${item.productName} (${item.quantity} ${item.unit})$expiry';
        })
        .join(', ');

    final habitsText = recentEntries.isEmpty
        ? 'Sin datos suficientes de registros previos'
        : recentEntries
            .map((e) => '${_mealTypeLabel(e)}: ${e.foodName}')
            .join('; ');

    final today = DateTime.now();
    final firstPlanDate = DateTime(today.year, today.month, today.day)
        .add(const Duration(days: 1));

    return '''
Eres un nutricionista y planificador de comidas experto. Genera un plan de
comidas de $_planDays días (empezando el ${_isoDate(firstPlanDate)}) para un
usuario, usando SOBRE TODO los productos que ya tiene en su despensa, y
combinando los alimentos de forma parecida a como el usuario ya los combina
normalmente (ver "Hábitos recientes" abajo). Responde ÚNICAMENTE con un
arreglo JSON de $_planDays objetos, cada uno con "date" (formato
YYYY-MM-DD) y "meals" (arreglo de objetos con "mealLabel" en español, ej.
"Desayuno"/"Almuerzo"/"Cena"/"Merienda", y "description": una comida
concreta y apetecible con sus ingredientes principales).

Perfil del usuario:
- Objetivo(s): $goalsText
- Restricciones alimentarias: $restrictionsText
- Alergias: $allergiesText
- Meta calórica diaria estimada: ${profile.dailyCalorieGoal.round()} kcal

Despensa actual (producto, cantidad, y aviso si vence pronto o ya venció):
$pantryText

Hábitos recientes (comidas registradas en los últimos días, en formato
"tipo de comida: nombre del alimento"), para inferir cómo el usuario
combina alimentos y qué tipo de comidas prefiere en cada momento del día:
$habitsText

Instrucciones:
- Prioriza usar los productos de la despensa, especialmente los marcados
  como "vence en X días" o "YA VENCIDO", para evitar que se desperdicien.
- No repitas exactamente la misma comida los $_planDays días; varía dentro
  de lo que la despensa permite.
- NUNCA incluyas un alimento que aparezca en las restricciones o alergias
  del usuario.
- Si la despensa no alcanza para completar alguna comida de forma
  razonable, puedes sugerir 1-2 ingredientes adicionales comunes que no
  estén en la despensa, pero la mayoría de cada comida debe salir de la
  despensa.
- Ajusta las porciones/tipo de comida a la meta calórica y objetivo del
  usuario.
- Responde en español, solo el arreglo JSON, sin texto ni markdown
  adicional.
''';
  }

  String _mealTypeLabel(FoodEntry e) => switch (e.mealType.name) {
        'breakfast' => 'Desayuno',
        'morningSnack' => 'Merienda de mañana',
        'lunch' => 'Almuerzo',
        'afternoonSnack' => 'Merienda de tarde',
        'dinner' => 'Cena',
        'drink' => 'Bebida',
        'dessert' => 'Postre',
        _ => e.mealType.name,
      };

  String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
