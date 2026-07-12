import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notifications/notification_service.dart';
import '../../../core/security/notification_preferences_store.dart';
import '../../auth/providers/auth_providers.dart';

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

  /// Persists [enabled]/[time] and (de)schedules the OS reminder to match.
  /// If enabling, first requests the OS notification permission — returns
  /// false without changing anything if the user denies it, so the UI can
  /// keep the toggle off instead of showing a reminder that silently won't
  /// fire.
  Future<bool> save({
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

    final updated =
        NotificationPreferences(enabled: enabled, hour: time.hour, minute: time.minute);
    await NotificationPreferencesStore.instance.write(_userId, updated);

    if (enabled) {
      await NotificationService.instance.scheduleDailyReminder(time, title: title, body: body);
    } else {
      await NotificationService.instance.cancelReminder();
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
