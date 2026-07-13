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
    improvementTip: (json['improvementTip'] as String?)?.trim().isEmpty == true
        ? null
        : json['improvementTip'] as String?,
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

// An alias Google keeps pointed at its current recommended lightweight
// flash model, rather than a pinned version like "gemini-2.5-flash" —
// pinned versions get retired from new API keys with no advance warning
// (confirmed the hard way: 2.5-flash 404'd for this key despite being
// listed by ListModels as supporting generateContent). The non-"lite"
// "gemini-flash-latest" alias also 503'd repeatedly under free-tier
// demand; the lite variant has more free-tier headroom and is plenty
// capable for this single-image classification task.
const _geminiModel = 'gemini-flash-lite-latest';
const _geminiEndpoint =
    'https://generativelanguage.googleapis.com/v1beta/models/$_geminiModel:generateContent';

/// Shared low-level caller for Gemini structured-JSON requests (with or
/// without an image part). Returns the decoded JSON payload — a Map for
/// object schemas, a List for array schemas.
Future<dynamic> _callGeminiJson({
  required String prompt,
  required Map<String, dynamic> responseSchema,
  String? photoPath,
  int thinkingBudget = 0,
}) async {
  final apiKey = await ApiKeyStore.instance.getGeminiApiKey();
  if (apiKey == null || apiKey.isEmpty) {
    throw MissingApiKeyException();
  }

  final parts = <Map<String, dynamic>>[
    {'text': prompt}
  ];
  if (photoPath != null) {
    final bytes = await File(photoPath).readAsBytes();
    parts.add({
      'inline_data': {
        'mime_type': mimeTypeForImagePath(photoPath),
        'data': base64Encode(bytes),
      },
    });
  }

  final response = await http
      .post(
        Uri.parse(_geminiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': apiKey,
        },
        body: jsonEncode({
          'contents': [
            {'parts': parts},
          ],
          'generationConfig': {
            'responseMimeType': 'application/json',
            'responseSchema': responseSchema,
            // Most calls here are straightforward classification/generation
            // tasks that don't benefit from deep reasoning, so thinking is
            // off (budget 0) by default to keep latency low. Meal-photo
            // recognition is the exception — accurately identifying every
            // component, weighing it against visual references, and cross-
            // checking known nutrition data is exactly the kind of
            // multi-step estimation "thinking" mode helps with, so it opts
            // into dynamic thinking (budget -1) at the cost of some speed.
            'thinkingConfig': {'thinkingBudget': thinkingBudget},
          },
        }),
      )
      .timeout(const Duration(seconds: 90));

  if (response.statusCode != 200) {
    throw HttpException(
        'Gemini API error ${response.statusCode}: ${response.body}');
  }

  final decoded = jsonDecode(utf8.decode(response.bodyBytes));
  final text = decoded['candidates'][0]['content']['parts'][0]['text'] as String;
  return jsonDecode(text);
}

/// Shared low-level caller for Gemini Vision structured-JSON requests. Used
/// by both meal-photo and nutrition-label recognition — only the prompt and
/// response schema differ between those use cases.
Future<Map<String, dynamic>> callGeminiVisionJson({
  required String photoPath,
  required String prompt,
  required Map<String, dynamic> responseSchema,
  int thinkingBudget = 0,
}) async {
  final json = await _callGeminiJson(
    prompt: prompt,
    responseSchema: responseSchema,
    photoPath: photoPath,
    thinkingBudget: thinkingBudget,
  );
  return json as Map<String, dynamic>;
}

/// Shared low-level caller for text-only Gemini structured-JSON requests
/// (no image) — used for text-generation use cases like AI recommendations.
Future<dynamic> callGeminiTextJson({
  required String prompt,
  required Map<String, dynamic> responseSchema,
}) {
  return _callGeminiJson(prompt: prompt, responseSchema: responseSchema);
}

