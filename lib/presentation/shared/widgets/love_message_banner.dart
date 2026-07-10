import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// A small original mascot + message that fades in and out on a loop,
/// shown below the save button on the food entry screen.
class LoveMessageBanner extends StatefulWidget {
  const LoveMessageBanner({super.key});

  @override
  State<LoveMessageBanner> createState() => _LoveMessageBannerState();
}

class _LoveMessageBannerState extends State<LoveMessageBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: FadeTransition(
        opacity: _opacity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/mascot/love_mascot.png', width: 64, height: 64),
            const SizedBox(height: 8),
            Text(
              l10n.foodLogLoveMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
