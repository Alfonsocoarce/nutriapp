import 'package:flutter_test/flutter_test.dart';
import 'package:nutriapp/data/services/invoice_category_guesser.dart';
import 'package:nutriapp/domain/entities/pantry_category.dart';

void main() {
  group('InvoiceCategoryGuesser.guess', () {
    test('matches common food keywords to their category', () {
      expect(InvoiceCategoryGuesser.guess('PLATAN UNI'), PantryCategory.fruits);
      expect(InvoiceCategoryGuesser.guess('QUESO MOZZ'), PantryCategory.dairy);
      expect(InvoiceCategoryGuesser.guess('RIB EYE KG'), PantryCategory.meats);
      expect(InvoiceCategoryGuesser.guess('ARROZ 1KG'), PantryCategory.grains);
      expect(InvoiceCategoryGuesser.guess('CAMARON JUMBO'), PantryCategory.seafood);
      expect(InvoiceCategoryGuesser.guess('FRIJ NEGRO'), PantryCategory.legumes);
    });

    test('returns null for real non-food receipt lines instead of guessing', () {
      // Verbatim abbreviated lines from a real CSU receipt: paper goods,
      // cleaning supplies, and personal care — none of these belong in a
      // food pantry, and previously all fell through to "snacks".
      const nonFoodLines = [
        'PAPEL 4R1000', // toilet paper, 4-roll pack
        'TOA MIL U 3R', // paper towels
        'GV DET PRIMA', // Great Value laundry detergent
        'EQUATE ANTIB', // Equate antibacterial soap
        'GV BOL ALMAC', // Great Value storage bags
        'ONEP JAB BUR', // bar soap
        'CONT ABS 3U', // absorbent pads
        'BIC FLOWER 2', // Bic razors
      ];
      for (final line in nonFoodLines) {
        expect(InvoiceCategoryGuesser.guess(line), isNull, reason: line);
      }
    });

    test('returns null for an unrecognizable cryptic code rather than guessing', () {
      expect(InvoiceCategoryGuesser.guess('YU SE'), isNull);
    });
  });
}
