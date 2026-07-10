import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/enum_labels.dart';
import '../../../domain/entities/confidence_level.dart';
import '../../../domain/entities/food_component_breakdown.dart';
import '../../../domain/entities/food_entry.dart';
import '../../../domain/entities/food_recognition_result.dart';
import '../../../domain/entities/meal_type.dart';
import '../../../domain/entities/nutrition_info.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_providers.dart';
import '../../shared/widgets/love_message_banner.dart';
import '../providers/food_log_providers.dart';

/// Confirms/edits a food entry before saving. Used both after AI photo
/// analysis (pre-filled from [initialResult]) and for fully manual entry
/// (initialResult == null).
class FoodEntryFormScreen extends ConsumerStatefulWidget {
  const FoodEntryFormScreen({super.key, this.initialResult, this.photoPath});

  final FoodRecognitionResult? initialResult;
  final String? photoPath;

  @override
  ConsumerState<FoodEntryFormScreen> createState() => _FoodEntryFormScreenState();
}

class _FoodEntryFormScreenState extends ConsumerState<FoodEntryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinController;
  late final TextEditingController _carbsController;
  late final TextEditingController _fatController;
  late MealType _mealType;
  ConfidenceLevel? _confidence;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final r = widget.initialResult;
    _nameController = TextEditingController(text: r?.foodName ?? '');
    _caloriesController =
        TextEditingController(text: r?.nutrition.calories?.toStringAsFixed(0) ?? '');
    _proteinController = TextEditingController(
        text: r?.nutrition.proteinGrams?.toStringAsFixed(0) ?? '');
    _carbsController =
        TextEditingController(text: r?.nutrition.carbsGrams?.toStringAsFixed(0) ?? '');
    _fatController =
        TextEditingController(text: r?.nutrition.fatGrams?.toStringAsFixed(0) ?? '');
    _mealType = MealType.fromHour(DateTime.now().hour);
    _confidence = r?.nutrition.confidence;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.foodLogAnalysisResult)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_confidence != null) ...[
                  Chip(
                    label: Text(
                        '${l10n.foodLogConfidenceLevel}: ${_confidenceLabel(_confidence!, l10n)}'),
                    avatar: const Icon(Icons.info_outline, size: 18),
                  ),
                  const SizedBox(height: 12),
                ],
                if (widget.initialResult?.visibilityWarning != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: Theme.of(context)
                                .colorScheme
                                .onErrorContainer,
                            size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.foodLogVisibilityWarningTitle,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onErrorContainer,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.initialResult!.visibilityWarning!,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onErrorContainer,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: l10n.foodLogFoodName),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? l10n.commonRequired : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<MealType>(
                  initialValue: _mealType,
                  decoration: InputDecoration(labelText: l10n.foodLogEditClassification),
                  items: MealType.values
                      .map((m) =>
                          DropdownMenuItem(value: m, child: Text(m.label(l10n))))
                      .toList(),
                  onChanged: (v) => setState(() => _mealType = v!),
                ),
                const SizedBox(height: 16),
                _NutrientField(
                  controller: _caloriesController,
                  label: l10n.foodLogCalories,
                  suffix: l10n.commonKcal,
                  notAvailableLabel: l10n.foodLogNotAvailable,
                ),
                _NutrientField(
                  controller: _proteinController,
                  label: l10n.dashboardProtein,
                  suffix: l10n.commonGrams,
                  notAvailableLabel: l10n.foodLogNotAvailable,
                ),
                _NutrientField(
                  controller: _carbsController,
                  label: l10n.dashboardCarbs,
                  suffix: l10n.commonGrams,
                  notAvailableLabel: l10n.foodLogNotAvailable,
                ),
                _NutrientField(
                  controller: _fatController,
                  label: l10n.dashboardFat,
                  suffix: l10n.commonGrams,
                  notAvailableLabel: l10n.foodLogNotAvailable,
                ),
                if ((widget.initialResult?.components ?? const []).isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _ComponentBreakdownList(
                    title: l10n.foodLogComponentBreakdownTitle,
                    components: widget.initialResult!.components,
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l10n.foodLogSaveEntry),
                ),
                const SizedBox(height: 16),
                const LoveMessageBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _confidenceLabel(ConfidenceLevel c, AppLocalizations l10n) => switch (c) {
        ConfidenceLevel.high => l10n.foodLogConfidenceHigh,
        ConfidenceLevel.medium => l10n.foodLogConfidenceMedium,
        ConfidenceLevel.low => l10n.foodLogConfidenceLow,
      };

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    setState(() => _saving = true);

    final entry = FoodEntry(
      id: 0,
      userId: userId,
      foodName: _nameController.text,
      loggedAt: DateTime.now(),
      mealType: _mealType,
      nutrition: NutritionInfo(
        calories: double.tryParse(_caloriesController.text),
        proteinGrams: double.tryParse(_proteinController.text),
        carbsGrams: double.tryParse(_carbsController.text),
        fatGrams: double.tryParse(_fatController.text),
        confidence: _confidence ?? ConfidenceLevel.high,
      ),
      photoPath: widget.photoPath,
      estimatedWeightGrams: widget.initialResult?.estimatedWeightGrams,
      servings: widget.initialResult?.servings,
      cookingMethod: widget.initialResult?.cookingMethod,
      components: widget.initialResult?.components ?? const [],
    );

    await ref.read(todaysFoodLogProvider.notifier).addEntry(entry);

    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.foodLogEntrySaved)));
    }
  }
}

class _ComponentBreakdownList extends StatelessWidget {
  const _ComponentBreakdownList({required this.title, required this.components});

  final String title;
  final List<FoodComponentBreakdown> components;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          for (final c in components) ...[
            Row(
              children: [
                Expanded(
                  child: Text(c.name.isEmpty ? '—' : c.name,
                      style: theme.textTheme.bodyMedium),
                ),
                if (c.calories != null)
                  Text('${c.calories!.toStringAsFixed(0)} kcal',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            Text(
              [
                if (c.estimatedWeightGrams != null)
                  '~${c.estimatedWeightGrams!.toStringAsFixed(0)} g',
                if (c.proteinGrams != null)
                  'P ${c.proteinGrams!.toStringAsFixed(0)} g',
                if (c.carbsGrams != null)
                  'C ${c.carbsGrams!.toStringAsFixed(0)} g',
                if (c.fatGrams != null) 'G ${c.fatGrams!.toStringAsFixed(0)} g',
              ].join(' · '),
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            if (c != components.last) const Divider(height: 16),
          ],
        ],
      ),
    );
  }
}

class _NutrientField extends StatelessWidget {
  const _NutrientField({
    required this.controller,
    required this.label,
    required this.suffix,
    required this.notAvailableLabel,
  });

  final TextEditingController controller;
  final String label;
  final String suffix;
  final String notAvailableLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          hintText: notAvailableLabel,
        ),
      ),
    );
  }
}
