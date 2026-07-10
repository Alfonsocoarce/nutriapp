import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/services/gemini_food_recognition_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/widgets/settings_screen.dart';
import '../providers/food_log_providers.dart';
import 'food_entry_form_screen.dart';

enum _CaptureMode { meal, label }

class FoodLogScreen extends ConsumerStatefulWidget {
  const FoodLogScreen({super.key});

  @override
  ConsumerState<FoodLogScreen> createState() => _FoodLogScreenState();
}

class _FoodLogScreenState extends ConsumerState<FoodLogScreen> {
  bool _analyzing = false;
  _CaptureMode _mode = _CaptureMode.meal;

  Future<void> _capture(ImageSource source) async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: source, imageQuality: 85);
    if (photo == null) return;
    await _analyze(photo.path);
  }

  Future<void> _analyze(String photoPath) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _analyzing = true);
    try {
      final service = _mode == _CaptureMode.label
          ? ref.read(labelRecognitionServiceProvider)
          : ref.read(foodRecognitionServiceProvider);
      final result = await service.analyze(photoPath);
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) =>
            FoodEntryFormScreen(initialResult: result, photoPath: photoPath),
      ));
    } on MissingApiKeyException {
      if (mounted) await _showMissingApiKeyDialog(l10n);
    } catch (error, stackTrace) {
      debugPrint('Food recognition failed: $error\n$stackTrace');
      if (mounted) {
        final shouldRetry = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.foodLogAnalysisFailedTitle),
            content: Text(l10n.foodLogAnalysisFailedMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(l10n.settingsCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        );
        if (shouldRetry == true) {
          if (mounted) setState(() => _analyzing = false);
          return _analyze(photoPath);
        }
      }
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  Future<void> _showMissingApiKeyDialog(AppLocalizations l10n) async {
    final goToSettings = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.foodLogMissingApiKeyTitle),
        content: Text(l10n.foodLogMissingApiKeyMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.settingsCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.foodLogGoToSettings),
          ),
        ],
      ),
    );
    if (goToSettings == true && mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
    }
  }

  void _manualEntry() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const FoodEntryFormScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.foodLogTitle)),
      body: SafeArea(
        child: Center(
          child: _analyzing
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(l10n.foodLogAnalyzing),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SegmentedButton<_CaptureMode>(
                        segments: [
                          ButtonSegment(
                            value: _CaptureMode.meal,
                            label: Text(l10n.foodLogModeMeal),
                            icon: const Icon(Icons.restaurant),
                          ),
                          ButtonSegment(
                            value: _CaptureMode.label,
                            label: Text(l10n.foodLogModeLabel),
                            icon: const Icon(Icons.label_outline),
                          ),
                        ],
                        selected: {_mode},
                        onSelectionChanged: (selection) =>
                            setState(() => _mode = selection.first),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.lightbulb_outline,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer,
                                size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _mode == _CaptureMode.label
                                    ? l10n.foodLogLabelTip
                                    : l10n.foodLogVisibilityTip,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () => _capture(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: Text(l10n.foodLogTakePhoto),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => _capture(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: Text(l10n.foodLogChooseFromGallery),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: _manualEntry,
                        child: Text(l10n.foodLogManualEntry),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
