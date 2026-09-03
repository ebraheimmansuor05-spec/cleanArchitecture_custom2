import '../entities/workshop_user_entity.dart';
import '../repositories/workshop_users_roles_repository.dart';

class GetWorkshopUsersUseCase {
  final WorkshopUsersRolesRepository repository;

  GetWorkshopUsersUseCase(this.repository);

  Future<List<WorkshopUserEntity>> call(String workshopId) {
    return repository.fetchWorkshopUsers(workshopId);
  }
}