
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../authentication/domain/entities/auth_user_entity.dart';
import '../../../authentication/domain/repositories/auth_repository.dart';
import '../entities/workshop_user_entity.dart';
import '../enums/workshop_member_status.dart';
import '../repositories/workshop_users_roles_repository.dart';

class CreateWorkerUseCase {
  final AuthRepository _authRepository;
  final WorkshopUsersRolesRepository _workshopUsersRolesRepository;

  const CreateWorkerUseCase(
    this._authRepository,
    this._workshopUsersRolesRepository,
  );

  Future<Either<Failure, CreateWorkerResult>> call({
    required String email,
    required String password,
    required String displayName,
    required String phone,
    required String roleId,
    required String workshopId,
    required String ownerId,
  }) async {
    final registerResult = await _authRepository.registerWorker(
      email: email,
      password: password,
      displayName: displayName,
    );

    if (registerResult.isLeft()) {
      return Left(registerResult.fold(
        (failure) => failure,
        (_) => AuthFailure('Unexpected error'),
      ));
    }

    final authUser = registerResult.fold(
      (failure) => null,
      (user) => user,
    )!;

    try {
      final workerId = await _generateWorkerId(workshopId);

      final workshopUser = WorkshopUserEntity(
        id: '',
        workshopId: workshopId,
        userId: authUser.id,
        roleId: roleId,
        status: WorkshopMemberStatus.active,
        joinedAt: DateTime.now(),
        workerId: workerId,
      );

      final saveResult = await _workshopUsersRolesRepository.createWorkshopUser(
        workshopUser,
        workerId: workerId,
      );

      if (saveResult.isLeft()) {
        await _authRepository.deleteUser(authUser.id);
        return Left(saveResult.fold(
          (failure) => failure,
          (_) => AuthFailure('Unexpected error'),
        ));
      }

      final savedWorkshopUser = saveResult.fold(
        (failure) => null,
        (data) => data,
      )!;

      return Right(CreateWorkerResult(
        authUser: authUser,
        workerId: workerId,
        workshopUser: savedWorkshopUser,
        temporaryPassword: password,
      ));
    } catch (e) {
      await _authRepository.deleteUser(authUser.id);
      return Left(AuthFailure(e.toString()));
    }
  }

  Future<String> _generateWorkerId(String workshopId) async {
    try {
      final members = await _workshopUsersRolesRepository.getWorkshopUsers(workshopId);
      
      final count = members.fold(
        (failure) => 0,
        (list) => list.length,
      );
      
      return 'W-${(count + 1).toString().padLeft(3, '0')}';
    } catch (e) {
      return 'W-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    }
  }
}

class CreateWorkerResult {
  final AuthUserEntity authUser;
  final String workerId;
  final WorkshopUserEntity workshopUser;
  final String temporaryPassword;

  const CreateWorkerResult({
    required this.authUser,
    required this.workerId,
    required this.workshopUser,
    required this.temporaryPassword,
  });
}
