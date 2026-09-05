import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/safe_call.dart';
import '../../domain/entities/workshop_user_entity.dart';
import '../../domain/repositories/workshop_users_roles_repository.dart';
import '../datasources/workshop_users_roles_remote_data_source.dart';

class WorkshopUsersRolesRepositoryImpl
    implements WorkshopUsersRolesRepository {
  final WorkshopUsersRolesRemoteDataSource remoteDataSource;

  WorkshopUsersRolesRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<WorkshopUserEntity>>> getWorkshopUsers() {
    return safeCall(() => remoteDataSource.fetchWorkshopUsers());
  }
}
