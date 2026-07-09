import '../../domain/entities/pantry_category.dart';
import '../../domain/entities/pantry_item.dart';
import '../../domain/repositories/pantry_repository.dart';
import '../local/app_database.dart';

class SqlitePantryRepository implements PantryRepository {
  @override
  Future<int> addItem(PantryItem item) async {
    final db = await AppDatabase.instance.database;
    return db.insert('pantry_items', _toRow(item));
  }

  @override
  Future<void> updateItem(PantryItem item) async {
    final db = await AppDatabase.instance.database;
    await db.update(
      'pantry_items',
      _toRow(item),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  @override
  Future<void> deleteItem(int itemId) async {
    final db = await AppDatabase.instance.database;
    await db.delete('pantry_items', where: 'id = ?', whereArgs: [itemId]);
  }

  @override
  Future<List<PantryItem>> allItems(int userId) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'pantry_items',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'expiration_date ASC',
    );
    return rows
        .map((row) => PantryItem(
              id: row['id'] as int,
              userId: row['user_id'] as int,
              productName: row['product_name'] as String,
              category: PantryCategory.values.byName(row['category'] as String),
              quantity: row['quantity'] as double,
              unit: row['unit'] as String,
              purchaseDate: DateTime.parse(row['purchase_date'] as String),
              expirationDate: row['expiration_date'] == null
                  ? null
                  : DateTime.parse(row['expiration_date'] as String),
            ))
        .toList();
  }

  Map<String, Object?> _toRow(PantryItem item) => {
        'user_id': item.userId,
        'product_name': item.productName,
        'category': item.category.name,
        'quantity': item.quantity,
        'unit': item.unit,
        'purchase_date': item.purchaseDate.toIso8601String(),
        'expiration_date': item.expirationDate?.toIso8601String(),
      };
}
