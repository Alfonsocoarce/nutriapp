import '../../domain/entities/food_recognition_result.dart';
import 'food_recognition_service.dart';
import 'gemini_food_recognition_service.dart';

/// Reads a printed "Datos Nutricionales" / "Nutrition Facts" label from a
/// packaged product photo, instead of estimating from a plate of food.
/// Shares the HTTP/parsing plumbing with [GeminiFoodRecognitionService] —
/// only the prompt (read, don't estimate) and schema (no per-plate
/// components/visibility warning) differ.
class GeminiLabelRecognitionService implements FoodRecognitionService {
  static const _prompt = '''
Eres un experto en lectura de tablas de información nutricional impresas
en empaques de productos alimenticios. Esta fotografía muestra la etiqueta
"Datos Nutricionales" (o "Nutrition Facts") de un producto envasado.
Responde ÚNICAMENTE con un objeto JSON (sin texto adicional).

Reglas importantes:
- Lee ÚNICAMENTE los valores que aparecen impresos en la etiqueta. NO
  estimes ni inventes un valor que no puedas leer con claridad: usa null
  en ese campo en lugar de adivinar.
- "estimatedWeightGrams" es el tamaño de porción impreso (Tamaño de
  Porción / Serving Size), en gramos.
- "servings" son las porciones por envase (Porciones por Envase / Servings
  Per Container), si aparecen impresas.
- Los valores nutricionales (calories, proteinGrams, carbsGrams, etc.) son
  los impresos PARA UNA PORCIÓN, no para el envase completo ni por cada
  100 g, salvo que la etiqueta indique explícitamente que ya corresponden
  al envase completo — en ese caso acláralo usando el mismo valor pero
  asumiendo que es lo que el usuario consumirá.
- "confidence" debe ser "high" cuando el texto de la etiqueta es legible
  con claridad (estás leyendo un dato impreso, no estimando visualmente).
  Usa "medium" o "low" solo si partes del texto están borrosas, cortadas,
  con reflejos o ilegibles.
- "foodName" es el nombre del producto si es visible en la foto (marca +
  producto), o una descripción breve y genérica si no se alcanza a leer
  (ej. "Producto envasado sin nombre legible").
- Responde en español para foodName.
''';

  static const _responseSchema = {
    'type': 'OBJECT',
    'properties': {
      'foodName': {'type': 'STRING'},
      'ingredients': {
        'type': 'ARRAY',
        'items': {'type': 'STRING'},
      },
      'estimatedWeightGrams': {'type': 'NUMBER', 'nullable': true},
      'servings': {'type': 'INTEGER', 'nullable': true},
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
    'required': ['foodName', 'confidence'],
  };

  @override
  Future<FoodRecognitionResult> analyze(String photoPath) async {
    final json = await callGeminiVisionJson(
      photoPath: photoPath,
      prompt: _prompt,
      responseSchema: _responseSchema,
    );
    return foodRecognitionResultFromGeminiJson(json);
  }
}
