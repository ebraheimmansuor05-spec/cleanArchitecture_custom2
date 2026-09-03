import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_clean_architecture_template/features/workshop_users_roles/domain/entities/workshop_user_entity.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/domain/usecases/get_workshop_users_usecase.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/presentation/manager/workshop_user/workshop_user_cubit.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/presentation/manager/workshop_user/workshop_user_state.dart';

class MockGetWorkshopUsersUseCase extends Mock
    implements GetWorkshopUsersUseCase {}

void main() {
  late MockGetWorkshopUsersUseCase useCase;
  late WorkshopUserCubit cubit;

  setUp(() {
    useCase = MockGetWorkshopUsersUseCase();
    cubit = WorkshopUserCubit(useCase);
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
        () => useCase(workshopId),
      ).thenAnswer(
        (_) async => users,
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
        () => useCase(workshopId),
      ).called(1);
    },
  );
}