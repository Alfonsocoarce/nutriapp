import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/auth/providers/auth_providers.dart';
import '../presentation/plan/screens/my_plan_screen.dart';
import '../presentation/shared/widgets/main_shell.dart';

/// No login: the router just waits for the single local user to be
/// created/resolved once at startup, then always shows [MainShell].
class _StartupGate extends ConsumerWidget {
  const _StartupGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    return authState.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => const Scaffold(body: Center(child: Icon(Icons.error_outline))),
      data: (_) => const MainShell(),
    );
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const _StartupGate()),
      GoRoute(path: '/mi-plan', builder: (context, state) => const MyPlanScreen()),
    ],
  );
});
