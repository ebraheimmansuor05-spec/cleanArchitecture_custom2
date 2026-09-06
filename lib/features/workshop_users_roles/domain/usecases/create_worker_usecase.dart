import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/worker_creation_result_entity.dart';
import '../repositories/workshop_users_roles_repository.dart';
import '../repositories/workshop_repository.dart';

class CreateWorkerUseCase {
  final WorkshopUsersRolesRepository _workshopUsersRolesRepository;
  final WorkshopRepository _workshopRepository;

  const CreateWorkerUseCase(
    this._workshopUsersRolesRepository,
    this._workshopRepository,
  );

  Future<Either<Failure, WorkerCreationResultEntity>> call({
    required String displayName,
    required String phone,
    required String password,
    required String roleId,
    required String workshopId,
  }) async {
    if (displayName.trim().isEmpty) {
      return Left(
        AuthFailure('Worker display name is required.'),
      );
    }

    if (phone.trim().isEmpty) {
      return Left(
        AuthFailure('Worker phone is required.'),
      );
    }

    if (password.length < 6) {
      return Left(
        AuthFailure(
          'Worker password must contain at least 6 characters.',
        ),
      );
    }

    if (roleId.trim().isEmpty) {
      return Left(
        AuthFailure('Worker role is required.'),
      );
    }

    if (workshopId.trim().isEmpty) {
      return Left(
        AuthFailure('Workshop is required.'),
      );
    }

    final workshopResult =
        await _workshopRepository.getWorkshop(
      workshopId,
    );

    if (workshopResult.isLeft()) {
      return Left(
        workshopResult.fold(
          (failure) => failure,
          (_) => AuthFailure('Workshop not found.'),
        ),
      );
    }

    return _workshopUsersRolesRepository.createWorker(
      displayName: displayName,
      phone: phone,
      password: password,
      roleId: roleId,
      workshopId: workshopId,
    );
  }
}