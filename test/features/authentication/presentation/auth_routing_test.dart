import 'package:flutter_clean_architecture_template/config/routing/app_router.dart';
import 'package:flutter_clean_architecture_template/config/routing/route_names.dart';
import 'package:flutter_clean_architecture_template/features/authentication/presentation/manager/session_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  test('session checking always protects application content', () {
    expect(
      authenticationRedirect(
        sessionState: const SessionChecking(),
        location: RouteNames.kRootPage,
      ),
      RouteNames.kSessionCheckPage,
    );
  });

  test('unauthenticated user is redirected from protected route', () {
    expect(
      authenticationRedirect(
        sessionState: const SessionUnauthenticated(),
        location: RouteNames.kProfilePage,
      ),
      RouteNames.kLoginPage,
    );
  });

  test('unauthenticated user can access F01 public routes', () {
    expect(
      authenticationRedirect(
        sessionState: const SessionUnauthenticated(),
        location: RouteNames.kRegisterPage,
      ),
      isNull,
    );
  });

  test('authenticated user leaves login for neutral session boundary', () {
    expect(
      authenticationRedirect(
        sessionState: const SessionAuthenticated(testUser),
        location: RouteNames.kLoginPage,
      ),
      RouteNames.kAccountSessionPage,
    );
  });

  test('authenticated user can access protected application route', () {
    expect(
      authenticationRedirect(
        sessionState: const SessionAuthenticated(testUser),
        location: RouteNames.kRootPage,
      ),
      isNull,
    );
  });
}
