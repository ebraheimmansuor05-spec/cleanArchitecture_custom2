import '../../domain/entities/role_entity.dart';
import '../../domain/entities/workshop_entity.dart';
import '../../domain/entities/workshop_user_entity.dart';
import '../../domain/repositories/workshop_users_roles_repository.dart';
import '../datasources/workshop_users_roles_remote_data_source.dart';
import '../models/role_model.dart';
import '../models/workshop_model.dart';

class WorkshopUsersRolesRepositoryImpl
    implements WorkshopUsersRolesRepository {
  final WorkshopUsersRolesRemoteDataSource _remoteDataSource;

  WorkshopUsersRolesRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<WorkshopUserEntity>> fetchWorkshopUsers(
    String workshopId,
  ) async {
    final models = await _remoteDataSource.fetchWorkshopUsers(
      workshopId,
    );

    return models;
  }

  @override
  Future<List<RoleEntity>> fetchRoles(
    String workshopId,
  ) async {
    final models = await _remoteDataSource.fetchRoles(
      workshopId,
    );

    return models;
  }

  @override
  Future<RoleEntity> createRole(
    RoleEntity role,
  ) async {
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

    return _remoteDataSource.createRole(model);
  }

  @override
  Future<RoleEntity> updateRole(
    RoleEntity role,
  ) async {
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

    return _remoteDataSource.updateRole(model);
  }

  @override
  Future<void> deleteRole(
    String workshopId,
    String roleId,
  ) {
    return _remoteDataSource.deleteRole(
      workshopId,
      roleId,
    );
  }

  @override
  Future<WorkshopEntity> createWorkshop(
    WorkshopEntity workshop,
  ) async {
    final model = WorkshopModel(
      id: workshop.id,
      ownerId: workshop.ownerId,
      name: workshop.name,
      createdAt: workshop.createdAt,
      updatedAt: workshop.updatedAt,
    );

    return _remoteDataSource.createWorkshop(model);
  }

  @override
  Future<WorkshopEntity> getWorkshop(
    String workshopId,
  ) {
    return _remoteDataSource.getWorkshop(workshopId);
  }
}