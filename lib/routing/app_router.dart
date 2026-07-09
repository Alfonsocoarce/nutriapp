import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/auth/providers/auth_providers.dart';
import '../presentation/auth/screens/login_screen.dart';
import '../presentation/auth/screens/register_screen.dart';
import '../presentation/shared/widgets/main_shell.dart';

/// Bridges Riverpod auth state changes into a [Listenable] so GoRouter can
/// re-evaluate its redirect whenever the session changes.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(authControllerProvider, (previous, next) => notifyListeners());
  }
}

final _authListenableProvider = Provider<_AuthListenable>((ref) {
  final listenable = _AuthListenable(ref);
  ref.onDispose(listenable.dispose);
  return listenable;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: ref.watch(_authListenableProvider),
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      if (authState.isLoading) return null;

      final loggedIn = authState.valueOrNull != null;
      final onAuthScreen =
          state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (!loggedIn && !onAuthScreen) return '/login';
      if (loggedIn && onAuthScreen) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/', builder: (context, state) => const MainShell()),
    ],
  );
});
