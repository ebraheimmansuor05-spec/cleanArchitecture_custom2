import '../entities/role_entity.dart';
import '../entities/workshop_entity.dart';
import '../entities/workshop_user_entity.dart';

abstract class WorkshopUsersRolesRepository {
  Future<List<WorkshopUserEntity>> fetchWorkshopUsers(
    String workshopId,
  );

  Future<List<RoleEntity>> fetchRoles(
    String workshopId,
  );

  Future<RoleEntity> createRole(
    RoleEntity role,
  );

  Future<RoleEntity> updateRole(
    RoleEntity role,
  );

  Future<void> deleteRole(
    String workshopId,
    String roleId,
  );

  Future<WorkshopEntity> createWorkshop(
    WorkshopEntity workshop,
  );

  Future<WorkshopEntity> getWorkshop(
    String workshopId,
  );
}