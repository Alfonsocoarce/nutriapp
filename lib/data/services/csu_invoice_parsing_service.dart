import 'dart:io';

import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../domain/entities/invoice_line_item.dart';
import 'invoice_category_guesser.dart';
import 'invoice_parsing_service.dart';

/// Parses real "Tiquete Electrónico" PDF receipts from Costa Rican
/// supermarkets (e.g. Corporación Supermercados Unidos / Automercado),
/// which embed a genuine text layer rather than a scanned image. Extraction
/// is pure Dart (no OCR, no external API, no native platform code), so it
/// needs no backend proxy and works fully offline — this is real parsing,
/// not a mock, for this receipt format.
///
/// Syncfusion's text extractor reads the invoice table one field per line,
/// not left-to-right per visual row. Each product is five consecutive
/// lines in this order:
///   DESCRIPCIÓN
///   CANTIDAD       (e.g. "0.44" or "1.00")
///   PRECIO UNITARIO (e.g. "1,548.67")
///   CÓDIGO          (9-14 digit barcode)
///   MONTO           (e.g. "1,750.00")
/// e.g.:
///   MINIVEGETAL
///   1.00
///   1,548.67
///   0744107410472
///   1,750.00
final _lineItemPattern = RegExp(
  r'^([A-ZÁÉÍÓÚÑ0-9 .]+)\n(\d+\.\d{2})\n([\d,]+\.\d{2})\n(\d{9,14})\n([\d,]+\.\d{2})$',
  multiLine: true,
);

/// Title-cases an ALL-CAPS receipt line ("RIB EYE KG" -> "Rib Eye Kg") so
/// items read as recognizable product names instead of shouty abbreviated
/// codes. Purely cosmetic — doesn't expand abbreviations or invent words,
/// and the review screen still lets the user edit it further.
String _toTitleCase(String input) {
  return input
      .toLowerCase()
      .split(' ')
      .map((word) => word.isEmpty ? word : word[0].toUpperCase() + word.substring(1))
      .join(' ');
}

/// Parses already-extracted invoice text. Split out from
/// [CsuInvoiceParsingService.parseInvoice] so the line-matching logic is
/// unit-testable without needing a real PDF file on disk.
///
/// Lines that don't match a known food keyword are dropped rather than
/// guessed into a category — grocery receipts also list non-food products
/// (paper goods, cleaning supplies, personal care), and those don't belong
/// in a food pantry. See [InvoiceCategoryGuesser] for the reasoning.
List<InvoiceLineItem> parseCsuInvoiceText(String text) {
  // PdfTextExtractor emits CRLF ("\r\n") line endings; normalize to "\n" so
  // the line-anchored pattern above matches regardless of the extractor's
  // choice of line terminator.
  final normalized = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

  final items = <InvoiceLineItem>[];
  for (final match in _lineItemPattern.allMatches(normalized)) {
    final description = match.group(1)!.trim();
    final quantity = double.tryParse(match.group(2)!) ?? 1;
    if (description.isEmpty) continue;

    final category = InvoiceCategoryGuesser.guess(description);
    if (category == null) continue;

    items.add(InvoiceLineItem(
      productName: _toTitleCase(description),
      quantity: quantity,
      // Weighed produce comes through as a fractional kg quantity;
      // whole-number quantities are discrete packaged units.
      unit: quantity == quantity.roundToDouble() ? 'unidad' : 'kg',
      category: category,
      price: double.tryParse(match.group(5)!.replaceAll(',', '')),
    ));
  }
  return items;
}

class CsuInvoiceParsingService implements InvoiceParsingService {
  @override
  Future<List<InvoiceLineItem>> parseInvoice(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    final document = PdfDocument(inputBytes: bytes);
    final text = PdfTextExtractor(document).extractText();
    document.dispose();

    final items = parseCsuInvoiceText(text);
    if (items.isEmpty) {
      throw const FormatException(
          'No se reconoció el formato de esta factura');
    }
    return items;
  }
}
