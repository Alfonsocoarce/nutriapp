import '../../domain/entities/food_exchange_group.dart';

/// The mother's real diet plan, transcribed from the nutritionist's
/// "Lista de Intercambios" — only the "Harinas" group was provided.
///
/// The other groups are conservative general reference tables (few items,
/// low-sodium and low-saturated-fat choices given her hypertension and
/// dyslipidemia) added only to fill the gaps the nutritionist's document
/// didn't cover. They are flagged [FoodExchangeSource.generalReference] so
/// the UI can always show which numbers are her actual prescription versus
/// a placeholder — if she gets the rest of the plan from her nutritionist,
/// replace the matching group here with it.
const nutritionistExchangePlan = <FoodExchangeGroup>[
  FoodExchangeGroup(
    name: 'Harinas',
    icon: '🍚',
    guidance: 'Cada opción de la lista equivale a una porción. Elige solo una por comida.',
    source: FoodExchangeSource.nutritionist,
    items: [
      FoodExchangeItem(food: 'Arroz blanco o integral', portion: '½ taza'),
      FoodExchangeItem(
          food: 'Frijoles, lentejas, arvejas cubaces, garbanzos', portion: '½ taza'),
      FoodExchangeItem(food: 'Gallo pinto', portion: '½ taza'),
      FoodExchangeItem(food: 'Espagueti, fideos, caracolitos, etc.', portion: '½ taza'),
      FoodExchangeItem(food: 'Pan baguette', portion: '4 dedos'),
      FoodExchangeItem(food: 'Pan cuadrado', portion: '1 tajada mediana'),
      FoodExchangeItem(food: 'Pan de perro o hamburguesa', portion: '½ unidad'),
      FoodExchangeItem(food: 'Pan tipo bollitos, dedos o piña', portion: '1 unidad'),
      FoodExchangeItem(food: 'Tortillas tortirricas', portion: '2 unidades'),
      FoodExchangeItem(food: 'Tortillas del fogón o campesina', portion: '1 unidad'),
      FoodExchangeItem(food: 'Galleta María o soda', portion: '1 paquete'),
      FoodExchangeItem(food: 'Cereal en hojuelas de maíz sin azúcar', portion: '¾ de taza'),
      FoodExchangeItem(food: 'Avena', portion: '¼ de taza o 2 cucharadas'),
      FoodExchangeItem(food: 'Harina de trigo', portion: '3 cucharadas'),
      FoodExchangeItem(food: 'Harina de maíz (masa)', portion: '2 cucharadas'),
      FoodExchangeItem(
        food: 'Papa, yuca, camote, ayote sazón, elote, tiquizque, ñame, ñampí, etc.',
        portion: '1 trozo mediano o ½ taza si es puré',
      ),
    ],
  ),
  FoodExchangeGroup(
    name: 'Vegetales',
    icon: '🥦',
    guidance:
        'Son la "barrera" que menciona tu plan: acompañan cada comida y ayudan a que el azúcar suba más despacio. Guía general — confirma con tu nutricionista si quieres una lista más completa.',
    source: FoodExchangeSource.generalReference,
    items: [
      FoodExchangeItem(food: 'Vegetales de hoja verde (lechuga, espinaca, acelga)', portion: 'Libre'),
      FoodExchangeItem(food: 'Tomate, pepino, chayote, vainicas, culantro', portion: '1 taza cruda'),
      FoodExchangeItem(food: 'Brócoli, coliflor, zanahoria, cebolla, chile dulce', portion: '½ taza cocida'),
    ],
  ),
  FoodExchangeGroup(
    name: 'Frutas',
    icon: '🍎',
    guidance:
        'Una porción a la vez, mejor acompañada (nunca sola ni en jugo) para que no suba rápido el azúcar. Guía general.',
    source: FoodExchangeSource.generalReference,
    items: [
      FoodExchangeItem(food: 'Papaya, sandía o melón en cubos', portion: '1 taza'),
      FoodExchangeItem(food: 'Manzana o naranja', portion: '1 unidad pequeña'),
      FoodExchangeItem(food: 'Banano', portion: '½ unidad'),
    ],
  ),
  FoodExchangeGroup(
    name: 'Alimentos de origen animal',
    icon: '🍗',
    guidance:
        'Preferir siempre las opciones magras (sin piel, no fritas) y evitar embutidos por la presión alta. Guía general.',
    source: FoodExchangeSource.generalReference,
    items: [
      FoodExchangeItem(food: 'Pechuga de pollo sin piel (no frita)', portion: '1 onza'),
      FoodExchangeItem(food: 'Pescado (no frito)', portion: '1 onza'),
      FoodExchangeItem(food: 'Huevo', portion: '1 unidad'),
      FoodExchangeItem(food: 'Queso fresco bajo en grasa', portion: '1 tajada delgada'),
    ],
  ),
  FoodExchangeGroup(
    name: 'Grasas',
    icon: '🥑',
    guidance: 'En cantidades pequeñas — ayudan, pero con moderación por el colesterol. Guía general.',
    source: FoodExchangeSource.generalReference,
    items: [
      FoodExchangeItem(food: 'Aguacate', portion: '2 cucharadas'),
      FoodExchangeItem(food: 'Aceite de oliva o canola', portion: '1 cucharadita'),
      FoodExchangeItem(food: 'Maní o almendras sin sal', portion: '6 a 8 unidades'),
    ],
  ),
];

/// Formats the exchange plan as grounding text for the AI prompts, so the
/// AI's suggestions stay consistent with what the nutritionist actually
/// prescribed instead of inventing its own portion sizes.
String nutritionistExchangePlanPromptText() {
  final buffer = StringBuffer();
  for (final group in nutritionistExchangePlan) {
    final sourceLabel = group.source == FoodExchangeSource.nutritionist
        ? 'prescrito por su nutricionista, úsalo tal cual, no lo cambies'
        : 'guía general de referencia';
    buffer.writeln('${group.name} ($sourceLabel):');
    for (final item in group.items) {
      buffer.writeln('- ${item.food}: ${item.portion} = 1 porción');
    }
  }
  return buffer.toString();
}
