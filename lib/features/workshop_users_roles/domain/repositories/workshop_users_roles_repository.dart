// lib/features/workshop_users_roles/domain/repositories/workshop_users_roles_repository.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
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
}