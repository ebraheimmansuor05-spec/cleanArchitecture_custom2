import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/manager/session_cubit.dart';
import '../../features/authentication/presentation/manager/session_state.dart';
import '../../features/authentication/presentation/pages/account_session_page.dart';
import '../../features/authentication/presentation/pages/forgot_password_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/register_page.dart';
import '../../features/authentication/presentation/pages/session_check_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../root.dart';
import 'route_names.dart';

class AppRouterController {
  final SessionCubit sessionCubit;
  late final _SessionRefreshNotifier _refreshNotifier;
  late final GoRouter router;

  AppRouterController(this.sessionCubit) {
    _refreshNotifier = _SessionRefreshNotifier(sessionCubit.stream);
    router = GoRouter(
      navigatorKey: GlobalKey<NavigatorState>(),
      initialLocation: RouteNames.kSessionCheckPage,
      refreshListenable: _refreshNotifier,
      redirect: (context, state) => authenticationRedirect(
        sessionState: sessionCubit.state,
        location: state.matchedLocation,
      ),
      routes: [
        GoRoute(
          path: RouteNames.kSessionCheckPage,
          name: 'session-check',
          builder: (context, state) => const SessionCheckPage(),
        ),
        GoRoute(
          path: RouteNames.kLoginPage,
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: RouteNames.kRegisterPage,
          name: 'register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: RouteNames.kForgotPasswordPage,
          name: 'forgot-password',
          builder: (context, state) => const ForgotPasswordPage(),
        ),
        GoRoute(
          path: RouteNames.kAccountSessionPage,
          name: 'account-session',
          builder: (context, state) => const AccountSessionPage(),
        ),
        GoRoute(
          path: RouteNames.kDashboardPage,
          name: 'dashboard',
          builder: (context, state) => const DashboardPage(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return RootPage(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.kRootPage,
                  name: 'home',
                  redirect: (context, state) => RouteNames.kDashboardPage,
                  builder: (context, state) => const HomePage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.kCartPage,
                  name: 'cart',
                  builder: (context, state) => const CartPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.kProfilePage,
                  name: 'profile',
                  builder: (context, state) => const ProfilePage(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void dispose() {
    router.dispose();
    _refreshNotifier.dispose();
  }
}

String? authenticationRedirect({
  required SessionState sessionState,
  required String location,
}) {
  final isChecking =
      sessionState is SessionInitial || sessionState is SessionChecking;
  final isSessionCheck = location == RouteNames.kSessionCheckPage;
  final isPublic =
      location == RouteNames.kLoginPage ||
      location == RouteNames.kRegisterPage ||
      location == RouteNames.kForgotPasswordPage;

  if (isChecking) {
    return isSessionCheck ? null : RouteNames.kSessionCheckPage;
  }

  if (sessionState.isAuthenticated) {
    if (isSessionCheck || isPublic) {
      return RouteNames.kAccountSessionPage;
    }
    return null;
  }

  return isPublic ? null : RouteNames.kLoginPage;
}

class _SessionRefreshNotifier extends ChangeNotifier {
  late final StreamSubscription<SessionState> _subscription;

  _SessionRefreshNotifier(Stream<SessionState> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
