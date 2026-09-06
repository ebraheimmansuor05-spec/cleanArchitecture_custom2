import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/role_entity.dart';
import '../../domain/repositories/role_repository.dart';
import '../datasources/workshop_users_roles_remote_data_source.dart';
import '../models/role_model.dart';

class RoleRepositoryImpl implements RoleRepository {
  final WorkshopUsersRolesRemoteDataSource _remoteDataSource;

  const RoleRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<RoleEntity>>> getRoles(
    String workshopId,
  ) async {
    try {
      final models = await _remoteDataSource.getRoles(
        workshopId,
      );

      return Right(
        models
            .map(_mapModelToEntity)
            .toList(),
      );
    } catch (e) {
      return Left(
        AuthFailure(
          e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, RoleEntity>> createRole(
    RoleEntity role,
  ) async {
    try {
      final model = RoleModel(
        id: role.id,
        workshopId: role.workshopId,
        name: role.name,
        description: role.description,
        permissions: role.permissions,
        isSystemRole: role.isSystemRole,
        createdAt: role.createdAt,
        updatedAt: role.updatedAt,
      );

      final createdModel = await _remoteDataSource.createRole(
        model,
      );

      return Right(
        _mapModelToEntity(createdModel),
      );
    } catch (e) {
      return Left(
        AuthFailure(
          e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, RoleEntity>> updateRole(
    RoleEntity role,
  ) async {
    try {
      final model = RoleModel(
        id: role.id,
        workshopId: role.workshopId,
        name: role.name,
        description: role.description,
        permissions: role.permissions,
        isSystemRole: role.isSystemRole,
        createdAt: role.createdAt,
        updatedAt: role.updatedAt,
      );

      final updatedModel = await _remoteDataSource.updateRole(
        model,
      );

      return Right(
        _mapModelToEntity(updatedModel),
      );
    } catch (e) {
      return Left(
        AuthFailure(
          e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteRole(
    String workshopId,
    String roleId,
  ) async {
    try {
      await _remoteDataSource.deleteRole(
        workshopId,
        roleId,
      );

      return const Right(null);
    } catch (e) {
      return Left(
        AuthFailure(
          e.toString(),
        ),
      );
    }
  }

  RoleEntity _mapModelToEntity(
    RoleModel model,
  ) {
    return RoleEntity(
      id: model.id,
      workshopId: model.workshopId,
      name: model.name,
      description: model.description,
      permissions: model.permissions,
      isSystemRole: model.isSystemRole,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
}