import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/security/api_key_store.dart';
import '../../domain/entities/confidence_level.dart';
import '../../domain/entities/food_component_breakdown.dart';
import '../../domain/entities/food_recognition_result.dart';
import '../../domain/entities/nutrition_info.dart';
import 'food_recognition_service.dart';

/// Thrown when the user hasn't configured a Gemini API key yet. The UI
/// catches this to prompt the user to add one in Configuración instead of
/// showing a generic error.
class MissingApiKeyException implements Exception {}

/// Converts Gemini's structured-output JSON into a [FoodRecognitionResult].
/// Split out from [GeminiFoodRecognitionService] so it's unit-testable
/// without a real network call.
FoodRecognitionResult foodRecognitionResultFromGeminiJson(
    Map<String, dynamic> json) {
  final confidence = switch (json['confidence']) {
    'high' => ConfidenceLevel.high,
    'low' => ConfidenceLevel.low,
    _ => ConfidenceLevel.medium,
  };

  return FoodRecognitionResult(
    foodName: (json['foodName'] as String?)?.trim() ?? 'Alimento no identificado',
    ingredients: (json['ingredients'] as List?)?.cast<String>() ?? const [],
    cookingMethod: json['cookingMethod'] as String?,
    estimatedWeightGrams: (json['estimatedWeightGrams'] as num?)?.toDouble(),
    servings: (json['servings'] as num?)?.toInt(),
    visibilityWarning: (json['visibilityWarning'] as String?)?.trim().isEmpty ==
            true
        ? null
        : json['visibilityWarning'] as String?,
    components: (json['components'] as List?)
            ?.cast<Map<String, dynamic>>()
            .map(FoodComponentBreakdown.fromJson)
            .toList() ??
        const [],
    nutrition: NutritionInfo(
      calories: (json['calories'] as num?)?.toDouble(),
      proteinGrams: (json['proteinGrams'] as num?)?.toDouble(),
      carbsGrams: (json['carbsGrams'] as num?)?.toDouble(),
      fatGrams: (json['fatGrams'] as num?)?.toDouble(),
      saturatedFatGrams: (json['saturatedFatGrams'] as num?)?.toDouble(),
      transFatGrams: (json['transFatGrams'] as num?)?.toDouble(),
      fiberGrams: (json['fiberGrams'] as num?)?.toDouble(),
      sugarsGrams: (json['sugarsGrams'] as num?)?.toDouble(),
      sodiumMilligrams: (json['sodiumMilligrams'] as num?)?.toDouble(),
      cholesterolMilligrams: (json['cholesterolMilligrams'] as num?)?.toDouble(),
      confidence: confidence,
    ),
  );
}

String mimeTypeForImagePath(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.heic')) return 'image/heic';
  return 'image/jpeg';
}

/// Real (non-mocked) food photo recognition using Google's Gemini Vision
/// API. The user supplies their own free API key (Configuración → clave de
/// IA), obtained at https://aistudio.google.com/app/apikey — see
/// [ApiKeyStore] for the security tradeoff this implies.
class GeminiFoodRecognitionService implements FoodRecognitionService {
  // An alias Google keeps pointed at its current recommended lightweight
  // flash model, rather than a pinned version like "gemini-2.5-flash" —
  // pinned versions get retired from new API keys with no advance warning
  // (confirmed the hard way: 2.5-flash 404'd for this key despite being
  // listed by ListModels as supporting generateContent). The non-"lite"
  // "gemini-flash-latest" alias also 503'd repeatedly under free-tier
  // demand; the lite variant has more free-tier headroom and is plenty
  // capable for this single-image classification task.
  static const _model = 'gemini-flash-lite-latest';
  static const _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

