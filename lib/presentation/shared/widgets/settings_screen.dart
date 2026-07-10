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
    final apiKeyAsync = ref.watch(apiKeyControllerProvider);
    final hasApiKey = apiKeyAsync.valueOrNull?.isNotEmpty ?? false;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(l10n.settingsEditProfile),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.settingsLanguage),
              subtitle: const Text('Español'),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: Text(l10n.settingsNotifications),
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: Text(l10n.settingsReplayTutorial),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OnboardingScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.ios_share),
              title: Text(l10n.settingsExportData),
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.auto_awesome,
                color: hasApiKey ? Colors.green : Theme.of(context).colorScheme.error,
              ),
              title: Text(l10n.settingsApiKeyTitle),
              subtitle: Text(
                hasApiKey
                    ? l10n.settingsApiKeySubtitleSet
                    : l10n.settingsApiKeySubtitleUnset,
              ),
              onTap: () => _showApiKeyDialog(context, ref, l10n, hasApiKey),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.delete_forever,
                  color: Theme.of(context).colorScheme.error),
              title: Text(
                l10n.settingsDeleteAllData,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () => _confirmDeleteAll(context, ref, l10n),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(l10n.authLogoutButton),
              onTap: () => ref.read(authControllerProvider.notifier).logout(),
            ),
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
