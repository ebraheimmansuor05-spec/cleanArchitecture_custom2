import 'package:dartz/dartz.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/domain/usecases/ib/features/workshop_users_roles/domain/update_workshop_user_status_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_clean_architecture_template/core/errors/failures.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/domain/entities/workshop_user_entity.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/domain/enums/workshop_member_status.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/domain/usecases/get_workshop_users_usecase.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/presentation/manager/workshop_user/workshop_user_cubit.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/presentation/manager/workshop_user/workshop_user_state.dart';

class MockGetWorkshopUsersUseCase extends Mock
    implements GetWorkshopUsersUseCase {}

class MockUpdateWorkshopUserStatusUseCase extends Mock
    implements UpdateWorkshopUserStatusUseCase {}

void main() {
  late MockGetWorkshopUsersUseCase getWorkshopUsersUseCase;
  late MockUpdateWorkshopUserStatusUseCase updateWorkshopUserStatusUseCase;
  late WorkshopUserCubit cubit;

  setUp(() {
    getWorkshopUsersUseCase = MockGetWorkshopUsersUseCase();
    updateWorkshopUserStatusUseCase =
        MockUpdateWorkshopUserStatusUseCase();

    cubit = WorkshopUserCubit(
      getWorkshopUsersUseCase,
      updateWorkshopUserStatusUseCase,
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  test(
    'emits loading then loaded when loading users succeeds',
    () async {
      const workshopId = 'workshop-1';
      final users = <WorkshopUserEntity>[];

      when(
        () => getWorkshopUsersUseCase(workshopId),
      ).thenAnswer(
        (_) async => Right(users),
      );

      expect(
        cubit.stream,
        emitsInOrder([
          WorkshopUserLoading(),
          WorkshopUserLoaded(users),
        ]),
      );

      await cubit.loadData(workshopId);

      verify(
        () => getWorkshopUsersUseCase(workshopId),
      ).called(1);
    },
  );

  test(
    'emits loading then error when loading users fails',
    () async {
      const workshopId = 'workshop-1';

      final failure = AuthFailure(
        'Failed to load workshop users',
      );

      when(
        () => getWorkshopUsersUseCase(workshopId),
      ).thenAnswer(
        (_) async => Left(failure),
      );

      expect(
        cubit.stream,
        emitsInOrder([
          WorkshopUserLoading(),
          isA<WorkshopUserError>(),
        ]),
      );

      await cubit.loadData(workshopId);

      verify(
        () => getWorkshopUsersUseCase(workshopId),
      ).called(1);
    },
  );

  test(
    'emits updating then loading then loaded when status update succeeds',
    () async {
      const workshopUserId = 'workshop-user-1';
      const workshopId = 'workshop-1';

      final updatedUser = WorkshopUserEntity(
        id: workshopUserId,
        workshopId: workshopId,
        userId: 'user-1',
        roleId: 'worker',
        status: WorkshopMemberStatus.suspended,
        joinedAt: DateTime(2026, 1, 1),
      );

      when(
        () => updateWorkshopUserStatusUseCase(
          workshopUserId: workshopUserId,
          status: WorkshopMemberStatus.suspended,
        ),
      ).thenAnswer(
        (_) async => Right(updatedUser),
      );

      when(
        () => getWorkshopUsersUseCase(workshopId),
      ).thenAnswer(
        (_) async => Right([updatedUser]),
      );

      expect(
        cubit.stream,
        emitsInOrder([
          WorkshopUserUpdating(
            workshopUserId: workshopUserId,
            status: WorkshopMemberStatus.suspended,
          ),
          WorkshopUserLoading(),
          WorkshopUserLoaded([updatedUser]),
        ]),
      );

      await cubit.updateStatus(
        workshopUserId: workshopUserId,
        status: WorkshopMemberStatus.suspended,
        workshopId: workshopId,
      );

      verify(
        () => updateWorkshopUserStatusUseCase(
          workshopUserId: workshopUserId,
          status: WorkshopMemberStatus.suspended,
        ),
      ).called(1);

      verify(
        () => getWorkshopUsersUseCase(workshopId),
      ).called(1);
    },
  );

  test(
    'emits updating then error when status update fails',
    () async {
      const workshopUserId = 'workshop-user-1';
      const workshopId = 'workshop-1';

      final failure = AuthFailure(
        'Failed to update workshop user status',
      );

      when(
        () => updateWorkshopUserStatusUseCase(
          workshopUserId: workshopUserId,
          status: WorkshopMemberStatus.suspended,
        ),
      ).thenAnswer(
        (_) async => Left(failure),
      );

      expect(
        cubit.stream,
        emitsInOrder([
          WorkshopUserUpdating(
            workshopUserId: workshopUserId,
            status: WorkshopMemberStatus.suspended,
          ),
          isA<WorkshopUserError>(),
        ]),
      );

      await cubit.updateStatus(
        workshopUserId: workshopUserId,
        status: WorkshopMemberStatus.suspended,
        workshopId: workshopId,
      );

      verify(
        () => updateWorkshopUserStatusUseCase(
          workshopUserId: workshopUserId,
          status: WorkshopMemberStatus.suspended,
        ),
      ).called(1);

      verifyNever(
        () => getWorkshopUsersUseCase(workshopId),
      );
    },
  );
}