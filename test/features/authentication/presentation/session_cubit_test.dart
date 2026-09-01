import 'package:dartz/dartz.dart';
import 'package:flutter_clean_architecture_template/features/authentication/domain/entities/auth_failure.dart';
import 'package:flutter_clean_architecture_template/features/authentication/domain/usecases/auth_use_cases.dart';
import 'package:flutter_clean_architecture_template/features/authentication/presentation/manager/session_cubit.dart';
import 'package:flutter_clean_architecture_template/features/authentication/presentation/manager/session_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  late FakeAuthRepository repository;
  late SessionCubit cubit;

  setUp(() {
    repository = FakeAuthRepository();
    cubit = SessionCubit(
      checkSessionUseCase: CheckSessionUseCase(repository),
      observeAuthStateUseCase: ObserveAuthStateUseCase(repository),
      logoutUseCase: LogoutUseCase(repository),
    );
  });

  tearDown(() async {
    await cubit.close();
    await repository.close();
  });

  test('cold start without session becomes unauthenticated', () async {
    await cubit.start();

    expect(cubit.state, const SessionUnauthenticated());
    expect(repository.currentUserCalls, 1);
  });

  test(
    'cold start with persisted provider session becomes authenticated',
    () async {
      repository.currentUserResult = const Right(testUser);

      await cubit.start();

      expect(cubit.state, const SessionAuthenticated(testUser));
    },
  );

  test('observes login and logout transitions', () async {
    await cubit.start();

    repository.authStateController.add(const Right(testUser));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state, const SessionAuthenticated(testUser));

    repository.authStateController.add(const Right(null));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state, const SessionUnauthenticated());
  });

  test('logout calls use case and becomes unauthenticated', () async {
    repository.currentUserResult = const Right(testUser);
    await cubit.start();

    await cubit.logout();

    expect(repository.logoutCalls, 1);
    expect(cubit.state, const SessionUnauthenticated());
  });

  test('logout failure retains authenticated identity', () async {
    repository.currentUserResult = const Right(testUser);
    repository.logoutResult = const Left(
      AuthenticationFailure(AuthErrorCode.network),
    );
    await cubit.start();

    await cubit.logout();

    final state = cubit.state as SessionFailure;
    expect(state.errorCode, AuthErrorCode.network);
    expect(state.user, testUser);
    expect(state.isAuthenticated, isTrue);
  });

  test('close cancels authentication state subscription', () async {
    await cubit.start();
    expect(repository.authStateController.hasListener, isTrue);

    await cubit.close();

    expect(repository.authStateController.hasListener, isFalse);
  });
}
