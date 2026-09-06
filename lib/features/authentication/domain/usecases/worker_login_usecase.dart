import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../workshop_users_roles/domain/enums/workshop_member_status.dart';
import '../../../workshop_users_roles/domain/repositories/workshop_users_roles_repository.dart';
import '../entities/auth_failure.dart';
import '../entities/auth_user_entity.dart';
import '../params/auth_credentials.dart';
import '../repositories/auth_repository.dart';

class WorkerLoginUseCase {
  final AuthRepository _authRepository;
  final WorkshopUsersRolesRepository _workshopUsersRolesRepository;

  const WorkerLoginUseCase(
    this._authRepository,
    this._workshopUsersRolesRepository,
  );

  Future<Either<Failure, AuthUserEntity>> call({
    required String workerLoginId,
    required String password,
  }) async {
    final normalizedId = workerLoginId.trim();

    if (normalizedId.isEmpty) {
      return Left(
        AuthenticationFailure(
          AuthErrorCode.userNotFound,
          'برجاء إدخال Worker Login ID',
        ),
      );
    }

    final email = _workerAuthEmail(normalizedId);

    final loginResult = await _authRepository.login(
      LoginCredentials(
        email: email,
        password: password,
      ),
    );

    if (loginResult.isLeft()) {
      return Left(
        loginResult.fold(
          (failure) => failure,
          (_) => AuthenticationFailure(
            AuthErrorCode.unknown,
          ),
        ),
      );
    }

    final user = loginResult.fold(
      (failure) => null,
      (data) => data,
    );

    if (user == null) {
      return Left(
        AuthenticationFailure(
          AuthErrorCode.userNotFound,
        ),
      );
    }

    final workshopUserResult =
        await _workshopUsersRolesRepository
            .getWorkshopUserByUserId(user.id);

    if (workshopUserResult.isLeft()) {
      await _authRepository.logout();

      return Left(
        workshopUserResult.fold(
          (failure) => failure,
          (_) => AuthenticationFailure(
            AuthErrorCode.unknown,
          ),
        ),
      );
    }

    final workshopUser = workshopUserResult.fold(
      (failure) => null,
      (data) => data,
    );

    if (workshopUser == null) {
      await _authRepository.logout();

      return Left(
        AuthenticationFailure(
          AuthErrorCode.userNotFound,
          'لم يتم العثور على عضوية مرتبطة بحساب العامل.',
        ),
      );
    }

    if (workshopUser.status !=
        WorkshopMemberStatus.active) {
      await _authRepository.logout();

      return Left(
        AuthenticationFailure(
          AuthErrorCode.accountSuspended,
          'الحساب غير نشط. يرجى التواصل مع صاحب الورشة.',
        ),
      );
    }

    return Right(
      user.copyWith(
        workshopId: workshopUser.workshopId,
        roleId: workshopUser.roleId,
      ),
    );
  }

  String _workerAuthEmail(String workerLoginId) {
    final normalized = workerLoginId
        .trim()
        .toLowerCase();

    return '$normalized@workers.kitchenflow.app';
  }
}