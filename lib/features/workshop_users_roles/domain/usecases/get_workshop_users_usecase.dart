import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/use_cases/use_case.dart';
import '../entities/workshop_user_entity.dart';
import '../repositories/workshop_users_roles_repository.dart';

class GetWorkshopUsersUseCase
    implements UseCase<List<WorkshopUserEntity>, NoParam> {
  final WorkshopUsersRolesRepository repository;

  GetWorkshopUsersUseCase(this.repository);

  @override
  Future<Either<Failure, List<WorkshopUserEntity>>> call(
      [NoParam? param]) async {
    return repository.getWorkshopUsers();
  }
}
