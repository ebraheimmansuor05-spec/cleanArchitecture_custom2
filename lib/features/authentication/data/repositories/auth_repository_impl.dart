import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/auth_failure.dart';
import '../../domain/entities/auth_user_entity.dart';
import '../../domain/params/auth_credentials.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  const AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, AuthUserEntity>> login(
    LoginCredentials credentials,
  ) async {
    try {
      final user = await remoteDataSource.login(
        email: credentials.email.trim(),
        password: credentials.password,
      );
      return Right(user.toEntity());
    } on FirebaseAuthException catch (error) {
      return Left(_mapFirebaseFailure(error));
    } catch (_) {
      return const Left(AuthenticationFailure(AuthErrorCode.unknown));
    }
  }

  @override
  Future<Either<Failure, AuthUserEntity>> register(
    RegistrationCredentials credentials,
  ) async {
    try {
      final user = await remoteDataSource.register(
        email: credentials.email.trim(),
        password: credentials.password,
      );
      return Right(user.toEntity());
    } on FirebaseAuthException catch (error) {
      return Left(_mapFirebaseFailure(error));
    } catch (_) {
      return const Left(AuthenticationFailure(AuthErrorCode.unknown));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendPasswordResetEmail(String email) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email.trim());
      return const Right(unit);
    } on FirebaseAuthException catch (error) {
      return Left(_mapFirebaseFailure(error));
    } catch (_) {
      return const Left(AuthenticationFailure(AuthErrorCode.unknown));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(unit);
    } on FirebaseAuthException catch (error) {
      return Left(_mapFirebaseFailure(error));
    } catch (_) {
      return const Left(AuthenticationFailure(AuthErrorCode.unknown));
    }
  }

  @override
  Future<Either<Failure, AuthUserEntity?>> getCurrentUser() async {
    try {
      return Right(remoteDataSource.getCurrentUser()?.toEntity());
    } on FirebaseAuthException catch (error) {
      return Left(_mapFirebaseFailure(error));
    } catch (_) {
      return const Left(AuthenticationFailure(AuthErrorCode.unknown));
    }
  }

  @override
  Stream<Either<Failure, AuthUserEntity?>> observeAuthState() async* {
    try {
      await for (final user in remoteDataSource.observeAuthState()) {
        yield Right(user?.toEntity());
      }
    } on FirebaseAuthException catch (error) {
      yield Left(_mapFirebaseFailure(error));
    } catch (_) {
      yield const Left(AuthenticationFailure(AuthErrorCode.unknown));
    }
  }

  AuthenticationFailure _mapFirebaseFailure(FirebaseAuthException error) {
    final code = switch (error.code) {
      'invalid-email' => AuthErrorCode.invalidEmail,
      'invalid-credential' ||
      'user-not-found' ||
      'wrong-password' => AuthErrorCode.invalidCredentials,
      'email-already-in-use' => AuthErrorCode.emailAlreadyInUse,
      'weak-password' => AuthErrorCode.weakPassword,
      'user-disabled' => AuthErrorCode.userDisabled,
      'too-many-requests' => AuthErrorCode.tooManyRequests,
      'network-request-failed' => AuthErrorCode.network,
      'operation-not-allowed' => AuthErrorCode.operationNotAllowed,
      'requires-recent-login' ||
      'user-token-expired' => AuthErrorCode.sessionExpired,
      _ => AuthErrorCode.unknown,
    };
    return AuthenticationFailure(code);
  }
}
