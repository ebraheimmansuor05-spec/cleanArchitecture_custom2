import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/auth_failure.dart';
import '../../domain/entities/auth_user_entity.dart';
import '../../domain/params/auth_credentials.dart';
import '../../domain/usecases/auth_use_cases.dart';
import 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final SendPasswordResetUseCase sendPasswordResetUseCase;

  AuthenticationCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.sendPasswordResetUseCase,
  }) : super(const AuthenticationInitial());

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
  }) async {
    if (state is AuthenticationLoading) return;
    const action = AuthenticationAction.register;
    emit(const AuthenticationLoading(action));
    final result = await registerUseCase(
      RegistrationCredentials(
        email: email.trim(),
        password: password,
        confirmPassword: confirmPassword,
      ),
    );
    _emitResult(action, result);
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
      emit(const AuthenticationInitial());
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
