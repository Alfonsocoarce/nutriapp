import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/enum_labels.dart';
import '../../../domain/entities/invoice_line_item.dart';
import '../../../domain/entities/pantry_category.dart';
import '../../../domain/entities/pantry_item.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/pantry_providers.dart';

/// Lets the user confirm/edit the products a scanned invoice produced
/// before any of them are written to the pantry (ERS RF-09/RF-10).
class InvoiceReviewScreen extends ConsumerStatefulWidget {
  const InvoiceReviewScreen({super.key, required this.items});

  final List<InvoiceLineItem> items;

  @override
  ConsumerState<InvoiceReviewScreen> createState() => _InvoiceReviewScreenState();
}

class _ReviewRow {
  _ReviewRow(InvoiceLineItem item)
      : nameController = TextEditingController(text: item.productName),
        quantityController =
            TextEditingController(text: item.quantity.toString()),
        unitController = TextEditingController(text: item.unit),
        category = item.category,
        included = true;

  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController unitController;
  PantryCategory category;
  bool included;
}

class _InvoiceReviewScreenState extends ConsumerState<InvoiceReviewScreen> {
  late final List<_ReviewRow> _rows =
      widget.items.map((e) => _ReviewRow(e)).toList();
  bool _saving = false;

  @override
  void dispose() {
    for (final row in _rows) {
      row.nameController.dispose();
      row.quantityController.dispose();
      row.unitController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.invoiceReviewTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.invoiceReviewSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _rows.length,
                separatorBuilder: (_, _) => const Divider(height: 24),
                itemBuilder: (context, index) => _buildRow(context, l10n, index),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: _saving ? null : _saveAll,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.invoiceSaveAll),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, AppLocalizations l10n, int index) {
    final row = _rows[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: row.included,
          onChanged: (v) => setState(() => row.included = v ?? true),
          title: TextField(
            controller: row.nameController,
            enabled: row.included,
            decoration: InputDecoration(labelText: l10n.pantryProductName),
          ),
        ),
        if (row.included) ...[
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: row.quantityController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: l10n.pantryQuantity),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: row.unitController,
                  decoration: InputDecoration(labelText: l10n.pantryUnit),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<PantryCategory>(
            initialValue: row.category,
            items: PantryCategory.values
                .map((c) => DropdownMenuItem(value: c, child: Text(c.label(l10n))))
                .toList(),
            onChanged: (v) => setState(() => row.category = v ?? row.category),
          ),
        ],
      ],
    );
  }

  Future<void> _saveAll() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    setState(() => _saving = true);

    final now = DateTime.now();
    final items = _rows.where((r) => r.included).map((row) {
      return PantryItem(
        id: 0,
        userId: userId,
        productName: row.nameController.text,
        category: row.category,
        quantity: double.tryParse(row.quantityController.text) ?? 1,
        unit: row.unitController.text,
        purchaseDate: now,
      );
    }).toList();

    await ref.read(pantryControllerProvider.notifier).addItems(items);

    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.invoiceItemsSaved)));
    }
  }
}
