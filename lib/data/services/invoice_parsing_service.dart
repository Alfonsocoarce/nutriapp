import '../../domain/entities/invoice_line_item.dart';

/// Extracts product/quantity/unit/price lines from a scanned supermarket
/// invoice (PDF or photo) — ERS RF-09. The production implementation should
/// run OCR (e.g. Google ML Kit / Tesseract) or a document-vision model
/// through the same stateless backend proxy used for food-photo recognition,
/// so no API key ships inside the app.
///
/// [MockInvoiceParsingService] is the only implementation wired up today;
/// swapping in a real provider means adding a new class here and changing
/// the single provider override in pantry providers.
abstract class InvoiceParsingService {
  Future<List<InvoiceLineItem>> parseInvoice(String filePath);
}
