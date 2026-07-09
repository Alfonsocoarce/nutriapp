import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/app_database.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_providers.dart';
import '../../profile/screens/profile_setup_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

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
              leading: const Icon(Icons.ios_share),
              title: Text(l10n.settingsExportData),
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
