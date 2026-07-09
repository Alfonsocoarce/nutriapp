import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/security/api_key_store.dart';

class ApiKeyController extends StateNotifier<AsyncValue<String?>> {
  ApiKeyController() : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = await AsyncValue.guard(() => ApiKeyStore.instance.getGeminiApiKey());
  }

  Future<void> save(String key) async {
    await ApiKeyStore.instance.setGeminiApiKey(key);
    state = AsyncValue.data(key);
  }

  Future<void> remove() async {
    await ApiKeyStore.instance.clearGeminiApiKey();
    state = const AsyncValue.data(null);
  }
}

final apiKeyControllerProvider =
    StateNotifierProvider<ApiKeyController, AsyncValue<String?>>((ref) {
  return ApiKeyController();
});