  static const _prompt = '''
Eres un experto en nutrición y en estimación de porciones a partir de
fotografías. Analiza la fotografía de este plato de comida y responde
ÚNICAMENTE con un objeto JSON (sin texto adicional) que describa el
alimento, sus porciones y su información nutricional aproximada para la
porción visible en la foto.

Estimación de porciones:
- Identifica cada componente visible del plato por separado (proteína,
  carbohidrato, vegetales, salsas, etc.) antes de estimar el peso total, y
  usa referencias de escala en la foto (tamaño del plato, cubiertos, taza)
  para calibrar el tamaño de cada porción con la mayor precisión posible.
- Presta atención a alimentos que suelen quedar parcial o totalmente
  cubiertos por otros en el mismo plato (por ejemplo: arroz y frijoles o
  "gallo pinto" debajo de huevos fritos, salsas debajo de una proteína,
  guarniciones debajo de una pieza principal). Si ves bordes, texturas o
  colores que sugieren que hay comida debajo o detrás de otro alimento,
  inclúyela con tu mejor estimación, aunque no sea completamente visible.
- Si sospechas que una parte relevante del plato podría no ser visible en
  la foto (por ejemplo, algo parece estar debajo de otro alimento, o el
  plato está cortado por el borde de la imagen), describe brevemente en
  "visibilityWarning" qué podría faltar por ver, en español, para que la
  persona pueda confirmarlo o tomar otra foto. Si el plato completo es
  claramente visible, usa null en ese campo.

Desglose por componente (obligatorio):
- Además de los totales del plato, llena "components": un arreglo con un
  objeto POR CADA alimento distinguible del plato (ej. "Huevo frito",
  "Arroz", "Frijoles", "Plátano maduro", "Aguacate", "Pan"), cada uno con su
  propio peso estimado en gramos y su propia información nutricional.
- La suma de "calories"/"proteinGrams"/"carbsGrams"/"fatGrams" de todos los
  elementos de "components" debe ser consistente con los totales generales
  del plato (calories, proteinGrams, carbsGrams, fatGrams a nivel raíz).
- No agrupes varios alimentos distintos en un solo componente (por ejemplo,
  "huevos y arroz" no es válido; deben ir como dos componentes separados).

Reglas importantes:
- Si no puedes determinar un valor con confianza razonable, usa null en ese
  campo en lugar de adivinar. Es preferible un dato faltante a uno incorrecto.
- "confidence" refleja tu nivel general de certeza sobre la identificación Y
  la estimación de porciones: usa "low" o "medium" (no "high") cuando haya
  alimentos parcial u ocultos, o cuando la escala del plato sea difícil de
  determinar.
- Los valores nutricionales son para el peso/porción estimado visible en la
  foto completa (sumando todos los componentes del plato), no por cada 100 g.
- Responde en español para foodName, ingredients, cookingMethod,
  visibilityWarning y el "name" de cada componente.
''';

  @override
  Future<FoodRecognitionResult> analyze(String photoPath) async {
    final apiKey = await ApiKeyStore.instance.getGeminiApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw MissingApiKeyException();
    }

    final bytes = await File(photoPath).readAsBytes();
    final base64Image = base64Encode(bytes);
    final mimeType = mimeTypeForImagePath(photoPath);

    final response = await http
        .post(
          Uri.parse(_endpoint),
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': apiKey,
          },
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': _prompt},
                  {
                    'inline_data': {'mime_type': mimeType, 'data': base64Image}
                  },
                ],
              },
            ],
            'generationConfig': {
              'responseMimeType': 'application/json',
              'responseSchema': _responseSchema,
              // Disable extended "thinking" — this is a straightforward
              // classification task, not one that benefits from deep
              // reasoning, and thinking adds significant latency.
              'thinkingConfig': {'thinkingBudget': 0},
            },
          }),
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode != 200) {
      throw HttpException(
          'Gemini API error ${response.statusCode}: ${response.body}');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final text = decoded['candidates'][0]['content']['parts'][0]['text']
        as String;
    final json = jsonDecode(text) as Map<String, dynamic>;

    return foodRecognitionResultFromGeminiJson(json);
  }

  static const _responseSchema = {
    'type': 'OBJECT',
    'properties': {
      'foodName': {'type': 'STRING'},
      'ingredients': {
        'type': 'ARRAY',
        'items': {'type': 'STRING'},
      },
      'cookingMethod': {'type': 'STRING', 'nullable': true},
      'estimatedWeightGrams': {'type': 'NUMBER', 'nullable': true},
      'servings': {'type': 'INTEGER', 'nullable': true},
      'visibilityWarning': {'type': 'STRING', 'nullable': true},
      'components': {
        'type': 'ARRAY',
        'items': {
          'type': 'OBJECT',
          'properties': {
            'name': {'type': 'STRING'},
            'estimatedWeightGrams': {'type': 'NUMBER', 'nullable': true},
            'calories': {'type': 'NUMBER', 'nullable': true},
            'proteinGrams': {'type': 'NUMBER', 'nullable': true},
            'carbsGrams': {'type': 'NUMBER', 'nullable': true},
            'fatGrams': {'type': 'NUMBER', 'nullable': true},
          },
          'required': ['name'],
        },
      },
      'confidence': {
        'type': 'STRING',
        'enum': ['high', 'medium', 'low'],
      },
      'calories': {'type': 'NUMBER', 'nullable': true},
      'proteinGrams': {'type': 'NUMBER', 'nullable': true},
      'carbsGrams': {'type': 'NUMBER', 'nullable': true},
      'fatGrams': {'type': 'NUMBER', 'nullable': true},
      'saturatedFatGrams': {'type': 'NUMBER', 'nullable': true},
      'transFatGrams': {'type': 'NUMBER', 'nullable': true},
      'fiberGrams': {'type': 'NUMBER', 'nullable': true},
      'sugarsGrams': {'type': 'NUMBER', 'nullable': true},
      'sodiumMilligrams': {'type': 'NUMBER', 'nullable': true},
      'cholesterolMilligrams': {'type': 'NUMBER', 'nullable': true},
    },
    'required': ['foodName', 'ingredients', 'confidence'],
  };
}
