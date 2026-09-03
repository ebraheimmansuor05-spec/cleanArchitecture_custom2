
import 'package:dartz/dartz.dart';
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
      'returns roles when remote data source succeeds',
      () async {
        const workshopId = 'workshop-1';

        final roles = <RoleModel>[];

        when(
          () => remoteDataSource.fetchRoles(workshopId),
        ).thenAnswer(
          (_) async => roles,
        );

        final result = await repository.getRoles(workshopId);

        expect(result, Right<Failure, List<RoleEntity>>(roles));

        verify(
          () => remoteDataSource.fetchRoles(workshopId),
        ).called(1);
      },
    );

    test(
      'returns failure when remote data source throws',
      () async {
        const workshopId = 'workshop-1';

        when(
          () => remoteDataSource.fetchRoles(workshopId),
        ).thenThrow(
          Exception('Failed to fetch roles'),
        );

        final result = await repository.getRoles(workshopId);

        expect(result.isLeft(), true);

        verify(
          () => remoteDataSource.fetchRoles(workshopId),
        ).called(1);
      },
    );
  });
}
