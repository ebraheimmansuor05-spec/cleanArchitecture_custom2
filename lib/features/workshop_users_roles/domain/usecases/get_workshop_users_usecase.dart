// lib/features/workshop_users_roles/domain/usecases/get_workshop_users_usecase.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/workshop_user_entity.dart';
import '../repositories/workshop_users_roles_repository.dart';

class GetWorkshopUsersUseCase {
  final WorkshopUsersRolesRepository _repository;

  const GetWorkshopUsersUseCase(this._repository);

  Future<Either<Failure, List<WorkshopUserEntity>>> call(
    String workshopId,
  ) async {
    return _repository.getWorkshopUsers(workshopId);
  }
}