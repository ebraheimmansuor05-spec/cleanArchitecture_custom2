// lib/features/workshop_users_roles/data/repositories/role_repository_impl.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/role_entity.dart';
import '../../domain/repositories/role_repository.dart';
import '../datasources/workshop_users_roles_remote_data_source.dart';

class RoleRepositoryImpl implements RoleRepository {
  final WorkshopUsersRolesRemoteDataSource _remoteDataSource;

  const RoleRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<RoleEntity>>> getRoles(String workshopId) async {
    try {
      final models = await _remoteDataSource.getRoles(workshopId);
      return Right(models);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RoleEntity>> createRole(RoleEntity role) async {
    try {
      return Left(AuthFailure('Create role not implemented yet'));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RoleEntity>> updateRole(RoleEntity role) async {
    try {
      return Left(AuthFailure('Update role not implemented yet'));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRole(
    String workshopId,
    String roleId,
  ) async {
    try {
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}