import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/sqlite_auth_repository.dart';
import '../../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SqliteAuthRepository();
});

/// Holds the app's single local user id. There's no login/logout — this
/// resolves once at startup (creating the local user on first launch) and
/// stays populated for the rest of the app's lifetime.
class AuthController extends StateNotifier<AsyncValue<int?>> {
  AuthController(this._repository) : super(const AsyncValue.loading()) {
    _init();
  }

  final AuthRepository _repository;

  Future<void> _init() async {
    state = await AsyncValue.guard(() => _repository.ensureLocalUser());
  }

  /// Re-creates the local user after "Borrar todos los datos" wipes the
  /// database, so the app has a fresh valid user id to work with again.
  Future<void> resetAfterDataDeleted() => _init();
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<int?>>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

/// Convenience accessor: the local user's id, or null while it's still
/// being created/resolved at startup.
final currentUserIdProvider = Provider<int?>((ref) {
  return ref.watch(authControllerProvider).valueOrNull;
});
