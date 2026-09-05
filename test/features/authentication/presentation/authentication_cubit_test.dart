import 'package:dartz/dartz.dart';
import 'package:flutter_clean_architecture_template/features/authentication/domain/entities/auth_failure.dart';
import 'package:flutter_clean_architecture_template/features/authentication/domain/params/auth_credentials.dart';
import 'package:flutter_clean_architecture_template/features/authentication/domain/usecases/auth_use_cases.dart';
import 'package:flutter_clean_architecture_template/features/authentication/presentation/manager/authentication_cubit.dart';
import 'package:flutter_clean_architecture_template/features/authentication/presentation/manager/authentication_state.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/domain/usecases/create_workshop_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_clean_architecture_template/features/authentication/domain/enums/account_type.dart';
import '../helpers/fakes.dart';

Future<void> register({
  required String email,
  required String password,
  required String confirmPassword,
  required String workshopName,
  required AccountType accountType,
}) async {
  RegistrationCredentials(
    email: email.trim(),
    password: password,
    confirmPassword: confirmPassword,
    workshopName: workshopName.trim(),
    accountType: accountType,
  );
}

void main() {
  late FakeAuthRepository repository;
  late AuthenticationCubit cubit;

  setUp(() {
    repository = FakeAuthRepository();
    cubit = AuthenticationCubit(
      loginUseCase: LoginUseCase(repository),
      registerUseCase: RegisterUseCase(repository),
      sendPasswordResetUseCase: SendPasswordResetUseCase(repository),
      createWorkshopUseCase: CreateWorkshopUseCase(FakeWorkshopRepository()),
    );
  });

  tearDown(() async {
    await cubit.close();
    await repository.close();
  });

  test('login emits loading then success', () async {
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        const AuthenticationLoading(AuthenticationAction.login),
        const AuthenticationSuccess(AuthenticationAction.login, user: testUser),
      ]),
    );

    await cubit.login(email: 'owner@kitchenflow.test', password: 'password');
    await expectation;
  });

  test('login validation emits field failure and skips repository', () async {
    await cubit.login(email: '', password: '');

    final state = cubit.state as AuthenticationFailureState;
    expect(state.fieldErrors[AuthField.email], AuthValidationCode.required);
    expect(state.fieldErrors[AuthField.password], AuthValidationCode.required);
    expect(repository.loginCalls, 0);
  });

  test('provider failure is exposed as safe error code', () async {
    repository.loginResult = const Left(
      AuthenticationFailure(AuthErrorCode.invalidCredentials),
    );

    await cubit.login(email: 'owner@kitchenflow.test', password: 'wrong');

    final state = cubit.state as AuthenticationFailureState;
    expect(state.errorCode, AuthErrorCode.invalidCredentials);
    expect(state.fieldErrors, isEmpty);
  });

  test('registration and recovery call their use cases', () async {
    await cubit.register(
      email: 'owner@kitchenflow.test',
      password: 'password',
      confirmPassword: 'password',
     workshopName: 'KitchenFlow Workshop',
      accountType: AccountType.owner,
    );
    expect(repository.registerCalls, 1);

    cubit.reset();
    await cubit.sendPasswordResetEmail('owner@kitchenflow.test');
    expect(repository.resetCalls, 1);
    expect(
      cubit.state,
      const AuthenticationSuccess(AuthenticationAction.passwordReset),
    );
  });
}
