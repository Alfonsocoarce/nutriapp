import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../l10n/app_localizations.dart';
import '../providers/food_log_providers.dart';
import 'food_entry_form_screen.dart';

class FoodLogScreen extends ConsumerStatefulWidget {
  const FoodLogScreen({super.key});

  @override
  ConsumerState<FoodLogScreen> createState() => _FoodLogScreenState();
}

class _FoodLogScreenState extends ConsumerState<FoodLogScreen> {
  bool _analyzing = false;

  Future<void> _capture(ImageSource source) async {
    final l10n = AppLocalizations.of(context)!;
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: source, imageQuality: 85);
    if (photo == null) return;

    setState(() => _analyzing = true);
    try {
      final result =
          await ref.read(foodRecognitionServiceProvider).analyze(photo.path);
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) =>
            FoodEntryFormScreen(initialResult: result, photoPath: photo.path),
      ));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.commonError)));
      }
    } finally {
      if (mounted) setState(() => _analyzing = false);
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