/// Real (non-mocked) food photo recognition using Google's Gemini Vision
/// API. The user supplies their own free API key (Configuración → clave de
/// IA), obtained at https://aistudio.google.com/app/apikey — see
/// [ApiKeyStore] for the security tradeoff this implies.
class GeminiFoodRecognitionService implements FoodRecognitionService {
  static const _prompt = '''
Actúa como una persona nutricionista clínica certificada con formación en
ciencia de los alimentos y años de experiencia estimando porciones a
partir de fotografías (el mismo método que usan en consulta: el "método
del plato" y comparación con objetos de referencia). Analiza la
fotografía de este plato de comida con el mayor rigor posible y responde
ÚNICAMENTE con un objeto JSON (sin texto adicional).

Sigue este proceso, en orden, antes de responder:

1. IDENTIFICACIÓN: Mira la foto completa primero. Enumera mentalmente cada
   alimento distinguible (proteína, carbohidrato, vegetales, salsas,
   bebidas, postres, etc.), incluyendo los que sueles ver parcialmente
   cubiertos por otros (ej. arroz y frijoles o "gallo pinto" debajo de
   huevos fritos, salsas debajo de una proteína, guarniciones debajo de
   una pieza principal). Si ves bordes, texturas o colores que sugieren
   comida debajo o detrás de otro alimento, inclúyela con tu mejor
   estimación aunque no sea 100% visible.
2. ESCALA Y REFERENCIA: Usa objetos de referencia visibles en la foto para
   calibrar tamaños — un plato llano estándar mide 24-27 cm de diámetro,
   uno de postre/ensalada 18-20 cm, un tenedor ~19 cm, una cuchara sopera
   ~15 cm, una taza estándar 240 ml, un huevo mediano ~50 g. Para
   alimentos discretos, cuenta unidades (ej. "2 huevos", "3 tortillas")
   en vez de solo estimar un peso agregado.
3. PESO Y PORCIÓN: Con la escala calibrada, estima el peso en gramos (o
   volumen en ml para líquidos) de cada componente por separado.
4. NUTRICIÓN: Para cada componente, calcula la información nutricional
   usando tu conocimiento de tablas de composición de alimentos
   reconocidas (USDA FoodData Central, tablas de composición de alimentos
   de Centroamérica del INCAP) aplicada al peso estimado — no repitas de
   memoria valores por 100 g sin ajustarlos a la porción real.
5. AUTOEVALUACIÓN: Solo al final, decide "confidence" según qué tan clara
   estuvo la foto y qué tan seguro quedaste de la escala y del contenido
   oculto.

Reglas de identificación:
- "foodName" debe ser el nombre real y específico del plato o alimento
  (ej. "Gallo pinto con huevo frito y plátano maduro", "Casado con
  pollo", "Ensalada César con pollo"). NUNCA generes un nombre genérico
  tipo "Desayuno con X, Y y Z" o "Almuerzo con..." — si no reconoces un
  nombre de plato típico, describe el componente principal de forma
  concreta (ej. "Huevos fritos con acompañamientos", no "Desayuno").
- Si sospechas que una parte relevante del plato podría no ser visible
  (algo parece estar debajo de otro alimento, o el plato está cortado por
  el borde de la imagen), describe brevemente en "visibilityWarning" qué
  podría faltar por ver, en español. Si el plato completo es claramente
  visible, usa null en ese campo.

Desglose por componente (obligatorio):
- Además de los totales del plato, llena "components": un objeto POR CADA
  alimento distinguible (ej. "Huevo frito", "Arroz", "Frijoles", "Plátano
  maduro", "Aguacate", "Pan"), cada uno con su propio peso estimado en
  gramos y su propia información nutricional. Incluye la cantidad en el
  nombre cuando aplique (ej. "2 huevos fritos").
- La suma de "calories"/"proteinGrams"/"carbsGrams"/"fatGrams" de todos
  los "components" debe ser consistente con los totales a nivel raíz.
- No agrupes varios alimentos distintos en un solo componente (ej.
  "huevos y arroz" no es válido; van como dos componentes separados).

Reglas sobre precisión y campos vacíos (importante — leer con cuidado):
- Como experta/o, tu trabajo es DAR UNA ESTIMACIÓN RAZONADA siempre que el
  alimento sea identificable, igual que harías en una consulta real con
  información visual limitada — no dejar el campo en blanco por
  precaución. Usa null en los campos numéricos ÚNICAMENTE cuando el
  alimento en sí no se pueda identificar de ninguna forma razonable (por
  ejemplo, el objeto no es reconocible como comida, o la imagen está
  completamente fuera de foco, o no hay comida visible). Una estimación
  razonada con "confidence": "low" ayuda mucho más a la persona que un
  campo vacío sin ninguna cifra.
- "confidence" refleja tu certeza general sobre identificación Y
  porciones: usa "low" o "medium" (no "high") cuando haya alimentos
  parcial u ocultos, ángulos difíciles, poca luz, o escala ambigua — pero
  igual entrega tu mejor número.
- Si "confidence" es "medium" o "low", llena "improvementTip" con 1-2
  oraciones concretas y accionables en español sobre qué debería hacer la
  persona al tomar la próxima foto para lograr un resultado más preciso
  (ej. "Acércate más y evita que otros alimentos tapen el plato",
  "Fotografía desde arriba con buena luz, mostrando el plato completo sin
  cortar los bordes", "Aleja un poco la cámara para que se vea el plato
  completo junto a un objeto de referencia como un tenedor"). Si
  "confidence" es "high", usa null en "improvementTip".
- Los valores nutricionales son para el peso/porción total estimado
  visible en la foto (sumando todos los componentes), no por cada 100 g.
- Responde en español para foodName, ingredients, cookingMethod,
  visibilityWarning, improvementTip y el "name" de cada componente.
''';

  @override
  Future<FoodRecognitionResult> analyze(String photoPath) async {
    final json = await callGeminiVisionJson(
      photoPath: photoPath,
      prompt: _prompt,
      responseSchema: _responseSchema,
      // Dynamic thinking: accurately identifying every component, scaling
      // it against visual references, and cross-checking known nutrition
      // data benefits from multi-step reasoning far more than the other
      // (simpler) Gemini calls in this app do — worth the extra latency.
      thinkingBudget: -1,
    );
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
      'improvementTip': {'type': 'STRING', 'nullable': true},
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
    'required': ['foodName', 'ingredients', 'confidence', 'components'],
  };
}
