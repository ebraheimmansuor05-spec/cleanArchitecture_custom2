import '../../domain/entities/worker_creation_result_entity.dart';
import '../../domain/enums/workshop_member_status.dart';
import 'workshop_user_model.dart';

class WorkerCreationResultModel {
  final String workerLoginId;
  final String temporaryPassword;
  final WorkshopUserModel workshopUser;

  const WorkerCreationResultModel({
    required this.workerLoginId,
    required this.temporaryPassword,
    required this.workshopUser,
  });

  factory WorkerCreationResultModel.fromMap(Map<String, dynamic> map) {
    final workshopUserData = Map<String, dynamic>.from(
      map['workshopUser'] as Map,
    );

    return WorkerCreationResultModel(
      workerLoginId: map['workerLoginId'] as String,
      temporaryPassword: map['temporaryPassword'] as String,
      workshopUser: WorkshopUserModel(
        id: workshopUserData['id'] as String,
        workshopId: workshopUserData['workshopId'] as String,
        userId: workshopUserData['userId'] as String,
        roleId: workshopUserData['roleId'] as String,
        status: WorkshopMemberStatus.values.byName(
          workshopUserData['status'] as String,
        ),
        joinedAt: DateTime.parse(
          workshopUserData['joinedAt'] as String,
        ),
        workerId: workshopUserData['workerId'] as String?,
      ),
    );
  }

  WorkerCreationResultEntity toEntity() {
    return WorkerCreationResultEntity(
      workerLoginId: workerLoginId,
      temporaryPassword: temporaryPassword,
      workshopUser: workshopUser.toEntity(),
    );
  }
}