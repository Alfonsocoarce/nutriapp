import '../../domain/entities/pantry_category.dart';

/// Best-effort food-category guess from an abbreviated Spanish supermarket
/// receipt line (e.g. "MINIVEGETAL", "RIB EYE KG", "YOGURT ALMEN").
///
/// Returns `null` when the line doesn't match any known food keyword —
/// this is deliberate, not a gap to "fix" with a fallback category: grocery
/// receipts also include non-food lines (paper goods, cleaning supplies,
/// personal care, etc.) that don't belong in a food pantry at all, and an
/// unrecognized line is exactly as likely to be one of those as it is to be
/// an obscure food this keyword list doesn't cover yet. Per the ERS RF-09
/// "no adivinar" principle, an unrecognized item is left out rather than
/// guessed into a wrong bucket (previously this defaulted everything
/// unmatched to "snacks", which silently filled the pantry with paper
/// towels and soap). [CsuInvoiceParsingService] drops any line with a
/// `null` guess before it ever reaches the review screen.
class InvoiceCategoryGuesser {
  InvoiceCategoryGuesser._();

  static const _keywordMap = <PantryCategory, List<String>>{
    PantryCategory.fruits: [
      'PLATAN', 'UVA', 'LIMON', 'PAPAYA', 'MANDARI', 'AGUACAT', 'MANZANA',
      'MZ ', 'BANAN', 'FRESA', 'SANDIA', 'MELON', 'PINA', 'COCO', 'KIWI',
      'DURAZNO', 'PERA ', 'MORA', 'GUAYABA', 'MANGO',
    ],
    PantryCategory.vegetables: [
      'LECHUGA', 'CULANTR', 'CHILE', 'ZUCHINI', 'ZUCCHINI', 'CEBOLLA',
      'VAINICA', 'TOMATE', 'ZANAHORIA', 'AJO ', 'PEPINO', 'VEG ', 'VEGETAL',
      'BROCOL', 'PAPA ', 'ELOTE', 'APIO', 'REPOLLO', 'COL ', 'MAIZ',
      'ESPINACA', 'RABANO', 'REMOLACHA', 'PIMENT', 'AYOTE', 'YUCA',
      'CAMOTE',
    ],
    PantryCategory.meats: [
      'RIB EYE', 'MOLIDA', 'COSTI', 'TROCITOS RES', 'ALITAS', 'CARNE',
      'LOMO', 'CERD', 'RES ', 'POLLO', 'JAMON', 'CHULETA', 'CHORIZO',
      'TOCINET', 'TOCINO', 'SALCHICH', 'MORTADEL', 'PAVO', 'HUEVO',
    ],
    PantryCategory.fish: [
      'FIL ', 'FILET', 'PESCADO', 'ATUN', 'SALMON', 'TILAPIA', 'BACALAO',
      'TRUCHA', 'MOJARRA',
    ],
    PantryCategory.seafood: [
      'CAMARON', 'LANGOSTA', 'PULPO', 'CANGREJO', 'MEJILLON', 'OSTRA',
      'CALAMAR', 'MARISCO',
    ],
    PantryCategory.dairy: [
      'QUESO', 'YOGURT', 'LECHE', 'CREMA', 'NATILLA', 'MANTEQUILLA',
    ],
    PantryCategory.grains: [
      'HARINA', 'CEREAL', 'TORTI', 'PAN ', 'PN PRO', 'LASAG', 'ARROZ',
      'PASTA', 'ESPAGUETI', 'AVENA', 'MACARRON', 'FIDEO', 'MAICENA',
      'GALLETA SODA',
    ],
    PantryCategory.legumes: ['FRIJ', 'LENTEJA', 'GARBANZO', 'HABA'],
    PantryCategory.beverages: [
      'JUG ', 'JUGO', 'TE MANZA', 'BEBIDA', 'TROPICA', 'REFRESCO', 'AGUA ',
      'GASEOSA', 'CAFE', 'SODA', 'ENERGIZ', 'ISOTONIC',
    ],
    PantryCategory.snacks: [
      'GERBER', 'GALLETA', 'CHOCOLAT', 'PAPAS ', 'SNACK', 'CONFITE',
      'DULCE', 'CHICLE', 'PALOMITAS', 'TOSTITOS', 'DORITO',
    ],
    PantryCategory.frozen: ['CONG', 'HELADO', 'NUGGET'],
    PantryCategory.condiments: [
      'LIZANO', 'PIMIENTA', 'SAL ', 'AZUCAR', 'MOSTAZA', 'MAYONESA',
      'SALSA', 'ADEREZO', 'MARG', 'VINAGRE', 'ACEITE', 'MIEL', 'KETCHUP',
      'CATSUP',
    ],
  };

  static PantryCategory? guess(String description) {
    final upper = description.toUpperCase();
    for (final entry in _keywordMap.entries) {
      for (final keyword in entry.value) {
        if (upper.contains(keyword)) return entry.key;
      }
    }
    return null;
  }
}
