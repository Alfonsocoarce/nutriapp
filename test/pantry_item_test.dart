import 'package:flutter_test/flutter_test.dart';
import 'package:nutriapp/domain/entities/pantry_category.dart';
import 'package:nutriapp/domain/entities/pantry_item.dart';

PantryItem _item({DateTime? expirationDate}) => PantryItem(
      id: 1,
      userId: 1,
      productName: 'Leche',
      category: PantryCategory.dairy,
      quantity: 1,
      unit: 'L',
      purchaseDate: DateTime.now(),
      expirationDate: expirationDate,
    );

void main() {
  group('PantryItem expiration', () {
    test('with no expiration date, daysRemaining is null and nothing is flagged', () {
      final item = _item();
      expect(item.daysRemaining, isNull);
      expect(item.isExpired, isFalse);
      expect(item.isExpiringSoon, isFalse);
    });

    test('past expiration date is flagged as expired, not expiring soon', () {
      final item = _item(expirationDate: DateTime.now().subtract(const Duration(days: 2)));
      expect(item.isExpired, isTrue);
      expect(item.isExpiringSoon, isFalse);
    });

    test('expiration within 3 days is flagged as expiring soon', () {
      final item = _item(expirationDate: DateTime.now().add(const Duration(days: 2)));
      expect(item.isExpired, isFalse);
      expect(item.isExpiringSoon, isTrue);
    });

    test('expiration far in the future is flagged as neither', () {
      final item = _item(expirationDate: DateTime.now().add(const Duration(days: 30)));
      expect(item.isExpired, isFalse);
      expect(item.isExpiringSoon, isFalse);
    });
  });
}
