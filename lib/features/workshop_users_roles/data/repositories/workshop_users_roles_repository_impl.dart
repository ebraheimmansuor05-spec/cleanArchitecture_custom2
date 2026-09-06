import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/worker_creation_result_entity.dart';
import '../../domain/entities/workshop_user_entity.dart';
import '../../domain/enums/workshop_member_status.dart';
import '../../domain/repositories/workshop_users_roles_repository.dart';
import '../datasources/workshop_users_roles_remote_data_source.dart';
import '../models/workshop_user_model.dart';

class WorkshopUsersRolesRepositoryImpl
    implements WorkshopUsersRolesRepository {
  final WorkshopUsersRolesRemoteDataSource _remoteDataSource;

  const WorkshopUsersRolesRepositoryImpl(
    this._remoteDataSource,
  );

  @override
  Future<Either<Failure, List<WorkshopUserEntity>>>
      getWorkshopUsers(
    String workshopId,
  ) async {
    try {
      final models =
          await _remoteDataSource.getWorkshopUsers(
        workshopId,
      );

      return Right(
        models
            .map((model) => model.toEntity())
            .toList(),
      );
    } catch (e) {
      return Left(
        AuthFailure(e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, WorkshopUserEntity>>
      createWorkshopUser(
    WorkshopUserEntity entity, {
    required String workerId,
  }) async {
    try {
      if (entity.userId.trim().isEmpty) {
        return Left(
          AuthFailure(
            'Cannot create workshop membership without a user id.',
          ),
        );
      }

      final model = WorkshopUserModel(
        id: entity.id,
        workshopId: entity.workshopId,
        userId: entity.userId,
        roleId: entity.roleId,
        status: entity.status,
        joinedAt: entity.joinedAt,
        workerId: workerId,
      );

      final created =
          await _remoteDataSource.createWorkshopUser(
        model,
        workerId: workerId,
      );

      return Right(
        created.toEntity(),
      );
    } catch (e) {
      return Left(
        AuthFailure(e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, WorkshopUserEntity?>>
      getWorkshopUserByUserId(
    String userId,
  ) async {
    try {
      final model =
          await _remoteDataSource.getWorkshopUserByUserId(
        userId,
      );

      return Right(
        model?.toEntity(),
      );
    } catch (e) {
      return Left(
        AuthFailure(e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, WorkshopUserEntity>>
      updateWorkshopUserStatus({
    required String workshopUserId,
    required WorkshopMemberStatus status,
  }) async {
    try {
      final model =
          await _remoteDataSource.updateWorkshopUserStatus(
        workshopUserId: workshopUserId,
        status: status,
      );

      return Right(
        model.toEntity(),
      );
    } catch (e) {
      return Left(
        AuthFailure(e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, WorkerCreationResultEntity>>
      createWorker({
    required String displayName,
    required String phone,
    required String password,
    required String roleId,
    required String workshopId,
  }) async {
    try {
      final model =
          await _remoteDataSource.createWorker(
        displayName: displayName,
        phone: phone,
        password: password,
        roleId: roleId,
        workshopId: workshopId,
      );

      return Right(
        model.toEntity(),
      );
    } catch (e) {
      return Left(
        AuthFailure(e.toString()),
      );
    }
  }
}