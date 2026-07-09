import 'pantry_category.dart';

/// A single product line extracted from a scanned supermarket invoice
/// (ERS RF-09). Quantity/unit/category are the parser's best guess and
/// remain editable by the user before anything is written to the pantry.
class InvoiceLineItem {
  final String productName;
  final double quantity;
  final String unit;
  final PantryCategory category;
  final double? price;

  const InvoiceLineItem({
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.category,
    this.price,
  });
}
