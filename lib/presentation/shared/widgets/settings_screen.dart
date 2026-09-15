import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/security/notification_preferences_store.dart';
import '../../../data/local/app_database.dart';
import '../../../data/services/data_export_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_providers.dart';
import '../../food_log/providers/food_log_providers.dart';
import '../../onboarding/screens/onboarding_screen.dart';
import '../../pantry/providers/pantry_providers.dart';
import '../../profile/providers/profile_providers.dart';
import '../../profile/screens/profile_setup_screen.dart';
import '../../settings/providers/api_key_providers.dart';
import '../../settings/providers/notification_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final apiKeyAsync = ref.watch(apiKeyControllerProvider);
    final hasApiKey = apiKeyAsync.valueOrNull?.isNotEmpty ?? false;
    final notifPrefs = ref.watch(notificationPreferencesProvider).valueOrNull ??
        NotificationPreferences.defaultValue;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            _SettingsTile(
              icon: Icons.person_outline,
              title: l10n.settingsEditProfile,
              description: l10n.settingsEditProfileDesc,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
              ),
            ),
            const Divider(height: 1),
            _SettingsTile(
              icon: notifPrefs.all.any((r) => r.enabled)
                  ? Icons.notifications_active
                  : Icons.notifications_outlined,
              iconColor: notifPrefs.all.any((r) => r.enabled) ? theme.colorScheme.primary : null,
              title: l10n.settingsNotifications,
              description: l10n.settingsNotificationsEnabledDesc(
                  notifPrefs.all.where((r) => r.enabled).length),
              onTap: () => _showNotificationsDialog(context, ref, l10n, notifPrefs),
            ),
            const Divider(height: 1),
            _SettingsTile(
              icon: Icons.help_outline,
              title: l10n.settingsReplayTutorial,
              description: l10n.settingsReplayTutorialDesc,
              onTap: () => showOnboardingSheet(context),
            ),
            const Divider(height: 1),
            _SettingsTile(
              icon: Icons.ios_share,
              title: l10n.settingsExportData,
              description: l10n.settingsExportDataDesc,
              onTap: () => _exportData(context, ref, l10n),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            _SettingsTile(
              icon: Icons.auto_awesome,
              iconColor: hasApiKey ? Colors.green : theme.colorScheme.error,
              title: l10n.settingsApiKeyTitle,
              description: hasApiKey
                  ? l10n.settingsApiKeySubtitleSet
                  : l10n.settingsApiKeySubtitleUnset,
              onTap: () => _showApiKeyDialog(context, ref, l10n, hasApiKey),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            _SettingsTile(
              icon: Icons.delete_forever,
              iconColor: theme.colorScheme.error,
              titleColor: theme.colorScheme.error,
              title: l10n.settingsDeleteAllData,
              description: l10n.settingsDeleteAllDataDesc,
              onTap: () => _confirmDeleteAll(context, ref, l10n),
            ),
            const Divider(height: 1),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _showApiKeyDialog(BuildContext context, WidgetRef ref,
      AppLocalizations l10n, bool hasApiKey) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsApiKeyDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.settingsApiKeyDialogIntro),
            const SizedBox(height: 6),
            InkWell(
              onTap: () => launchUrl(
                Uri.parse('https://aistudio.google.com/app/apikey'),
                mode: LaunchMode.externalApplication,
              ),
              child: Text(
                l10n.settingsApiKeyDialogLinkLabel,
                style: TextStyle(
                  color: Theme.of(ctx).colorScheme.primary,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(l10n.settingsApiKeyDialogOutro),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.settingsApiKeyFieldLabel),
            ),
          ],
        ),
        actions: [
          if (hasApiKey)
            TextButton(
              onPressed: () => Navigator.of(ctx).pop('__remove__'),
              child: Text(l10n.settingsApiKeyRemove,
                  style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
            ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.settingsCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: Text(l10n.settingsApiKeySave),
          ),
        ],
      ),
    );

    if (result == null || !context.mounted) return;

    if (result == '__remove__') {
      await ref.read(apiKeyControllerProvider.notifier).remove();
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.settingsApiKeyRemoved)));
      }
      return;
    }

    if (result.trim().isEmpty) return;
    await ref.read(apiKeyControllerProvider.notifier).save(result);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.settingsApiKeySaved)));
    }
  }

  Future<void> _confirmDeleteAll(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsDeleteConfirmTitle),
        content: Text(l10n.settingsDeleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.settingsCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.settingsConfirm),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await AppDatabase.instance.deleteAllData();
      await ref.read(authControllerProvider.notifier).resetAfterDataDeleted();
    }
  }

  String _mealLabel(AppLocalizations l10n, MealReminderType type) => switch (type) {
        MealReminderType.breakfast => l10n.settingsNotificationsBreakfastLabel,
        MealReminderType.lunch => l10n.settingsNotificationsLunchLabel,
        MealReminderType.dinner => l10n.settingsNotificationsDinnerLabel,
      };

  String _mealPushTitle(AppLocalizations l10n, MealReminderType type) => switch (type) {
        MealReminderType.breakfast => l10n.settingsNotificationsBreakfastPushTitle,
        MealReminderType.lunch => l10n.settingsNotificationsLunchPushTitle,
        MealReminderType.dinner => l10n.settingsNotificationsDinnerPushTitle,
      };

  Future<void> _showNotificationsDialog(BuildContext context, WidgetRef ref,
      AppLocalizations l10n, NotificationPreferences current) async {
    var reminders = {for (final r in current.all) r.type: r};

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(l10n.settingsNotificationsDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final type in MealReminderType.values) ...[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(_mealLabel(l10n, type)),
                  subtitle: reminders[type]!.enabled
                      ? Text(TimeOfDay(hour: reminders[type]!.hour, minute: reminders[type]!.minute)
                          .format(ctx))
                      : null,
                  value: reminders[type]!.enabled,
                  onChanged: (v) => setDialogState(
                      () => reminders[type] = reminders[type]!.copyWith(enabled: v)),
                ),
                if (reminders[type]!.enabled)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.settingsNotificationsTimeLabel),
                    trailing: Text(
                        TimeOfDay(hour: reminders[type]!.hour, minute: reminders[type]!.minute)
                            .format(ctx),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: ctx,
                        initialTime:
                            TimeOfDay(hour: reminders[type]!.hour, minute: reminders[type]!.minute),
                      );
                      if (picked != null) {
                        setDialogState(() => reminders[type] = reminders[type]!
                            .copyWith(hour: picked.hour, minute: picked.minute));
                      }
                    },
                  ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.settingsCancel),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                var anyDenied = false;
                for (final type in MealReminderType.values) {
                  final r = reminders[type]!;
                  final granted = await ref.read(notificationPreferencesProvider.notifier).save(
                        type: type,
                        enabled: r.enabled,
                        time: TimeOfDay(hour: r.hour, minute: r.minute),
                        title: _mealPushTitle(l10n, type),
                        body: l10n.settingsNotificationsPushBody,
                      );
                  if (!granted && r.enabled) anyDenied = true;
                }
                if (anyDenied && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.settingsNotificationsPermissionDenied)));
                }
              },
              child: Text(l10n.settingsSave),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final userId = ref.read(currentUserIdProvider);
    final profile = ref.read(profileControllerProvider).valueOrNull;
    if (userId == null || profile == null) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      final foodEntries = await ref
          .read(foodLogRepositoryProvider)
          .entriesForRange(userId, DateTime(2000), DateTime.now().add(const Duration(days: 1)));
      final pantryItems = await ref.read(pantryRepositoryProvider).allItems(userId);
      final file = await DataExportService().export(
        profile: profile,
        foodEntries: foodEntries,
        pantryItems: pantryItems,
      );
      if (!context.mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        subject: l10n.settingsExportShareSubject,
        text: l10n.settingsExportShareSubject,
        sharePositionOrigin: box == null ? null : (box.localToGlobal(Offset.zero) & box.size),
      ));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.settingsExportFailed)));
    }
  }
}

/// A single spacious, self-describing settings row: icon + bold title +
/// chevron on one line, with a muted explanatory line below — mirrors the
/// "Ayuda y soporte" / "Preferencias" style card layout the user asked to
/// match, rather than a cramped single-line ListTile.
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.description,
    this.iconColor,
    this.titleColor,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color? iconColor;
  final Color? titleColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon,
                      size: 24, color: iconColor ?? theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                  ),
                  if (onTap != null)
                    Icon(Icons.chevron_right, color: theme.colorScheme.outline),
                ],
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 38),
                child: Text(
                  description,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
