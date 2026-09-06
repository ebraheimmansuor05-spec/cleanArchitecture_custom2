import 'dart:async';

import 'package:dartz/dartz.dart';

import 'package:flutter_clean_architecture_template/core/errors/failures.dart';
import 'package:flutter_clean_architecture_template/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_clean_architecture_template/features/authentication/data/models/auth_user_model.dart';
import 'package:flutter_clean_architecture_template/features/authentication/domain/entities/auth_user_entity.dart';
import 'package:flutter_clean_architecture_template/features/authentication/domain/params/auth_credentials.dart';
import 'package:flutter_clean_architecture_template/features/authentication/domain/repositories/auth_repository.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/domain/entities/workshop_entity.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/domain/entities/workshop_user_entity.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/domain/repositories/workshop_repository.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/domain/repositories/workshop_users_roles_repository.dart';

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

class FakeWorkshopRepository implements WorkshopRepository {
  Either<Failure, WorkshopEntity> createWorkshopResult = Right(
    WorkshopEntity(
      id: 'workshop-1',
      ownerId: 'user-1',
      name: 'Test Workshop',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
  );

  Either<Failure, WorkshopEntity> getWorkshopResult = Right(
    WorkshopEntity(
      id: 'workshop-1',
      ownerId: 'user-1',
      name: 'Test Workshop',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
  );

  Either<Failure, WorkshopEntity> getWorkshopByOwnerIdResult = Right(
    WorkshopEntity(
      id: 'workshop-1',
      ownerId: 'user-1',
      name: 'Test Workshop',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
  );

  int createWorkshopCalls = 0;
  int getWorkshopCalls = 0;
  int getWorkshopByOwnerIdCalls = 0;

  WorkshopEntity? lastCreatedWorkshop;
  String? lastWorkshopId;
  String? lastOwnerId;

  @override
  Future<Either<Failure, WorkshopEntity>> createWorkshop(
    WorkshopEntity workshop,
  ) async {
    createWorkshopCalls++;
    lastCreatedWorkshop = workshop;
    return createWorkshopResult;
  }

  @override
  Future<Either<Failure, WorkshopEntity>> getWorkshop(
    String workshopId,
  ) async {
    getWorkshopCalls++;
    lastWorkshopId = workshopId;
    return getWorkshopResult;
  }

  @override
  Future<Either<Failure, WorkshopEntity>> getWorkshopByOwnerId(
    String ownerId,
  ) async {
    getWorkshopByOwnerIdCalls++;
    lastOwnerId = ownerId;
    return getWorkshopByOwnerIdResult;
  }
}

class FakeWorkshopUsersRolesRepository
    implements WorkshopUsersRolesRepository {
  Either<Failure, List<WorkshopUserEntity>> getWorkshopUsersResult =
      const Right([]);

  Either<Failure, WorkshopUserEntity?> getWorkshopUserByUserIdResult =
      const Right(null);

  late Either<Failure, WorkshopUserEntity> createWorkshopUserResult;

  int getWorkshopUsersCalls = 0;
  int createWorkshopUserCalls = 0;
  int getWorkshopUserByUserIdCalls = 0;

  String? lastWorkshopId;
  String? lastUserId;
  WorkshopUserEntity? lastCreatedWorkshopUser;
  String? lastWorkerId;

  @override
  Future<Either<Failure, List<WorkshopUserEntity>>> getWorkshopUsers(
    String workshopId,
  ) async {
    getWorkshopUsersCalls++;
    lastWorkshopId = workshopId;
    return getWorkshopUsersResult;
  }

  @override
  Future<Either<Failure, WorkshopUserEntity>> createWorkshopUser(
    WorkshopUserEntity entity, {
    required String workerId,
  }) async {
    createWorkshopUserCalls++;
    lastCreatedWorkshopUser = entity;
    lastWorkerId = workerId;
    return createWorkshopUserResult;
  }

  @override
  Future<Either<Failure, WorkshopUserEntity?>> getWorkshopUserByUserId(
    String userId,
  ) async {
    getWorkshopUserByUserIdCalls++;
    lastUserId = userId;
    return getWorkshopUserByUserIdResult;
  }
}

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
  Future<Either<Failure, Unit>> sendPasswordResetEmail(
    String email,
  ) async {
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

  @override
  Future<Either<Failure, AuthUserEntity>> registerWorker({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return const Right(testUser);
  }

  @override
  Future<Either<Failure, Unit>> deleteUser(String userId) async {
    return const Right(unit);
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

  final authStateController =
      StreamController<AuthUserModel?>.broadcast();

  @override
  Future<AuthUserModel> login({
    required String email,
    required String password,
  }) async {
    if (loginError case final error?) {
      throw error;
    }

    return loginUser;
  }

  @override
  Future<AuthUserModel> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (registerError case final error?) {
      throw error;
    }

    return registerUser;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    if (resetError case final error?) {
      throw error;
    }
  }

  @override
  Future<void> logout() async {
    if (logoutError case final error?) {
      throw error;
    }
  }

  @override
  Future<AuthUserModel?> getCurrentUser() async {
    if (currentUserError case final error?) {
      throw error;
    }

    return currentUser;
  }

  @override
  Stream<AuthUserModel?> observeAuthState() {
    return authStateController.stream;
  }

  @override
  Future<AuthUserModel> createUserWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return registerUser;
  }

  @override
  Future<void> deleteUser(String userId) async {}

  Future<void> close() => authStateController.close();
}