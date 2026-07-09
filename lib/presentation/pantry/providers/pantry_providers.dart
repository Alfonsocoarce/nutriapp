import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/sqlite_pantry_repository.dart';
import '../../../domain/entities/pantry_item.dart';
import '../../../domain/repositories/pantry_repository.dart';
import '../../auth/providers/auth_providers.dart';

final pantryRepositoryProvider = Provider<PantryRepository>((ref) {
  return SqlitePantryRepository();
});

class PantryController extends StateNotifier<AsyncValue<List<PantryItem>>> {
  PantryController(this._repository, this._userId)
      : super(const AsyncValue.loading()) {
    if (_userId != null) {
      reload();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  final PantryRepository _repository;
  final int? _userId;

  Future<void> reload() async {
    if (_userId == null) return;
    state = await AsyncValue.guard(() => _repository.allItems(_userId));
  }

  Future<void> addItem(PantryItem item) async {
    await _repository.addItem(item);
    await reload();
  }

  Future<void> updateItem(PantryItem item) async {
    await _repository.updateItem(item);
    await reload();
  }

  Future<void> deleteItem(int itemId) async {
    await _repository.deleteItem(itemId);
    await reload();
  }
}

final pantryControllerProvider =
    StateNotifierProvider<PantryController, AsyncValue<List<PantryItem>>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return PantryController(ref.watch(pantryRepositoryProvider), userId);
});
