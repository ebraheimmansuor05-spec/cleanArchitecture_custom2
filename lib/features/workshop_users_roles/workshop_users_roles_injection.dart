import '../../core/di/injection_container.dart';
import '../../core/network/api_consumer.dart';
import 'data/datasources/workshop_users_roles_remote_data_source.dart';
import 'data/repositories/workshop_users_roles_repository_impl.dart';
import 'domain/repositories/workshop_users_roles_repository.dart';
import 'domain/usecases/get_workshop_users_usecase.dart';
import 'presentation/manager/workshop_user/workshop_user_cubit.dart';

void initWorkshopUsersRoles() {
  // ── State Management ────────────────────────────────────────────────────────
  sl.registerFactory(
    () => WorkshopUserCubit(sl<GetWorkshopUsersUseCase>()),
  );

  // ── Use Cases ────────────────────────────────────────────────────────────────
  sl.registerLazySingleton(
    () => GetWorkshopUsersUseCase(sl<WorkshopUsersRolesRepository>()),
  );

  // ── Repository ───────────────────────────────────────────────────────────────
  sl.registerLazySingleton<WorkshopUsersRolesRepository>(
    () => WorkshopUsersRolesRepositoryImpl(
      sl<WorkshopUsersRolesRemoteDataSource>(),
    ),
  );

  // ── Data Sources ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<WorkshopUsersRolesRemoteDataSource>(
    () => WorkshopUsersRolesRemoteDataSourceImpl(sl<ApiConsumer>()),
  );
}
