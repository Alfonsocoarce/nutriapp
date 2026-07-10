import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Tracks whether a given user has already been offered/seen the
/// first-time app walkthrough, so it's only shown once automatically —
/// stored per user (not globally) since the device may be shared across
/// local accounts. Uses the same secure-storage mechanism as the rest of
/// the app's small persisted flags/keys, even though this value isn't
/// sensitive, for consistency with [ApiKeyStore].
class OnboardingStore {
  OnboardingStore._();

  static final OnboardingStore instance = OnboardingStore._();

  static const _secureStorage = FlutterSecureStorage();
  static const _keyPrefix = 'nutriapp_onboarding_seen_';

  Future<bool> hasSeenOnboarding(int userId) async {
    final value = await _secureStorage.read(key: '$_keyPrefix$userId');
    return value == 'true';
  }

  Future<void> markOnboardingSeen(int userId) {
    return _secureStorage.write(key: '$_keyPrefix$userId', value: 'true');
  }
}
