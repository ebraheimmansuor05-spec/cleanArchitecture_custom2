import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_clean_architecture_template/features/workshop_users_roles/data/datasources/workshop_users_roles_remote_data_source.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/data/repositories/workshop_users_roles_repository_impl.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/data/models/workshop_user_model.dart';

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

  group('fetchWorkshopUsers', () {
    test('returns users from remote data source', () async {
      const workshopId = 'workshop-1';

      final users = <WorkshopUserModel>[];

      when(
        () => remoteDataSource.fetchWorkshopUsers(workshopId),
      ).thenAnswer(
        (_) async => users,
      );

      final result = await repository.fetchWorkshopUsers(
        workshopId,
      );

      expect(result, users);

      verify(
        () => remoteDataSource.fetchWorkshopUsers(workshopId),
      ).called(1);
    });
  });

  group('fetchRoles', () {
    test('returns roles from remote data source', () async {
      const workshopId = 'workshop-1';

      final roles = <dynamic>[];

      when(
        () => remoteDataSource.fetchRoles(workshopId),
      ).thenAnswer(
        (_) async => roles.cast(),
      );

      final result = await repository.fetchRoles(
        workshopId,
      );

      expect(result, roles);

      verify(
        () => remoteDataSource.fetchRoles(workshopId),
      ).called(1);
    });
  });
}