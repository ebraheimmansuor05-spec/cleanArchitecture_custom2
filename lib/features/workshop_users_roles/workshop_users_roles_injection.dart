// lib/features/workshop_users_roles/workshop_users_roles_injection.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/di/injection_container.dart';
import 'data/datasources/workshop_users_roles_remote_data_source.dart';
import 'data/repositories/role_repository_impl.dart';
import 'data/repositories/workshop_repository_impl.dart';
import 'data/repositories/workshop_users_roles_repository_impl.dart';
import 'domain/repositories/role_repository.dart';
import 'domain/repositories/workshop_repository.dart';
import 'domain/repositories/workshop_users_roles_repository.dart';
import 'domain/usecases/create_workshop_usecase.dart';
import 'domain/usecases/create_worker_usecase.dart';
import 'domain/usecases/get_workshop_by_owner_id_usecase.dart';
import 'domain/usecases/get_workshop_usecase.dart';
import 'domain/usecases/get_workshop_users_usecase.dart';
import 'domain/usecases/get_roles_usecase.dart';
import 'presentation/manager/role/role_cubit.dart';
import 'presentation/manager/workshop_user/workshop_cubit.dart';
import 'presentation/manager/workshop_user/workshop_user_cubit.dart';

void initWorkshopUsersRoles() {
  // Data Source
  sl.registerLazySingleton<WorkshopUsersRolesRemoteDataSource>(
    () => FirebaseWorkshopUsersRolesDataSource(
      sl<FirebaseFirestore>(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<WorkshopUsersRolesRepository>(
    () => WorkshopUsersRolesRepositoryImpl(
      sl<WorkshopUsersRolesRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<RoleRepository>(
    () => RoleRepositoryImpl(
      sl<WorkshopUsersRolesRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<WorkshopRepository>(
    () => WorkshopRepositoryImpl(
      sl<WorkshopUsersRolesRemoteDataSource>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<GetWorkshopUsersUseCase>(
    () => GetWorkshopUsersUseCase(
      sl<WorkshopUsersRolesRepository>(),
    ),
  );

  sl.registerLazySingleton<GetWorkshopByOwnerIdUseCase>(
    () => GetWorkshopByOwnerIdUseCase(
      sl<WorkshopRepository>(),
    ),
  );

  sl.registerLazySingleton<CreateWorkshopUseCase>(
    () => CreateWorkshopUseCase(
      sl<WorkshopRepository>(),
    ),
  );

  sl.registerLazySingleton<GetWorkshopUseCase>(
    () => GetWorkshopUseCase(
      sl<WorkshopRepository>(),
    ),
  );

  sl.registerLazySingleton<GetRolesUseCase>(
    () => GetRolesUseCase(
      sl<RoleRepository>(),
    ),
  );

  sl.registerLazySingleton<CreateWorkerUseCase>(
    () => CreateWorkerUseCase(
      sl<WorkshopUsersRolesRepository>(),
      sl<WorkshopRepository>(),
    ),
  );

  // Cubits
  sl.registerFactory<WorkshopUserCubit>(
    () => WorkshopUserCubit(
      sl<GetWorkshopUsersUseCase>(),
    ),
  );

  sl.registerFactory<WorkshopCubit>(
    () => WorkshopCubit(
      sl<CreateWorkshopUseCase>(),
      sl<GetWorkshopUseCase>(),
      sl<GetWorkshopByOwnerIdUseCase>(),
    ),
  );

  sl.registerFactory<RoleCubit>(
    () => RoleCubit(
      sl<GetRolesUseCase>(),
    ),
  );
}