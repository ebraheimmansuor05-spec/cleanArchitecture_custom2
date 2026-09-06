import 'package:equatable/equatable.dart';

import 'workshop_user_entity.dart';

class WorkerCreationResultEntity extends Equatable {
  final String workerLoginId;
  final String temporaryPassword;
  final WorkshopUserEntity workshopUser;

  const WorkerCreationResultEntity({
    required this.workerLoginId,
    required this.temporaryPassword,
    required this.workshopUser,
  });

  @override
  List<Object?> get props => [
        workerLoginId,
        temporaryPassword,
        workshopUser,
      ];
}