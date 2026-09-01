import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_clean_architecture_template/core/errors/failures.dart';
import 'package:flutter_clean_architecture_template/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_clean_architecture_template/features/authentication/data/models/auth_user_model.dart';
import 'package:flutter_clean_architecture_template/features/authentication/domain/entities/auth_user_entity.dart';
import 'package:flutter_clean_architecture_template/features/authentication/domain/params/auth_credentials.dart';
import 'package:flutter_clean_architecture_template/features/authentication/domain/repositories/auth_repository.dart';

const testUser = AuthUserEntity(
  id: 'user-1',
  email: 'owner@kitchenflow.test',
  displayName: null,
  isEmailVerified: true,
);

const testUserModel = AuthUserModel(
  id: 'user-1',
  email: 'owner@kitchenflow.test',
  displayName: null,
  isEmailVerified: true,
);

class FakeAuthRepository implements AuthRepository {
  Either<Failure, AuthUserEntity> loginResult = const Right(testUser);
  Either<Failure, AuthUserEntity> registerResult = const Right(testUser);
  Either<Failure, Unit> resetResult = const Right(unit);
  Either<Failure, Unit> logoutResult = const Right(unit);
  Either<Failure, AuthUserEntity?> currentUserResult = const Right(null);
  final authStateController =
      StreamController<Either<Failure, AuthUserEntity?>>.broadcast();

  int loginCalls = 0;
  int registerCalls = 0;
  int resetCalls = 0;
  int logoutCalls = 0;
  int currentUserCalls = 0;

  LoginCredentials? lastLoginCredentials;
  RegistrationCredentials? lastRegistrationCredentials;
  String? lastResetEmail;

  @override
  Future<Either<Failure, AuthUserEntity>> login(
    LoginCredentials credentials,
  ) async {
    loginCalls++;
    lastLoginCredentials = credentials;
    return loginResult;
  }

  @override
  Future<Either<Failure, AuthUserEntity>> register(
    RegistrationCredentials credentials,
  ) async {
    registerCalls++;
    lastRegistrationCredentials = credentials;
    return registerResult;
  }

  @override
  Future<Either<Failure, Unit>> sendPasswordResetEmail(String email) async {
    resetCalls++;
    lastResetEmail = email;
    return resetResult;
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    logoutCalls++;
    return logoutResult;
  }

  @override
  Future<Either<Failure, AuthUserEntity?>> getCurrentUser() async {
    currentUserCalls++;
    return currentUserResult;
  }

  @override
  Stream<Either<Failure, AuthUserEntity?>> observeAuthState() {
    return authStateController.stream;
  }

  Future<void> close() => authStateController.close();
}

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  Object? loginError;
  Object? registerError;
  Object? resetError;
  Object? logoutError;
  Object? currentUserError;

  AuthUserModel loginUser = testUserModel;
  AuthUserModel registerUser = testUserModel;
  AuthUserModel? currentUser;
  final authStateController = StreamController<AuthUserModel?>.broadcast();

  @override
  Future<AuthUserModel> login({
    required String email,
    required String password,
  }) async {
    if (loginError case final error?) throw error;
    return loginUser;
  }

  @override
  Future<AuthUserModel> register({
    required String email,
    required String password,
  }) async {
    if (registerError case final error?) throw error;
    return registerUser;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    if (resetError case final error?) throw error;
  }

  @override
  Future<void> logout() async {
    if (logoutError case final error?) throw error;
  }

  @override
  AuthUserModel? getCurrentUser() {
    if (currentUserError case final error?) throw error;
    return currentUser;
  }

  @override
  Stream<AuthUserModel?> observeAuthState() => authStateController.stream;

  Future<void> close() => authStateController.close();
}
