import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/role_entity.dart';

abstract class RoleRepository {
  Future<Either<Failure, List<RoleEntity>>> getRoles(
    String workshopId,
  );

  Future<Either<Failure, RoleEntity>> createRole(
    RoleEntity role,
  );

  Future<Either<Failure, RoleEntity>> updateRole(
    RoleEntity role,
  );

  Future<Either<Failure, void>> deleteRole(
    String workshopId,
    String roleId,
  );
}