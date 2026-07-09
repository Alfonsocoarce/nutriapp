import '../../domain/entities/pantry_category.dart';

/// Best-effort category guess from an abbreviated Spanish supermarket
/// receipt line (e.g. "MINIVEGETAL", "RIB EYE KG", "YOGURT ALMEN"). Wrong
/// guesses are cheap: the user reviews and can change every item's category
/// before anything is saved (ERS RF-09 "no adivinar" principle).
class InvoiceCategoryGuesser {
  InvoiceCategoryGuesser._();

  static const _keywordMap = <PantryCategory, List<String>>{
    PantryCategory.fruits: [
      'PLATAN', 'UVA', 'LIMON', 'PAPAYA', 'MANDARI', 'AGUACAT', 'MANZANA',
      'MZ ', 'BANAN', 'FRESA', 'SANDIA', 'MELON', 'PINA',
    ],
    PantryCategory.vegetables: [
      'LECHUGA', 'CULANTR', 'CHILE', 'ZUCHINI', 'ZUCCHINI', 'CEBOLLA',
      'VAINICA', 'TOMATE', 'ZANAHORIA', 'AJO ', 'PEPINO', 'VEG ', 'VEGETAL',
      'BROCOL', 'PAPA ', 'ELOTE', 'APIO',
    ],
    PantryCategory.meats: [
      'RIB EYE', 'MOLIDA', 'COSTI', 'TROCITOS RES', 'ALITAS', 'CARNE',
      'LOMO', 'CERD', 'RES ', 'POLLO', 'JAMON', 'CHULETA', 'CHORIZO',
    ],
    PantryCategory.fish: [
      'FIL ', 'FILET', 'PESCADO', 'ATUN', 'SALMON', 'CAMARON', 'TILAPIA',
    ],
    PantryCategory.dairy: [
      'QUESO', 'YOGURT', 'LECHE', 'CREMA', 'NATILLA', 'MANTEQUILLA',
    ],
    PantryCategory.grains: [
      'HARINA', 'CEREAL', 'TORTI', 'PAN ', 'PN PRO', 'LASAG', 'ARROZ',
      'PASTA', 'ESPAGUETI', 'AVENA',
    ],
    PantryCategory.legumes: ['FRIJ', 'LENTEJA', 'GARBANZO'],
    PantryCategory.beverages: [
      'JUG ', 'JUGO', 'TE MANZA', 'BEBIDA', 'TROPICA', 'REFRESCO', 'AGUA ',
      'GASEOSA', 'CAFE',
    ],
    PantryCategory.snacks: [
      'GERBER', 'GALLETA', 'CHOCOLAT', 'PAPAS ', 'SNACK',
    ],
    PantryCategory.frozen: ['CONG', 'HELADO'],
    PantryCategory.condiments: [
      'LIZANO', 'PIMIENTA', 'SAL ', 'AZUCAR', 'MOSTAZA', 'MAYONESA',
      'SALSA', 'ADEREZO', 'MARG',
    ],
  };

  static PantryCategory guess(String description) {
    final upper = description.toUpperCase();
    for (final entry in _keywordMap.entries) {
      for (final keyword in entry.value) {
        if (upper.contains(keyword)) return entry.key;
      }
    }
    return PantryCategory.snacks;
  }
}
