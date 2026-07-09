import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/enum_labels.dart';
import '../../../domain/entities/pantry_item.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/pantry_providers.dart';
import 'pantry_item_form_screen.dart';

class PantryScreen extends ConsumerWidget {
  const PantryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final itemsAsync = ref.watch(pantryControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pantryTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PantryItemFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: itemsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(l10n.commonError)),
          data: (items) {
            if (items.isEmpty) {
              return Center(child: Text(l10n.pantryEmpty));
            }
            final grouped = <String, List<PantryItem>>{};
            for (final item in items) {
              grouped.putIfAbsent(item.category.label(l10n), () => []).add(item);
            }
            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: grouped.entries.map((entry) {
                return ExpansionTile(
                  title: Text(entry.key),
                  initiallyExpanded: true,
                  children: entry.value
                      .map((item) => _PantryTile(item: item))
                      .toList(),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

class _PantryTile extends ConsumerWidget {
  const _PantryTile({required this.item});

  final PantryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final days = item.daysRemaining;

    Color? statusColor;
    String? statusLabel;
    if (item.isExpired) {
      statusColor = Theme.of(context).colorScheme.error;
      statusLabel = l10n.pantryExpired;
    } else if (item.isExpiringSoon) {
      statusColor = Colors.orange;
      statusLabel = l10n.pantryExpiringSoon;
    }

    return ListTile(
      title: Text(item.productName),
      subtitle: Text('${item.quantity} ${item.unit}'
          '${days != null ? ' · ${l10n.pantryDaysRemaining}: $days' : ''}'),
      trailing: statusLabel == null
          ? IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () =>
                  ref.read(pantryControllerProvider.notifier).deleteItem(item.id),
            )
          : Chip(
              label: Text(statusLabel, style: const TextStyle(color: Colors.white)),
              backgroundColor: statusColor,
            ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PantryItemFormScreen(existing: item)),
      ),
    );
  }
}
