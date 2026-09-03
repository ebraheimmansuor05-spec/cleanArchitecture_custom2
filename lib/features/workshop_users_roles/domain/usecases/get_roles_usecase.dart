import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/role_entity.dart';
import '../repositories/role_repository.dart';

class GetRolesUseCase {
  final RoleRepository _repository;

  const GetRolesUseCase(this._repository);

  Future<Either<Failure, List<RoleEntity>>> call(
    String workshopId,
  ) {
    return _repository.getRoles(workshopId);
  }
}