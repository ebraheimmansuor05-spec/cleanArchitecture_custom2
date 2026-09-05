import 'package:dartz/dartz.dart';
import 'package:flutter_clean_architecture_template/features/authentication/domain/entities/auth_failure.dart';
import 'package:flutter_clean_architecture_template/features/authentication/domain/enums/account_type.dart';
import 'package:flutter_clean_architecture_template/features/authentication/domain/params/auth_credentials.dart';
import 'package:flutter_clean_architecture_template/features/authentication/domain/usecases/auth_use_cases.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  late FakeAuthRepository repository;

  setUp(() => repository = FakeAuthRepository());
  tearDown(() => repository.close());

  test('LoginUseCase validates before calling repository', () async {
    final result = await LoginUseCase(repository)(
      const LoginCredentials(email: '', password: ''),
    );

    expect(result.isLeft(), isTrue);
    expect(
      result.fold((failure) => failure, (_) => null),
      isA<AuthValidationFailure>(),
    );
    expect(repository.loginCalls, 0);
  });

  test('LoginUseCase delegates valid credentials', () async {
    final result = await LoginUseCase(repository)(
      const LoginCredentials(
        email: 'owner@kitchenflow.test',
        password: 'password',
      ),
    );

    expect(result, const Right(testUser));
    expect(repository.loginCalls, 1);
  });

  test('RegisterUseCase stops at identity registration boundary', () async {
    final result = await RegisterUseCase(repository)(
      const RegistrationCredentials(
        email: 'owner@kitchenflow.test',
        password: 'password',
        confirmPassword: 'password',
        workshopName: 'Test Workshop',
        accountType: AccountType.owner,
      ),
    );

    expect(result, const Right(testUser));
    expect(repository.registerCalls, 1);
  });

  test('password reset validates email before provider call', () async {
    final result = await SendPasswordResetUseCase(repository)('invalid');

    expect(result.isLeft(), isTrue);
    expect(repository.resetCalls, 0);
  });

  test('logout, check session, and current user delegate cleanly', () async {
    repository.currentUserResult = const Right(testUser);

    expect(await LogoutUseCase(repository)(), const Right(unit));
    expect(await CheckSessionUseCase(repository)(), const Right(testUser));
    expect(await GetCurrentUserUseCase(repository)(), const Right(testUser));
    expect(repository.logoutCalls, 1);
    expect(repository.currentUserCalls, 2);
  });

  test('ObserveAuthStateUseCase exposes provider-independent stream', () async {
    final expectation = expectLater(
      ObserveAuthStateUseCase(repository)(),
      emits(const Right(testUser)),
    );

    repository.authStateController.add(const Right(testUser));
    await expectation;
  });
}
