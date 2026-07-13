import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notifications/notification_service.dart';
import '../../../core/security/notification_preferences_store.dart';
import '../../auth/providers/auth_providers.dart';

/// Text shown by a single meal reminder notification.
typedef ReminderText = ({String title, String body});

class NotificationPreferencesController
    extends StateNotifier<AsyncValue<NotificationPreferences>> {
  NotificationPreferencesController(this._userId)
      : super(const AsyncValue.loading()) {
    if (_userId != null) {
      _load();
    } else {
      state = const AsyncValue.data(NotificationPreferences.defaultValue);
    }
  }

  final int? _userId;

  Future<void> _load() async {
    state = await AsyncValue.guard(() => NotificationPreferencesStore.instance.read(_userId!));
  }

  /// The first time a user reaches this (no preferences ever persisted),
  /// silently turns on all three meal reminders at their default times —
  /// so reminders work out of the box instead of requiring a trip to
  /// Configuración. If the OS permission is denied, persists everything as
  /// off instead of a reminder that would silently never fire.
  Future<void> ensureDefaultReminders(
      Map<MealReminderType, ReminderText> textByType) async {
    if (_userId == null) return;
    final existing = await NotificationPreferencesStore.instance.readRaw(_userId);
    if (existing != null) return;

    final granted = await NotificationService.instance.requestPermission();
    final prefs =
        granted ? NotificationPreferences.defaultValue : NotificationPreferences.allDisabled;
    await NotificationPreferencesStore.instance.write(_userId, prefs);

    if (granted) {
      for (final reminder in prefs.all) {
        final text = textByType[reminder.type]!;
        await NotificationService.instance.scheduleMealReminder(
          reminder.type,
          TimeOfDay(hour: reminder.hour, minute: reminder.minute),
          title: text.title,
          body: text.body,
        );
      }
    }
    state = AsyncValue.data(prefs);
  }

  /// Persists one meal reminder's [enabled]/[time] and (de)schedules just
  /// that OS notification, leaving the other two meals untouched. If
  /// enabling, first requests the OS notification permission — returns
  /// false without changing anything if the user denies it, so the UI can
  /// keep the toggle off instead of showing a reminder that silently won't
  /// fire.
  Future<bool> save({
    required MealReminderType type,
    required bool enabled,
    required TimeOfDay time,
    required String title,
    required String body,
  }) async {
    if (_userId == null) return false;

    if (enabled) {
      final granted = await NotificationService.instance.requestPermission();
      if (!granted) return false;
    }

    final current = state.valueOrNull ?? NotificationPreferences.defaultValue;
    final updated = current.withReminder(
      MealReminder(type: type, enabled: enabled, hour: time.hour, minute: time.minute),
    );
    await NotificationPreferencesStore.instance.write(_userId, updated);

    if (enabled) {
      await NotificationService.instance.scheduleMealReminder(type, time, title: title, body: body);
    } else {
      await NotificationService.instance.cancelMealReminder(type);
    }

    state = AsyncValue.data(updated);
    return true;
  }
}

final notificationPreferencesProvider = StateNotifierProvider<
    NotificationPreferencesController, AsyncValue<NotificationPreferences>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return NotificationPreferencesController(userId);
});
