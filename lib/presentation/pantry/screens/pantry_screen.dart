import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/enum_labels.dart';
import '../../../domain/entities/pantry_item.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/pantry_providers.dart';
import 'invoice_review_screen.dart';
import 'pantry_item_form_screen.dart';

class PantryScreen extends ConsumerStatefulWidget {
  const PantryScreen({super.key});

  @override
  ConsumerState<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends ConsumerState<PantryScreen> {
  bool _analyzingInvoice = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final itemsAsync = ref.watch(pantryControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pantryTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: _analyzingInvoice ? null : () => _showAddOptions(context),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: _analyzingInvoice
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(l10n.invoiceAnalyzing),
                  ],
                ),
              )
            : itemsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(l10n.commonError)),
                data: (items) {
                  if (items.isEmpty) {
                    return Center(child: Text(l10n.pantryEmpty));
                  }
                  final grouped = <String, List<PantryItem>>{};
                  for (final item in items) {
                    grouped
                        .putIfAbsent(item.category.label(l10n), () => [])
                        .add(item);
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

  Future<void> _showAddOptions(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: Text(l10n.pantryUploadInvoice),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pickAndAnalyzeInvoice();
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l10n.pantryAddManually),
              onTap: () {
                Navigator.of(sheetContext).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PantryItemFormScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndAnalyzeInvoice() async {
    final l10n = AppLocalizations.of(context)!;
    const pdfType = XTypeGroup(label: 'PDF', extensions: ['pdf']);
    final file = await openFile(acceptedTypeGroups: const [pdfType]);
    final path = file?.path;
    if (path == null) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.invoiceNoFileSelected)));
      }
      return;
    }

    setState(() => _analyzingInvoice = true);
    try {
      final items =
          await ref.read(invoiceParsingServiceProvider).parseInvoice(path);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => InvoiceReviewScreen(items: items)),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.invoiceParsingError)));
      }
    } finally {
      if (mounted) setState(() => _analyzingInvoice = false);
    }
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
      dense: true,
      visualDensity: VisualDensity.compact,
      title: Text(item.productName,
          maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${item.quantity} ${item.unit}'
        '${days != null ? ' · ${l10n.pantryDaysRemaining}: $days' : ''}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
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
