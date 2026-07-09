import '../entities/food_entry.dart';
import '../entities/meal_type.dart';

abstract class FoodLogRepository {
  Future<int> addEntry(FoodEntry entry);
  Future<void> updateMealType(int entryId, MealType mealType);
  Future<List<FoodEntry>> entriesForDay(int userId, DateTime day);
  Future<List<FoodEntry>> entriesForRange(
      int userId, DateTime start, DateTime end);
  Future<void> deleteEntry(int entryId);
}
