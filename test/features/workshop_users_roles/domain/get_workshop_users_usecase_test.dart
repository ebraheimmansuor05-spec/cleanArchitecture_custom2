// test/features/workshop_users_roles/domain/usecases/get_workshop_users_usecase_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_clean_architecture_template/core/errors/failures.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/domain/entities/workshop_user_entity.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/domain/repositories/workshop_users_roles_repository.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/domain/usecases/get_workshop_users_usecase.dart';

class MockWorkshopUsersRolesRepository extends Mock
    implements WorkshopUsersRolesRepository {}

void main() {
  late MockWorkshopUsersRolesRepository repository;
  late GetWorkshopUsersUseCase useCase;

  setUp(() {
    repository = MockWorkshopUsersRolesRepository();
    useCase = GetWorkshopUsersUseCase(repository);
  });

  test(
    'delegates getWorkshopUsers to repository and returns users',
    () async {
      const workshopId = 'workshop-1';

      final users = <WorkshopUserEntity>[];

      when(
        () => repository.getWorkshopUsers(workshopId),
      ).thenAnswer(
        (_) async => Right(users),
      );

      final result = await useCase(workshopId);

      expect(result, Right(users));

      verify(
        () => repository.getWorkshopUsers(workshopId),
      ).called(1);
    },
  );

  test(
    'returns repository failure',
    () async {
      const workshopId = 'workshop-1';

      final failure = AuthFailure(
        'Failed to load workshop users',
      );

      when(
        () => repository.getWorkshopUsers(workshopId),
      ).thenAnswer(
        (_) async => Left(failure),
      );

      final result = await useCase(workshopId);

      expect(result, Left(failure));

      verify(
        () => repository.getWorkshopUsers(workshopId),
      ).called(1);
    },
  );
}