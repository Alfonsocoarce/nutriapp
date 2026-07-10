import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/security/onboarding_store.dart';
import '../../auth/providers/auth_providers.dart';

final onboardingStoreProvider = Provider<OnboardingStore>((ref) {
  return OnboardingStore.instance;
});

/// Whether the current user has already been offered the app walkthrough.
/// `true` (nothing to show) when there's no logged-in user, so callers
/// don't need a separate null check.
final hasSeenOnboardingProvider = FutureProvider<bool>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return true;
  final store = ref.watch(onboardingStoreProvider);
  return store.hasSeenOnboarding(userId);
});
