import 'package:equatable/equatable.dart';

class WorkerCreationResultEntity extends Equatable {
  final String workerId;
  final String workerLoginId;
  final String temporaryPassword;
  final String workshopUserId;

  const WorkerCreationResultEntity({
    required this.workerId,
    required this.workerLoginId,
    required this.temporaryPassword,
    required this.workshopUserId,
  });

  @override
  List<Object?> get props => [
        workerId,
        workerLoginId,
        temporaryPassword,
        workshopUserId,
      ];
}