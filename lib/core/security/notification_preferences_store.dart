import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum MealReminderType { breakfast, lunch, dinner }

/// Whether a single meal reminder is on, and at what local time it fires.
class MealReminder {
  final MealReminderType type;
  final bool enabled;
  final int hour;
  final int minute;

  const MealReminder({
    required this.type,
    required this.enabled,
    required this.hour,
    required this.minute,
  });

  MealReminder copyWith({bool? enabled, int? hour, int? minute}) => MealReminder(
        type: type,
        enabled: enabled ?? this.enabled,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
      );
}

/// The three daily meal reminders — desayuno, almuerzo, cena — each
/// independently enabled/disabled and independently timed. Active by
/// default (7:00 / 12:00 / 19:00) so a new user gets useful reminders
/// without having to configure anything first.
class NotificationPreferences {
  final MealReminder breakfast;
  final MealReminder lunch;
  final MealReminder dinner;

  const NotificationPreferences({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });

  static const defaultValue = NotificationPreferences(
    breakfast: MealReminder(type: MealReminderType.breakfast, enabled: true, hour: 7, minute: 0),
    lunch: MealReminder(type: MealReminderType.lunch, enabled: true, hour: 12, minute: 0),
    dinner: MealReminder(type: MealReminderType.dinner, enabled: true, hour: 19, minute: 0),
  );

  static const allDisabled = NotificationPreferences(
    breakfast: MealReminder(type: MealReminderType.breakfast, enabled: false, hour: 7, minute: 0),
    lunch: MealReminder(type: MealReminderType.lunch, enabled: false, hour: 12, minute: 0),
    dinner: MealReminder(type: MealReminderType.dinner, enabled: false, hour: 19, minute: 0),
  );

  List<MealReminder> get all => [breakfast, lunch, dinner];

  MealReminder forType(MealReminderType type) => switch (type) {
        MealReminderType.breakfast => breakfast,
        MealReminderType.lunch => lunch,
        MealReminderType.dinner => dinner,
      };

  NotificationPreferences withReminder(MealReminder updated) => NotificationPreferences(
        breakfast: updated.type == MealReminderType.breakfast ? updated : breakfast,
        lunch: updated.type == MealReminderType.lunch ? updated : lunch,
        dinner: updated.type == MealReminderType.dinner ? updated : dinner,
      );
}

/// Persists the three reminder preferences per user (not globally),
/// mirroring [OnboardingStore] — same secure-storage mechanism as the
/// rest of the app's small persisted flags, even though this value isn't
/// sensitive.
class NotificationPreferencesStore {
  NotificationPreferencesStore._();

  static final NotificationPreferencesStore instance = NotificationPreferencesStore._();

  static const _secureStorage = FlutterSecureStorage();
  static const _keyPrefix = 'nutriapp_notif_prefs_';

  /// Null means this user has never had preferences persisted — used to
  /// tell "never configured" apart from "explicitly turned everything off".
  Future<String?> readRaw(int userId) => _secureStorage.read(key: '$_keyPrefix$userId');

  Future<NotificationPreferences> read(int userId) async {
    final raw = await readRaw(userId);
    if (raw == null) return NotificationPreferences.defaultValue;
    final groups = raw.split('|');
    if (groups.length != 3) return NotificationPreferences.defaultValue;
    MealReminder parse(MealReminderType type, String group) {
      final parts = group.split(':');
      final fallback = NotificationPreferences.defaultValue.forType(type);
      if (parts.length != 3) return fallback;
      return MealReminder(
        type: type,
        enabled: parts[0] == '1',
        hour: int.tryParse(parts[1]) ?? fallback.hour,
        minute: int.tryParse(parts[2]) ?? fallback.minute,
      );
    }

    return NotificationPreferences(
      breakfast: parse(MealReminderType.breakfast, groups[0]),
      lunch: parse(MealReminderType.lunch, groups[1]),
      dinner: parse(MealReminderType.dinner, groups[2]),
    );
  }

  Future<void> write(int userId, NotificationPreferences prefs) {
    String encode(MealReminder r) => '${r.enabled ? '1' : '0'}:${r.hour}:${r.minute}';
    final raw = [encode(prefs.breakfast), encode(prefs.lunch), encode(prefs.dinner)].join('|');
    return _secureStorage.write(key: '$_keyPrefix$userId', value: raw);
  }
}
