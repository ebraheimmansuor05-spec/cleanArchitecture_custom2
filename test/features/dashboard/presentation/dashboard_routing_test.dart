import 'package:flutter_clean_architecture_template/config/routing/app_router.dart';
import 'package:flutter_clean_architecture_template/config/routing/route_names.dart';
import 'package:flutter_clean_architecture_template/features/authentication/domain/entities/auth_user_entity.dart';
import 'package:flutter_clean_architecture_template/features/authentication/presentation/manager/session_state.dart';
import 'package:flutter_test/flutter_test.dart';

const _authenticatedUser = AuthUserEntity(
  id: 'dashboard-test-user',
  email: 'owner@kitchenflow.test',
  displayName: null,
  isEmailVerified: true,
);

void main() {
  test('unauthenticated user cannot access Dashboard', () {
    expect(
      authenticationRedirect(
        sessionState: const SessionUnauthenticated(),
        location: RouteNames.kDashboardPage,
      ),
      RouteNames.kLoginPage,
    );
  });

  test('authenticated user can access Dashboard', () {
    expect(
      authenticationRedirect(
        sessionState: const SessionAuthenticated(_authenticatedUser),
        location: RouteNames.kDashboardPage,
      ),
      isNull,
    );
  });
}
