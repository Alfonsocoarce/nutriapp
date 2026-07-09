import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/sqlite_profile_repository.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../domain/repositories/profile_repository.dart';
import '../../auth/providers/auth_providers.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return SqliteProfileRepository();
});

class ProfileController extends StateNotifier<AsyncValue<UserProfile?>> {
  ProfileController(this._repository, this._userId)
      : super(const AsyncValue.loading()) {
    if (_userId != null) {
      _load();
    } else {
      state = const AsyncValue.data(null);
    }
  }

  final ProfileRepository _repository;
  final int? _userId;

  Future<void> _load() async {
    state = await AsyncValue.guard(() => _repository.getProfile(_userId!));
  }

  Future<void> save(UserProfile profile) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.saveProfile(profile);
      return profile;
    });
  }
}

final profileControllerProvider =
    StateNotifierProvider<ProfileController, AsyncValue<UserProfile?>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return ProfileController(ref.watch(profileRepositoryProvider), userId);
});
