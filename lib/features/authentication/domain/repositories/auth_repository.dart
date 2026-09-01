import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/auth_user_entity.dart';
import '../params/auth_credentials.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthUserEntity>> login(LoginCredentials credentials);

  Future<Either<Failure, AuthUserEntity>> register(
    RegistrationCredentials credentials,
  );

  Future<Either<Failure, Unit>> sendPasswordResetEmail(String email);

  Future<Either<Failure, Unit>> logout();

  Future<Either<Failure, AuthUserEntity?>> getCurrentUser();

  Stream<Either<Failure, AuthUserEntity?>> observeAuthState();
}
