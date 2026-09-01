import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_clean_architecture_template/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:flutter_clean_architecture_template/features/authentication/domain/entities/auth_failure.dart';
import 'package:flutter_clean_architecture_template/features/authentication/domain/params/auth_credentials.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  late FakeAuthRemoteDataSource dataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    dataSource = FakeAuthRemoteDataSource();
    repository = AuthRepositoryImpl(dataSource);
  });

  tearDown(() => dataSource.close());

  test('maps login model to domain entity', () async {
    final result = await repository.login(
      const LoginCredentials(
        email: ' owner@kitchenflow.test ',
        password: 'password',
      ),
    );

    expect(result, const Right(testUser));
  });

  test('maps invalid credentials without leaking Firebase exception', () async {
    dataSource.loginError = FirebaseAuthException(code: 'invalid-credential');

    final result = await repository.login(
      const LoginCredentials(
        email: 'owner@kitchenflow.test',
        password: 'wrong',
      ),
    );

    final failure = result.fold((value) => value, (_) => null);
    expect(failure, isA<AuthenticationFailure>());
    expect(
      (failure as AuthenticationFailure).code,
      AuthErrorCode.invalidCredentials,
    );
  });

  test('maps registration email-in-use failure', () async {
    dataSource.registerError = FirebaseAuthException(
      code: 'email-already-in-use',
    );

    final result = await repository.register(
      const RegistrationCredentials(
        email: 'owner@kitchenflow.test',
        password: 'password',
        confirmPassword: 'password',
      ),
    );

    expect(
      (result.fold((value) => value, (_) => null) as AuthenticationFailure)
          .code,
      AuthErrorCode.emailAlreadyInUse,
    );
  });

  test('maps unknown exceptions to safe unknown failure', () async {
    dataSource.resetError = StateError('provider internals');

    final result = await repository.sendPasswordResetEmail(
      'owner@kitchenflow.test',
    );

    final failure = result.fold((value) => value, (_) => null);
    expect(failure, isA<AuthenticationFailure>());
    expect((failure as AuthenticationFailure).code, AuthErrorCode.unknown);
    expect(failure.message, isNot(contains('provider internals')));
  });

  test('supports logout and absent current user', () async {
    expect(await repository.logout(), const Right(unit));
    expect(await repository.getCurrentUser(), const Right(null));
  });

  test('maps authentication state changes to domain entities', () async {
    final expectation = expectLater(
      repository.observeAuthState(),
      emitsInOrder([const Right(testUser), const Right(null)]),
    );

    await Future<void>.delayed(Duration.zero);
    dataSource.authStateController
      ..add(testUserModel)
      ..add(null);
    await expectation;
  });
}
