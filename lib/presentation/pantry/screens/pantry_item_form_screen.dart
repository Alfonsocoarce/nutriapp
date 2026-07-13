import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/enum_labels.dart';
import '../../../domain/entities/pantry_category.dart';
import '../../../domain/entities/pantry_item.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/pantry_providers.dart';

class PantryItemFormScreen extends ConsumerStatefulWidget {
  const PantryItemFormScreen({super.key, this.existing});

  final PantryItem? existing;

  @override
  ConsumerState<PantryItemFormScreen> createState() => _PantryItemFormScreenState();
}

class _PantryItemFormScreenState extends ConsumerState<PantryItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _unitController;
  late PantryCategory _category;
  DateTime _purchaseDate = DateTime.now();
  DateTime? _expirationDate;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameController = TextEditingController(text: e?.productName ?? '');
    _quantityController = TextEditingController(text: e?.quantity.toString() ?? '1');
    _unitController = TextEditingController(text: e?.unit ?? '');
    _category = e?.category ?? PantryCategory.vegetables;
    _purchaseDate = e?.purchaseDate ?? DateTime.now();
    _expirationDate = e?.expirationDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pantryAddItem)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: l10n.pantryProductName),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? l10n.commonRequired : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<PantryCategory>(
                  initialValue: _category,
                  decoration: const InputDecoration(),
                  items: PantryCategory.values
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c.label(l10n))))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: l10n.pantryQuantity),
                        validator: (v) =>
                            double.tryParse(v ?? '') == null ? l10n.commonRequired : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _unitController,
                        decoration: InputDecoration(labelText: l10n.pantryUnit),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? l10n.commonRequired : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.pantryPurchaseDate),
                  subtitle: Text(_formatDate(_purchaseDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _pickDate(isPurchase: true),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _save,
                  child: Text(l10n.pantrySaveItem),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate({required bool isPurchase}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 3),
    );
    if (picked == null) return;
    setState(() => _purchaseDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final item = PantryItem(
      id: widget.existing?.id ?? 0,
      userId: userId,
      productName: _nameController.text,
      category: _category,
      quantity: double.parse(_quantityController.text),
      unit: _unitController.text,
      purchaseDate: _purchaseDate,
      expirationDate: _expirationDate,
    );

    final controller = ref.read(pantryControllerProvider.notifier);
    if (widget.existing == null) {
      await controller.addItem(item);
    } else {
      await controller.updateItem(item);
    }

    if (mounted) Navigator.of(context).pop();
  }
}
