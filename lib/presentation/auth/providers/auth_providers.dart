import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/sqlite_auth_repository.dart';
import '../../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SqliteAuthRepository();
});

/// Holds the current session's user id (null when logged out). Loading state
/// is used only while the initial session lookup runs at app start.
class AuthController extends StateNotifier<AsyncValue<int?>> {
  AuthController(this._repository) : super(const AsyncValue.loading()) {
    _restoreSession();
  }

  final AuthRepository _repository;

  Future<void> _restoreSession() async {
    state = await AsyncValue.guard(() => _repository.currentUserId());
  }

  Future<void> register({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.register(email: email, password: password),
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.login(email: email, password: password),
    );
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncValue.data(null);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<int?>>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

/// Convenience accessor: the logged-in user's id, or null.
final currentUserIdProvider = Provider<int?>((ref) {
  return ref.watch(authControllerProvider).valueOrNull;
});
