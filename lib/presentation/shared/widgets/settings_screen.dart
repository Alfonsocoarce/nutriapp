import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/app_database.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_providers.dart';
import '../../onboarding/screens/onboarding_screen.dart';
import '../../profile/screens/profile_setup_screen.dart';
import '../../settings/providers/api_key_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final apiKeyAsync = ref.watch(apiKeyControllerProvider);
    final hasApiKey = apiKeyAsync.valueOrNull?.isNotEmpty ?? false;

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
              icon: Icons.language,
              title: l10n.settingsLanguage,
              description: l10n.settingsLanguageDesc,
            ),
            const Divider(height: 1),
            _SettingsTile(
              icon: Icons.notifications_outlined,
              title: l10n.settingsNotifications,
              description: l10n.settingsNotificationsDesc,
            ),
            const Divider(height: 1),
            _SettingsTile(
              icon: Icons.help_outline,
              title: l10n.settingsReplayTutorial,
              description: l10n.settingsReplayTutorialDesc,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OnboardingScreen()),
              ),
            ),
            const Divider(height: 1),
            _SettingsTile(
              icon: Icons.ios_share,
              title: l10n.settingsExportData,
              description: l10n.settingsExportDataDesc,
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
