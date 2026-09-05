// lib/features/authentication/presentation/manager/authentication_cubit.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../workshop_users_roles/domain/entities/workshop_entity.dart';
import '../../../workshop_users_roles/domain/usecases/create_workshop_usecase.dart';
import '../../domain/entities/auth_failure.dart';
import '../../domain/entities/auth_user_entity.dart';
import '../../domain/params/auth_credentials.dart';
import '../../domain/usecases/auth_use_cases.dart';
import '../../domain/usecases/worker_login_usecase.dart';
import 'authentication_state.dart';
import '../../domain/enums/account_type.dart';

enum AuthenticationAction {
  login,
  register,
  passwordReset,
  workerLogin,
}

class AuthenticationCubit extends Cubit<AuthenticationState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final SendPasswordResetUseCase sendPasswordResetUseCase;
  final CreateWorkshopUseCase createWorkshopUseCase;
  final WorkerLoginUseCase workerLoginUseCase;

  AuthenticationCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.sendPasswordResetUseCase,
    required this.createWorkshopUseCase,
    required this.workerLoginUseCase,
  }) : super( AuthenticationInitial());

  Future<void> login({required String email, required String password}) async {
    if (state is AuthenticationLoading) return;

    const action = AuthenticationAction.login;
    emit(const AuthenticationLoading(action));

    final result = await loginUseCase(
      LoginCredentials(email: email.trim(), password: password),
    );
    _emitResult(action, result);
  }

  Future<void> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String workshopName,
    required AccountType accountType,
  }) async {
    if (state is AuthenticationLoading) return;

    const action = AuthenticationAction.register;
    emit(const AuthenticationLoading(action));

    final registrationResult = await registerUseCase(
      RegistrationCredentials(
        email: email.trim(),
        password: password,
        confirmPassword: confirmPassword,
        workshopName: workshopName.trim(),
        accountType: accountType,
      ),
    );

    if (isClosed) return;

    await registrationResult.fold(
      (failure) async {
        emit(_failureState(action, failure));
      },
      (user) async {
        if (accountType == AccountType.worker) {
          emit(AuthenticationSuccess(action, user: user));
          return;
        }
        final workshopResult = await createWorkshopUseCase(
          WorkshopEntity(
            id: '',
            ownerId: user.id,
            name: workshopName.trim(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        if (isClosed) return;

        workshopResult.fold(
          (failure) {
            emit(_failureState(action, failure));
          },
          (_) {
            emit(AuthenticationSuccess(action, user: user));
          },
        );
      },
    );
  }

  Future<void> workerLogin({
    required String email,
    required String password,
  }) async {
    if (state is AuthenticationLoading) return;

    const action = AuthenticationAction.workerLogin;
    emit(const AuthenticationLoading(action));

    final result = await workerLoginUseCase(
      email: email.trim(),
      password: password,
    );

    if (isClosed) return;

    result.fold(
      (failure) => emit(_failureState(action, failure)),
      (user) => emit(AuthenticationSuccess(action, user: user)),
    );
  }

  Future<void> sendPasswordResetEmail(String email) async {
    if (state is AuthenticationLoading) return;

    const action = AuthenticationAction.passwordReset;
    emit(const AuthenticationLoading(action));

    final result = await sendPasswordResetUseCase(email.trim());

    if (isClosed) return;

    result.fold(
      (failure) => emit(_failureState(action, failure)),
      (_) => emit(const AuthenticationSuccess(action)),
    );
  }

  void reset() {
    if (!isClosed && state is! AuthenticationLoading) {
      emit( AuthenticationInitial());
    }
  }

  void _emitResult(
    AuthenticationAction action,
    Either<Failure, AuthUserEntity> result,
  ) {
    if (isClosed) return;

    result.fold(
      (failure) => emit(_failureState(action, failure)),
      (user) => emit(AuthenticationSuccess(action, user: user)),
    );
  }

  AuthenticationFailureState _failureState(
    AuthenticationAction action,
    Failure failure,
  ) {
    if (failure is AuthValidationFailure) {
      return AuthenticationFailureState(
        action: action,
        errorCode: AuthErrorCode.unknown,
        fieldErrors: failure.errors,
      );
    }

    if (failure is AuthenticationFailure) {
      return AuthenticationFailureState(
        action: action,
        errorCode: failure.code,
      );
    }

    return AuthenticationFailureState(
      action: action,
      errorCode: AuthErrorCode.unknown,
    );
  }
}