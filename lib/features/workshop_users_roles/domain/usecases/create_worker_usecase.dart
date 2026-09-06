// lib/features/workshop_users_roles/domain/usecases/create_worker_usecase.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/workshop_user_entity.dart';
import '../enums/workshop_member_status.dart';
import '../repositories/workshop_users_roles_repository.dart';
import '../repositories/workshop_repository.dart';

class CreateWorkerUseCase {
  final WorkshopUsersRolesRepository _workshopUsersRolesRepository;
  final WorkshopRepository _workshopRepository;

  const CreateWorkerUseCase(
    this._workshopUsersRolesRepository,
    this._workshopRepository,
  );

  Future<Either<Failure, CreateWorkerResult>> call({
    required String displayName,
    required String phone,
    required String password,
    required String roleId,
    required String workshopId,
  }) async {
    // 1. التحقق من وجود الـ Workshop
    final workshopResult = await _workshopRepository.getWorkshop(workshopId);
    if (workshopResult.isLeft()) {
      return Left(workshopResult.fold(
        (failure) => failure,
        (_) => AuthFailure('Workshop not found'),
      ));
    }

    // 2. توليد Worker Login ID فريد
    final workerLoginId = await _generateUniqueWorkerLoginId(workshopId);

    // 3. إنشاء العامل في الـ Repository
    final createResult = await _workshopUsersRolesRepository.createWorkshopUser(
      WorkshopUserEntity(
        id: '',
        workshopId: workshopId,
        userId: '', // سيتم تعبئته بعد إنشاء Auth
        roleId: roleId,
        status: WorkshopMemberStatus.active,
        joinedAt: DateTime.now(),
        workerId: workerLoginId,
      ),
      workerId: workerLoginId,
    );

    if (createResult.isLeft()) {
      return Left(createResult.fold(
        (failure) => failure,
        (_) => AuthFailure('Failed to create worker'),
      ));
    }

    final createdUser = createResult.fold(
      (failure) => null,
      (data) => data,
    )!;

    return Right(CreateWorkerResult(
      workerLoginId: workerLoginId,
      temporaryPassword: password,
      workshopUser: createdUser,
    ));
  }

  Future<String> _generateUniqueWorkerLoginId(String workshopId) async {
    // استخدام timestamp لتوليد ID فريد
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'W-${timestamp.toString().substring(8)}';
  }
}

class CreateWorkerResult {
  final String workerLoginId;
  final String temporaryPassword;
  final WorkshopUserEntity workshopUser;

  const CreateWorkerResult({
    required this.workerLoginId,
    required this.temporaryPassword,
    required this.workshopUser,
  });
}