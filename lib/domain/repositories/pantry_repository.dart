import '../entities/pantry_item.dart';

abstract class PantryRepository {
  Future<int> addItem(PantryItem item);
  Future<void> updateItem(PantryItem item);
  Future<void> deleteItem(int itemId);
  Future<void> deleteAllItems(int userId);
  Future<List<PantryItem>> allItems(int userId);
}
