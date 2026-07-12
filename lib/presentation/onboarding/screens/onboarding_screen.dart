import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/chart_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/onboarding_providers.dart';

class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;
}

/// Shows the first-time app walkthrough as a compact, dismissible modal
/// sheet rather than a full-screen takeover — quick to skim, doesn't block
/// the whole app. Shown once automatically after profile setup (see
/// [MainShell]), and replayable anytime from Configuración.
Future<void> showOnboardingSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _OnboardingSheet(),
  );
}

class _OnboardingSheet extends ConsumerStatefulWidget {
  const _OnboardingSheet();

  @override
  ConsumerState<_OnboardingSheet> createState() => _OnboardingSheetState();
}

class _OnboardingSheetState extends ConsumerState<_OnboardingSheet> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId != null) {
      await ref.read(onboardingStoreProvider).markOnboardingSeen(userId);
      ref.invalidate(hasSeenOnboardingProvider);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final pages = [
      _OnboardingPage(
        icon: Icons.dashboard,
        color: ChartColors.blue,
        title: l10n.onboardingPage1Title,
        description: l10n.onboardingPage1Description,
      ),
      _OnboardingPage(
        icon: Icons.camera_alt,
        color: ChartColors.amber,
        title: l10n.onboardingPage2Title,
        description: l10n.onboardingPage2Description,
      ),
      _OnboardingPage(
        icon: Icons.kitchen,
        color: ChartColors.red,
        title: l10n.onboardingPage3Title,
        description: l10n.onboardingPage3Description,
      ),
      _OnboardingPage(
        icon: Icons.summarize,
        color: ChartColors.blue,
        title: l10n.onboardingPage4Title,
        description: l10n.onboardingPage4Description,
      ),
      _OnboardingPage(
        icon: Icons.settings,
        color: ChartColors.amber,
        title: l10n.onboardingPage5Title,
        description: l10n.onboardingPage5Description,
      ),
    ];
    final isLastPage = _page == pages.length - 1;

    return SafeArea(
      top: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.58,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(l10n.onboardingSkip),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final page = pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: page.color.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(page.icon, size: 32, color: page.color),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < pages.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _page ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _page
                          ? pages[_page].color
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
              child: Row(
                children: [
                  if (_page > 0)
                    TextButton(
                      onPressed: () => _controller.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: Text(l10n.onboardingBack),
                    ),
                  const Spacer(),
                  FilledButton.tonal(
                    onPressed: isLastPage
                        ? _finish
                        : () => _controller.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            ),
                    child: Text(isLastPage ? l10n.onboardingFinish : l10n.onboardingNext),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
