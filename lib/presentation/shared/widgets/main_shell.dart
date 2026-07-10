import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../food_log/screens/food_log_screen.dart';
import '../../pantry/screens/pantry_screen.dart';
import '../../profile/providers/profile_providers.dart';
import '../../profile/screens/profile_setup_screen.dart';
import '../../reports/screens/weekly_report_screen.dart';
import 'settings_screen.dart';

/// Root screen once logged in. Forces profile setup first (RF-02) before
/// showing the tabbed app, since the dashboard/goals depend on it.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(profileControllerProvider);

    return profileAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text(l10n.commonError))),
      data: (profile) {
        if (profile == null) {
          return const ProfileSetupScreen();
        }

        final tabs = [
          const DashboardScreen(),
          const FoodLogScreen(),
          const PantryScreen(),
          const WeeklyReportScreen(),
          const SettingsScreen(),
        ];

        return Scaffold(
          body: IndexedStack(index: _tabIndex, children: tabs),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _tabIndex,
            onDestinationSelected: (i) => setState(() => _tabIndex = i),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.dashboard_outlined),
                selectedIcon: const Icon(Icons.dashboard),
                label: l10n.dashboardTitle,
              ),
              NavigationDestination(
                icon: const Icon(Icons.camera_alt_outlined),
                selectedIcon: const Icon(Icons.camera_alt),
                label: l10n.foodLogTitle,
              ),
              NavigationDestination(
                icon: const Icon(Icons.kitchen_outlined),
                selectedIcon: const Icon(Icons.kitchen),
                label: l10n.pantryTitle,
              ),
              NavigationDestination(
                icon: const Icon(Icons.summarize_outlined),
                selectedIcon: const Icon(Icons.summarize),
                label: l10n.reportsTitle,
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings),
                label: l10n.settingsTitle,
              ),
            ],
          ),
        );
      },
    );
  }
}
