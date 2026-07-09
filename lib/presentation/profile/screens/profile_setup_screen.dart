import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/enum_labels.dart';
import '../../../domain/entities/activity_level.dart';
import '../../../domain/entities/nutrition_goal.dart';
import '../../../domain/entities/sex.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/profile_providers.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _currentWeightController = TextEditingController();
  final _targetWeightController = TextEditingController();

  DateTime? _birthDate;
  Sex _sex = Sex.female;
  ActivityLevel _activityLevel = ActivityLevel.moderate;
  final Set<NutritionGoal> _goals = {};
  bool _initializedFromExisting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _currentWeightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  void _populateFrom(UserProfile profile) {
    if (_initializedFromExisting) return;
    _initializedFromExisting = true;
    _nameController.text = profile.name;
    _heightController.text = profile.heightCm.toStringAsFixed(0);
    _currentWeightController.text = profile.currentWeightKg.toStringAsFixed(1);
    _targetWeightController.text = profile.targetWeightKg.toStringAsFixed(1);
    _birthDate = profile.birthDate;
    _sex = profile.sex;
    _activityLevel = profile.activityLevel;
    _goals
      ..clear()
      ..addAll(profile.goals);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profileState = ref.watch(profileControllerProvider);

    profileState.whenData((profile) {
      if (profile != null) _populateFrom(profile);
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
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
                  decoration: InputDecoration(labelText: l10n.profileName),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? l10n.commonRequired : null,
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.profileBirthDate),
                  subtitle: Text(_birthDate == null
                      ? l10n.commonRequired
                      : '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickBirthDate,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Sex>(
                  initialValue: _sex,
                  decoration: InputDecoration(labelText: l10n.profileSex),
                  items: Sex.values
                      .map((s) =>
                          DropdownMenuItem(value: s, child: Text(s.label(l10n))))
                      .toList(),
                  onChanged: (v) => setState(() => _sex = v!),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: l10n.profileHeight, suffixText: l10n.commonCm),
                  validator: (v) => _validateNumber(v, l10n),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _currentWeightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      labelText: l10n.profileCurrentWeight, suffixText: l10n.commonKg),
                  validator: (v) => _validateNumber(v, l10n),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _targetWeightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      labelText: l10n.profileTargetWeight, suffixText: l10n.commonKg),
                  validator: (v) => _validateNumber(v, l10n),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ActivityLevel>(
                  initialValue: _activityLevel,
                  decoration: InputDecoration(labelText: l10n.profileActivityLevel),
                  items: ActivityLevel.values
                      .map((a) =>
                          DropdownMenuItem(value: a, child: Text(a.label(l10n))))
                      .toList(),
                  onChanged: (v) => setState(() => _activityLevel = v!),
                ),
                const SizedBox(height: 20),
                Text(l10n.goalsTitle, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: NutritionGoal.values.map((goal) {
                    final selected = _goals.contains(goal);
                    return FilterChip(
                      label: Text(goal.label(l10n)),
                      selected: selected,
                      onSelected: (value) => setState(() {
                        if (value) {
                          _goals.add(goal);
                        } else {
                          _goals.remove(goal);
                        }
                      }),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: profileState.isLoading ? null : _submit,
                  child: Text(l10n.profileSaveButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validateNumber(String? value, AppLocalizations l10n) {
    if (value == null || double.tryParse(value) == null) {
      return l10n.commonRequired;
    }
    return null;
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 25),
      firstDate: DateTime(now.year - 120),
      lastDate: now,
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate() || _birthDate == null) return;
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final profile = UserProfile(
      userId: userId,
      name: _nameController.text,
      birthDate: _birthDate!,
      sex: _sex,
      heightCm: double.parse(_heightController.text),
      currentWeightKg: double.parse(_currentWeightController.text),
      targetWeightKg: double.parse(_targetWeightController.text),
      activityLevel: _activityLevel,
      goals: _goals.toList(),
    );

    ref.read(profileControllerProvider.notifier).save(profile).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.profileSavedMessage)),
        );
      }
    });
  }
}
