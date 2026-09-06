import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_clean_architecture_template/core/errors/failures.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/domain/entities/role_entity.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/domain/usecases/get_roles_usecase.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/presentation/manager/role/role_cubit.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/presentation/manager/role/role_state.dart';

class MockGetRolesUseCase extends Mock implements GetRolesUseCase {}

void main() {
  late MockGetRolesUseCase useCase;
  late RoleCubit cubit;

  setUp(() {
    useCase = MockGetRolesUseCase();
    cubit = RoleCubit(useCase);
  });

  tearDown(() async {
    await cubit.close();
  });

  test(
    'emits loading then loaded when loading roles succeeds',
    () async {
      const workshopId = 'workshop-1';
      final roles = <RoleEntity>[];

      when(
        () => useCase(workshopId),
      ).thenAnswer(
        (_) async => Right(roles),
      );

      expect(
        cubit.stream,
        emitsInOrder([
          RoleLoading(),
          RoleLoaded(roles),
        ]),
      );

      await cubit.loadRoles(workshopId);

      verify(
        () => useCase(workshopId),
      ).called(1);
    },
  );

  test(
    'emits loading then error when loading roles fails',
    () async {
      const workshopId = 'workshop-1';

      final failure = ServerFailure(
        'Failed to load roles.',
      );

      when(
        () => useCase(workshopId),
      ).thenAnswer(
        (_) async => Left(failure),
      );

      expect(
        cubit.stream,
        emitsInOrder([
          RoleLoading(),
          RoleError(failure.message),
        ]),
      );

      await cubit.loadRoles(workshopId);

      verify(
        () => useCase(workshopId),
      ).called(1);
    },
  );

  test(
    'retry reloads roles using the last workshop id',
    () async {
      const workshopId = 'workshop-1';
      final roles = <RoleEntity>[];

      when(
        () => useCase(workshopId),
      ).thenAnswer(
        (_) async => Right(roles),
      );

      await cubit.loadRoles(workshopId);

      await cubit.retry();

      verify(
        () => useCase(workshopId),
      ).called(2);
    },
  );
}