// lib/features/authentication/data/repositories/auth_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/auth_failure.dart';
import '../../domain/entities/auth_user_entity.dart';
import '../../domain/params/auth_credentials.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  const AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, AuthUserEntity>> login(
    LoginCredentials credentials,
  ) async {
    try {
      final user = await _remoteDataSource.login(
        email: credentials.email,
        password: credentials.password,
      );
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseException(e));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthUserEntity>> register(
    RegistrationCredentials credentials,
  ) async {
    try {
      final user = await _remoteDataSource.register(
        email: credentials.email,
        password: credentials.password,
        displayName: credentials.email.split('@').first,
      );
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseException(e));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendPasswordResetEmail(String email) async {
    try {
      await _remoteDataSource.sendPasswordResetEmail(email);
      return const Right(unit);
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseException(e));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _remoteDataSource.logout();
      return const Right(unit);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthUserEntity?>> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, AuthUserEntity?>> observeAuthState() {
    try {
      return _remoteDataSource.observeAuthState().map((user) => Right(user));
    } catch (e) {
      return Stream.value(Left(AuthFailure(e.toString())));
    }
  }

  @override
  Future<Either<Failure, AuthUserEntity>> registerWorker({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final user = await _remoteDataSource.createUserWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseException(e));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteUser(String userId) async {
    try {
      await _remoteDataSource.deleteUser(userId);
      return const Right(unit);
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseException(e));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  Failure _mapFirebaseException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthenticationFailure(
          AuthErrorCode.userNotFound,
          e.message ?? 'المستخدم غير موجود',
        );
      case 'wrong-password':
        return AuthenticationFailure(
          AuthErrorCode.wrongPassword,
          e.message ?? 'كلمة المرور غير صحيحة',
        );
      case 'email-already-in-use':
        return AuthenticationFailure(
          AuthErrorCode.emailAlreadyInUse,
          e.message ?? 'البريد الإلكتروني مستخدم مسبقاً',
        );
      case 'invalid-email':
        return AuthenticationFailure(
          AuthErrorCode.invalidEmail,
          e.message ?? 'البريد الإلكتروني غير صحيح',
        );
      case 'too-many-requests':
        return AuthenticationFailure(
          AuthErrorCode.tooManyRequests,
          e.message ?? 'محاولات كثيرة، حاول لاحقاً',
        );
      case 'weak-password':
        return AuthenticationFailure(
          AuthErrorCode.weakPassword,
          e.message ?? 'كلمة المرور ضعيفة',
        );
      case 'user-disabled':
        return AuthenticationFailure(
          AuthErrorCode.userDisabled,
          e.message ?? 'الحساب معطل',
        );
      default:
        return AuthFailure(e.message ?? e.code);
    }
  }
}