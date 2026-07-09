import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/usecases/compute_daily_progress_usecase.dart';
import '../../food_log/providers/food_log_providers.dart';
import '../../profile/providers/profile_providers.dart';

final dailyProgressProvider = Provider<AsyncValue<DailyProgress?>>((ref) {
  final profileAsync = ref.watch(profileControllerProvider);
  final entriesAsync = ref.watch(todaysFoodLogProvider);

  if (profileAsync.isLoading || entriesAsync.isLoading) {
    return const AsyncValue.loading();
  }
  final error = profileAsync.hasError
      ? profileAsync
      : (entriesAsync.hasError ? entriesAsync : null);
  if (error != null) {
    return AsyncValue.error(error.error!, error.stackTrace!);
  }

  final profile = profileAsync.valueOrNull;
  if (profile == null) return const AsyncValue.data(null);

  final entries = entriesAsync.valueOrNull ?? [];
  final progress = ComputeDailyProgressUseCase()(
    profile: profile,
    todaysEntries: entries,
  );
  return AsyncValue.data(progress);
});
