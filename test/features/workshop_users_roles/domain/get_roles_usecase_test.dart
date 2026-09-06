
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_clean_architecture_template/core/errors/failures.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/domain/entities/role_entity.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/domain/repositories/role_repository.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/domain/usecases/get_roles_usecase.dart';

class MockRoleRepository extends Mock implements RoleRepository {}

void main() {
  late MockRoleRepository repository;
  late GetRolesUseCase useCase;

  setUp(() {
    repository = MockRoleRepository();
    useCase = GetRolesUseCase(repository);
  });

  test(
    'delegates getRoles to repository with the given workshop id',
    () async {
      const workshopId = 'workshop-1';

      final roles = <RoleEntity>[];

      when(
        () => repository.getRoles(workshopId),
      ).thenAnswer(
        (_) async => Right(roles),
      );

      final result = await useCase(workshopId);

      expect(result, Right(roles));

      verify(
        () => repository.getRoles(workshopId),
      ).called(1);
    },
  );

  test(
    'returns repository failure',
    () async {
      const workshopId = 'workshop-1';

      final failure = ServerFailure(
        'Failed to load roles.',
      );

      when(
        () => repository.getRoles(workshopId),
      ).thenAnswer(
        (_) async => Left(failure),
      );

      final result = await useCase(workshopId);

      expect(result, Left(failure));

      verify(
        () => repository.getRoles(workshopId),
      ).called(1);
    },
  );
}
