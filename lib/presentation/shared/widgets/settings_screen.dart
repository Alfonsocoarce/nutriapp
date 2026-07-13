import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

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
              icon: notifPrefs.enabled
                  ? Icons.notifications_active
                  : Icons.notifications_outlined,
              iconColor: notifPrefs.enabled ? theme.colorScheme.primary : null,
              title: l10n.settingsNotifications,
              description: notifPrefs.enabled
                  ? l10n.settingsNotificationsEnabledDesc(
                      TimeOfDay(hour: notifPrefs.hour, minute: notifPrefs.minute).format(context))
                  : l10n.settingsNotificationsDesc,
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
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const StadiumBorder(),
                ),
                onPressed: () => ref.read(authControllerProvider.notifier).logout(),
                icon: const Icon(Icons.logout),
                label: Text(l10n.authLogoutButton),
              ),
            ),
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
            Text(l10n.settingsApiKeyDialogDescription),
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
      await ref.read(authControllerProvider.notifier).logout();
    }
  }

  Future<void> _showNotificationsDialog(BuildContext context, WidgetRef ref,
      AppLocalizations l10n, NotificationPreferences current) async {
    var enabled = current.enabled;
    var time = TimeOfDay(hour: current.hour, minute: current.minute);

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(l10n.settingsNotificationsDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.settingsNotificationsToggleLabel),
                value: enabled,
                onChanged: (v) => setDialogState(() => enabled = v),
              ),
              if (enabled)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.settingsNotificationsTimeLabel),
                  trailing: Text(time.format(ctx),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () async {
                    final picked = await showTimePicker(context: ctx, initialTime: time);
                    if (picked != null) setDialogState(() => time = picked);
                  },
                ),
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
                final granted = await ref.read(notificationPreferencesProvider.notifier).save(
                      enabled: enabled,
                      time: time,
                      title: l10n.settingsNotificationsPushTitle,
                      body: l10n.settingsNotificationsPushBody,
                    );
                if (!granted && enabled && context.mounted) {
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
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        subject: l10n.settingsExportShareSubject,
        text: l10n.settingsExportShareSubject,
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
