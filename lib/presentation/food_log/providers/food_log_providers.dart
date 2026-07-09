import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/sqlite_food_log_repository.dart';
import '../../../data/services/food_recognition_service.dart';
import '../../../data/services/mock_food_recognition_service.dart';
import '../../../domain/entities/food_entry.dart';
import '../../../domain/repositories/food_log_repository.dart';
import '../../auth/providers/auth_providers.dart';

final foodLogRepositoryProvider = Provider<FoodLogRepository>((ref) {
  return SqliteFoodLogRepository();
});

/// Single provider override point for swapping in a real vision API later.
final foodRecognitionServiceProvider = Provider<FoodRecognitionService>((ref) {
  return MockFoodRecognitionService();
});

class TodaysFoodLogController extends StateNotifier<AsyncValue<List<FoodEntry>>> {
  TodaysFoodLogController(this._repository, this._userId)
      : super(const AsyncValue.loading()) {
    if (_userId != null) {
      reload();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  final FoodLogRepository _repository;
  final int? _userId;

  Future<void> reload() async {
    if (_userId == null) return;
    state = await AsyncValue.guard(
      () => _repository.entriesForDay(_userId, DateTime.now()),
    );
  }

  Future<void> addEntry(FoodEntry entry) async {
    await _repository.addEntry(entry);
    await reload();
  }

  Future<void> deleteEntry(int entryId) async {
    await _repository.deleteEntry(entryId);
    await reload();
  }
}

final todaysFoodLogProvider =
    StateNotifierProvider<TodaysFoodLogController, AsyncValue<List<FoodEntry>>>(
        (ref) {
  final userId = ref.watch(currentUserIdProvider);
  return TodaysFoodLogController(ref.watch(foodLogRepositoryProvider), userId);
});
