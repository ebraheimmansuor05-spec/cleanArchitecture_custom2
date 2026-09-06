import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/worker_creation_result_entity.dart';
import '../entities/workshop_user_entity.dart';

abstract class WorkshopUsersRolesRepository {
  Future<Either<Failure, List<WorkshopUserEntity>>> getWorkshopUsers(
    String workshopId,
  );

  Future<Either<Failure, WorkshopUserEntity>> createWorkshopUser(
    WorkshopUserEntity entity, {
    required String workerId,
  });

  Future<Either<Failure, WorkshopUserEntity?>> getWorkshopUserByUserId(
    String userId,
  );

  Future<Either<Failure, WorkerCreationResultEntity>> createWorker({
    required String displayName,
    required String phone,
    required String password,
    required String roleId,
    required String workshopId,
  });
}