
// test/features/workshop_users_roles/data/repositories/workshop_users_roles_repository_impl_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_clean_architecture_template/core/errors/failures.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/data/datasources/workshop_users_roles_remote_data_source.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/data/models/workshop_user_model.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/data/repositories/workshop_users_roles_repository_impl.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/domain/entities/workshop_user_entity.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/domain/enums/workshop_member_status.dart';

class MockWorkshopUsersRolesRemoteDataSource extends Mock
    implements WorkshopUsersRolesRemoteDataSource {}

void main() {
  late MockWorkshopUsersRolesRemoteDataSource remoteDataSource;
  late WorkshopUsersRolesRepositoryImpl repository;

  setUp(() {
    remoteDataSource = MockWorkshopUsersRolesRemoteDataSource();
    repository = WorkshopUsersRolesRepositoryImpl(
      remoteDataSource,
    );
  });

  group('getWorkshopUsers', () {
    test(
      'returns workshop users mapped from remote models',
      () async {
        const workshopId = 'workshop-1';

        final models = <WorkshopUserModel>[
          WorkshopUserModel(
            id: 'member-1',
            workshopId: workshopId,
            userId: 'user-1',
            roleId: 'role-1',
            status: WorkshopMemberStatus.active,
            joinedAt: DateTime(2026, 1, 1),
          ),
        ];

        when(
          () => remoteDataSource.getWorkshopUsers(workshopId),
        ).thenAnswer(
          (_) async => models,
        );

        final result = await repository.getWorkshopUsers(
          workshopId,
        );

        expect(result.isRight(), isTrue);

        final users = result.fold(
          (_) => <WorkshopUserEntity>[],
          (value) => value,
        );

        expect(users, hasLength(1));
        expect(users.first.id, 'member-1');
        expect(users.first.workshopId, workshopId);
        expect(users.first.userId, 'user-1');
        expect(users.first.roleId, 'role-1');
        expect(
          users.first.status,
          WorkshopMemberStatus.active,
        );

        verify(
          () => remoteDataSource.getWorkshopUsers(workshopId),
        ).called(1);
      },
    );

    test(
      'returns failure when remote data source throws',
      () async {
        const workshopId = 'workshop-1';

        when(
          () => remoteDataSource.getWorkshopUsers(workshopId),
        ).thenThrow(
          Exception('Firestore error'),
        );

        final result = await repository.getWorkshopUsers(
          workshopId,
        );

        expect(result.isLeft(), isTrue);

        final failure = result.fold(
          (value) => value,
          (_) => null,
        );

        expect(failure, isA<AuthFailure>());

        verify(
          () => remoteDataSource.getWorkshopUsers(workshopId),
        ).called(1);
      },
    );
  });
}

