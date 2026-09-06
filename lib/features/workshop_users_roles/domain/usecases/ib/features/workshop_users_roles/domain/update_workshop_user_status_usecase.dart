import 'package:dartz/dartz.dart';

import '../../../../../../../../core/errors/failures.dart';
import '../../../../../entities/workshop_user_entity.dart';
import '../../../../../enums/workshop_member_status.dart';
import '../../../../../repositories/workshop_users_roles_repository.dart';

class UpdateWorkshopUserStatusUseCase {
  final WorkshopUsersRolesRepository _repository;

  const UpdateWorkshopUserStatusUseCase(this._repository);

  Future<Either<Failure, WorkshopUserEntity>> call({
    required String workshopUserId,
    required WorkshopMemberStatus status,
  }) {
    return _repository.updateWorkshopUserStatus(
      workshopUserId: workshopUserId,
      status: status,
    );
  }
}