// lib/features/authentication/authentication_injection.dart

import 'package:firebase_auth/firebase_auth.dart';

import '../../core/di/injection_container.dart';
import '../workshop_users_roles/domain/repositories/workshop_users_roles_repository.dart';
import '../workshop_users_roles/domain/usecases/create_workshop_usecase.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/auth_use_cases.dart';
import 'domain/usecases/worker_login_usecase.dart';
import 'presentation/manager/authentication_cubit.dart';
import 'presentation/manager/session_cubit.dart';

void initAuthentication() {
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => FirebaseAuthRemoteDataSource(sl<FirebaseAuth>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );

  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(
    () => SendPasswordResetUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => CheckSessionUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ObserveAuthStateUseCase(sl<AuthRepository>()));

  sl.registerLazySingleton(
    () => WorkerLoginUseCase(
      sl<AuthRepository>(),
      sl<WorkshopUsersRolesRepository>(),
    ),
  );

  sl.registerFactory(
    () => AuthenticationCubit(
      loginUseCase: sl<LoginUseCase>(),
      registerUseCase: sl<RegisterUseCase>(),
      sendPasswordResetUseCase: sl<SendPasswordResetUseCase>(),
      createWorkshopUseCase: sl<CreateWorkshopUseCase>(),
      workerLoginUseCase: sl<WorkerLoginUseCase>(),
    ),
  );
  sl.registerFactory(
    () => SessionCubit(
      checkSessionUseCase: sl<CheckSessionUseCase>(),
      observeAuthStateUseCase: sl<ObserveAuthStateUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
    ),
  );
}