import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Whether the daily "log your meals" reminder is on, and at what local
/// time it fires.
class NotificationPreferences {
  final bool enabled;
  final int hour;
  final int minute;

  const NotificationPreferences({
    required this.enabled,
    required this.hour,
    required this.minute,
  });

  static const defaultValue = NotificationPreferences(enabled: false, hour: 8, minute: 0);
}

/// Persists the reminder preference per user (not globally), mirroring
/// [OnboardingStore] — same secure-storage mechanism as the rest of the
/// app's small persisted flags, even though this value isn't sensitive.
class NotificationPreferencesStore {
  NotificationPreferencesStore._();

  static final NotificationPreferencesStore instance = NotificationPreferencesStore._();

  static const _secureStorage = FlutterSecureStorage();
  static const _keyPrefix = 'nutriapp_notif_prefs_';

  Future<NotificationPreferences> read(int userId) async {
    final raw = await _secureStorage.read(key: '$_keyPrefix$userId');
    if (raw == null) return NotificationPreferences.defaultValue;
    final parts = raw.split(':');
    if (parts.length != 3) return NotificationPreferences.defaultValue;
    return NotificationPreferences(
      enabled: parts[0] == '1',
      hour: int.tryParse(parts[1]) ?? NotificationPreferences.defaultValue.hour,
      minute: int.tryParse(parts[2]) ?? NotificationPreferences.defaultValue.minute,
    );
  }

  Future<void> write(int userId, NotificationPreferences prefs) {
    final raw = '${prefs.enabled ? '1' : '0'}:${prefs.hour}:${prefs.minute}';
    return _secureStorage.write(key: '$_keyPrefix$userId', value: raw);
  }
}
