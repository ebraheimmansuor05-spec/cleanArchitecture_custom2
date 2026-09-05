// lib/features/authentication/domain/usecases/worker_login_usecase.dart

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
    required String email,
    required String password,
  }) async {
    final loginResult = await _authRepository.login(
      LoginCredentials(email: email, password: password),
    );

    if (loginResult.isLeft()) {
      return Left(loginResult.fold(
        (failure) => failure,
        (_) => AuthFailure('Unexpected error'),
      ));
    }

    final user = loginResult.fold(
      (failure) => null,
      (user) => user,
    )!;

    final workshopUserResult = await _workshopUsersRolesRepository
        .getWorkshopUserByUserId(user.id);

    if (workshopUserResult.isLeft()) {
      return Left(workshopUserResult.fold(
        (failure) => failure,
        (_) => AuthFailure('Unexpected error'),
      ));
    }

    final workshopUser = workshopUserResult.fold(
      (failure) => null,
      (data) => data,
    );

    if (workshopUser == null) {
      return Left(AuthenticationFailure(
        AuthErrorCode.userNotFound,
        'لم يتم العثور على حساب عامل مرتبط بهذا البريد الإلكتروني',
      ));
    }

    if (workshopUser.status != WorkshopMemberStatus.active) {
      return Left(AuthenticationFailure(
        AuthErrorCode.accountSuspended,
        'الحساب غير نشط. يرجى التواصل مع صاحب الورشة',
      ));
    }

    return Right(user.copyWith(
      workshopId: workshopUser.workshopId,
      roleId: workshopUser.roleId,
    ));
  }
}