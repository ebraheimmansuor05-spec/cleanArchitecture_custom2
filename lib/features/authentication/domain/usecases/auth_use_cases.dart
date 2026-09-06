import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/auth_failure.dart';
import '../entities/auth_user_entity.dart';
import '../params/auth_credentials.dart';
import '../repositories/auth_repository.dart';
import '../validators/auth_validator.dart';

class LoginUseCase {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  Future<Either<Failure, AuthUserEntity>> call(LoginCredentials credentials) {
    final errors = AuthValidator.validateLogin(credentials);
    if (errors.isNotEmpty) {
      return Future.value(Left(AuthValidationFailure(errors)));
    }
    return repository.login(credentials);
  }
}

class RegisterUseCase {
  final AuthRepository repository;

  const RegisterUseCase(this.repository);

  Future<Either<Failure, AuthUserEntity>> call(
    RegistrationCredentials credentials,
  ) {
    final errors = AuthValidator.validateRegistration(credentials);
    if (errors.isNotEmpty) {
      return Future.value(Left(AuthValidationFailure(errors)));
    }
    return repository.register(credentials);
  }
}

class SendPasswordResetUseCase {
  final AuthRepository repository;

  const SendPasswordResetUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String email) {
    final errors = AuthValidator.validateRecoveryEmail(email);
    if (errors.isNotEmpty) {
      return Future.value(Left(AuthValidationFailure(errors)));
    }
    return repository.sendPasswordResetEmail(email);
  }
}

class LogoutUseCase {
  final AuthRepository repository;

  const LogoutUseCase(this.repository);

  Future<Either<Failure, Unit>> call() => repository.logout();
}

class CheckSessionUseCase {
  final AuthRepository repository;

  const CheckSessionUseCase(this.repository);

  Future<Either<Failure, AuthUserEntity?>> call() =>
      repository.getCurrentUser();
}

class GetCurrentUserUseCase {
  final AuthRepository repository;

  const GetCurrentUserUseCase(this.repository);

  Future<Either<Failure, AuthUserEntity?>> call() =>
      repository.getCurrentUser();
}

class ObserveAuthStateUseCase {
  final AuthRepository repository;

  const ObserveAuthStateUseCase(this.repository);

  Stream<Either<Failure, AuthUserEntity?>> call() =>
      repository.observeAuthState();
}
