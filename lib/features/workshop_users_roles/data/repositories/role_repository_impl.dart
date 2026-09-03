import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/safe_call.dart';
import '../../domain/entities/role_entity.dart';
import '../../domain/repositories/role_repository.dart';
import '../datasources/workshop_users_roles_remote_data_source.dart';
import '../models/role_model.dart';

class RoleRepositoryImpl implements RoleRepository {
  final WorkshopUsersRolesRemoteDataSource remoteDataSource;

  RoleRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<RoleEntity>>> getRoles(
    String workshopId,
  ) {
    return safeCall(
      () => remoteDataSource.fetchRoles(workshopId),
    );
  }

  @override
  Future<Either<Failure, RoleEntity>> createRole(
    RoleEntity role,
  ) {
    return safeCall(
      () => remoteDataSource.createRole(
        RoleModel(
          id: role.id,
          workshopId: role.workshopId,
          name: role.name,
          description: role.description,
          permissions: role.permissions,
          isSystemRole: role.isSystemRole,
          createdAt: role.createdAt,
          updatedAt: role.updatedAt,
        ),
      ),
    );
  }

  @override
  Future<Either<Failure, RoleEntity>> updateRole(
    RoleEntity role,
  ) {
    return safeCall(
      () => remoteDataSource.updateRole(
        RoleModel(
          id: role.id,
          workshopId: role.workshopId,
          name: role.name,
          description: role.description,
          permissions: role.permissions,
          isSystemRole: role.isSystemRole,
          createdAt: role.createdAt,
          updatedAt: role.updatedAt,
        ),
      ),
    );
  }

  @override
  Future<Either<Failure, void>> deleteRole(
    String workshopId,
    String roleId,
  ) {
    return safeCall(
      () => remoteDataSource.deleteRole(
        workshopId,
        roleId,
      ),
    );
  }
}