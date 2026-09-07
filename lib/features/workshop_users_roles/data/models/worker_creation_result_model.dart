import '../../domain/entities/worker_creation_result_entity.dart';

class WorkerCreationResultModel extends WorkerCreationResultEntity {
  const WorkerCreationResultModel({
    required super.workerId,
    required super.workerLoginId,
    required super.temporaryPassword,
    required super.workshopUserId,
  });

  factory WorkerCreationResultModel.fromMap(
    Map<String, dynamic> map,
  ) {
    final workerId = map['workerId'];
    final workerLoginId = map['workerLoginId'];
    final temporaryPassword = map['temporaryPassword'];
    final workshopUserId = map['workshopUserId'];

    if (workerId is! String || workerId.trim().isEmpty) {
      throw const FormatException(
        'Invalid workerId in createWorker response.',
      );
    }

    if (workerLoginId is! String || workerLoginId.trim().isEmpty) {
      throw const FormatException(
        'Invalid workerLoginId in createWorker response.',
      );
    }

    if (temporaryPassword is! String || temporaryPassword.isEmpty) {
      throw const FormatException(
        'Invalid temporaryPassword in createWorker response.',
      );
    }

    if (workshopUserId is! String || workshopUserId.trim().isEmpty) {
      throw const FormatException(
        'Invalid workshopUserId in createWorker response.',
      );
    }

    return WorkerCreationResultModel(
      workerId: workerId,
      workerLoginId: workerLoginId,
      temporaryPassword: temporaryPassword,
      workshopUserId: workshopUserId,
    );
  }

  WorkerCreationResultEntity toEntity() {
    return WorkerCreationResultEntity(
      workerId: workerId,
      workerLoginId: workerLoginId,
      temporaryPassword: temporaryPassword,
      workshopUserId: workshopUserId,
    );
  }
}