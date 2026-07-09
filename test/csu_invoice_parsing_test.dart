import 'package:flutter_test/flutter_test.dart';
import 'package:nutriapp/data/services/csu_invoice_parsing_service.dart';
import 'package:nutriapp/domain/entities/pantry_category.dart';

// A representative excerpt from a real "Tiquete Electrónico" PDF (Corporación
// Supermercados Unidos), reproduced verbatim from Syncfusion's
// PdfTextExtractor output. Extraction is field-per-line, not left-to-right
// per visual row: each product is DESCRIPCIÓN, CANTIDAD, PRECIO UNITARIO,
// CÓDIGO, MONTO across five consecutive lines. Header/footer noise is
// included so the parser is verified to ignore it.
const _sampleInvoiceText = '''
Tiquete Electrónico ver. 4.4
CÓDIGO
DESCRIPCIÓN
PRECIO
UNITARIO
IMP
MONTO
CANTIDAD
Consecutivo No.:
23800012040000407466

50613062600310200722323800012040000407466100000000
YU SE
0.44
744.17
0000000007175
370.00
MINIVEGETAL
1.00
1,548.67
0744107410472
1,750.00
PLATAN UNI
2.00
306.93
0000000004237
620.00
UVA VE 500 G
1.00
1,194.69
0744107412719
1,350.00
QUESO MOZZ
1.00
1,725.66
0744100050445
1,950.00
RIB EYE KG
0.40
7,672.57
0262532000000
3,468.00
YOGURT ALMEN
5.00
946.90
0744100163120
5,350.00
PAPEL 4R1000
1.00
1,485.15
0740613100187
1,500.00
CEREAL 10 PK
1.00
1,221.24
0744100100105
1,380.00
------------------------------ Última línea ------------------------------
SUBTOTAL
TOTAL
107,084.78
115,032.00
''';

void main() {
  group('parseCsuInvoiceText', () {
    final items = parseCsuInvoiceText(_sampleInvoiceText);

    test('extracts every product line and ignores header/footer noise', () {
      expect(items, hasLength(9));
    });

    test('parses fractional (weighed) quantities as kg', () {
      final ribEye = items.firstWhere((i) => i.productName == 'RIB EYE KG');
      expect(ribEye.quantity, 0.40);
      expect(ribEye.unit, 'kg');
      expect(ribEye.price, 3468.00);
    });

    test('parses whole-number quantities as unidad', () {
      final yogurt = items.firstWhere((i) => i.productName == 'YOGURT ALMEN');
      expect(yogurt.quantity, 5);
      expect(yogurt.unit, 'unidad');
    });

    test('does not confuse descriptions containing embedded numbers', () {
      final uva = items.firstWhere((i) => i.productName == 'UVA VE 500 G');
      expect(uva.quantity, 1.00);
      expect(uva.price, 1350.00);

      final papel = items.firstWhere((i) => i.productName == 'PAPEL 4R1000');
      expect(papel.quantity, 1.00);
      expect(papel.price, 1500.00);

      final cereal = items.firstWhere((i) => i.productName == 'CEREAL 10 PK');
      expect(cereal.quantity, 1.00);
      expect(cereal.price, 1380.00);
    });

    test('pairs each product with its own quantity and price, not a neighbor\'s', () {
      final platan = items.firstWhere((i) => i.productName == 'PLATAN UNI');
      expect(platan.quantity, 2.00);
      expect(platan.price, 620.00);

      final queso = items.firstWhere((i) => i.productName == 'QUESO MOZZ');
      expect(queso.quantity, 1.00);
      expect(queso.price, 1950.00);
    });

    test('guesses plausible categories from Spanish keywords', () {
      expect(items.firstWhere((i) => i.productName == 'PLATAN UNI').category,
          PantryCategory.fruits);
      expect(items.firstWhere((i) => i.productName == 'QUESO MOZZ').category,
          PantryCategory.dairy);
      expect(items.firstWhere((i) => i.productName == 'RIB EYE KG').category,
          PantryCategory.meats);
    });

    test('returns an empty list for text with no matching lines', () {
      expect(parseCsuInvoiceText('no invoice data here'), isEmpty);
    });
  });
}
