import 'pantry_category.dart';

class PantryItem {
  final int id;
  final int userId;
  final String productName;
  final PantryCategory category;
  final double quantity;
  final String unit;
  final DateTime purchaseDate;
  final DateTime? expirationDate;

  const PantryItem({
    required this.id,
    required this.userId,
    required this.productName,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.purchaseDate,
    this.expirationDate,
  });

  int? get daysRemaining {
    if (expirationDate == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry =
        DateTime(expirationDate!.year, expirationDate!.month, expirationDate!.day);
    return expiry.difference(today).inDays;
  }

  bool get isExpired => (daysRemaining ?? 1) < 0;
  bool get isExpiringSoon => (daysRemaining ?? 99) <= 3 && !isExpired;
}
