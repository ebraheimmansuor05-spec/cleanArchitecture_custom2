import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_clean_architecture_template/core/errors/failures.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/data/datasources/workshop_users_roles_remote_data_source.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/data/models/role_model.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/data/repositories/role_repository_impl.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/domain/entities/role_entity.dart';

class MockWorkshopUsersRolesRemoteDataSource extends Mock
    implements WorkshopUsersRolesRemoteDataSource {}

void main() {
  late MockWorkshopUsersRolesRemoteDataSource remoteDataSource;
  late RoleRepositoryImpl repository;

  setUp(() {
    remoteDataSource = MockWorkshopUsersRolesRemoteDataSource();
    repository = RoleRepositoryImpl(remoteDataSource);
  });

  group('getRoles', () {
    test(
      'returns roles mapped from remote data source models',
      () async {
        const workshopId = 'workshop-1';

        final roles = <RoleModel>[
          RoleModel(
            id: 'role-1',
            workshopId: workshopId,
            name: 'Manager',
            description: 'Workshop manager',
            permissions: const [],
            isSystemRole: false,
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
          ),
        ];

        when(
          () => remoteDataSource.getRoles(workshopId),
        ).thenAnswer(
          (_) async => roles,
        );

        final result = await repository.getRoles(workshopId);

        expect(result.isRight(), isTrue);

        final mappedRoles = result.fold(
          (_) => <RoleEntity>[],
          (value) => value,
        );

        expect(mappedRoles, hasLength(1));
        expect(mappedRoles.first.id, 'role-1');
        expect(mappedRoles.first.workshopId, workshopId);
        expect(mappedRoles.first.name, 'Manager');
        expect(
          mappedRoles.first.description,
          'Workshop manager',
        );
        expect(mappedRoles.first.permissions, isEmpty);
        expect(mappedRoles.first.isSystemRole, isFalse);
        expect(
          mappedRoles.first.createdAt,
          DateTime(2026, 1, 1),
        );
        expect(
          mappedRoles.first.updatedAt,
          DateTime(2026, 1, 1),
        );

        verify(
          () => remoteDataSource.getRoles(workshopId),
        ).called(1);
      },
    );

    test(
      'returns failure when remote data source throws',
      () async {
        const workshopId = 'workshop-1';

        when(
          () => remoteDataSource.getRoles(workshopId),
        ).thenThrow(
          Exception('Failed to fetch roles'),
        );

        final result = await repository.getRoles(workshopId);

        expect(result.isLeft(), isTrue);

        final failure = result.fold(
          (failure) => failure,
          (_) => null,
        );

        expect(failure, isA<AuthFailure>());

        verify(
          () => remoteDataSource.getRoles(workshopId),
        ).called(1);
      },
    );
  });
}