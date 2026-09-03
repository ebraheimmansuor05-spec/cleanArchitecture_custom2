import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/safe_call.dart';
import '../../domain/entities/workshop_entity.dart';
import '../../domain/repositories/workshop_repository.dart';
import '../datasources/workshop_users_roles_remote_data_source.dart';
import '../models/workshop_model.dart';

class WorkshopRepositoryImpl implements WorkshopRepository {
  final WorkshopUsersRolesRemoteDataSource remoteDataSource;

  WorkshopRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, WorkshopEntity>> createWorkshop(
    WorkshopEntity workshop,
  ) {
    return safeCall(
      () => remoteDataSource.createWorkshop(
        WorkshopModel(
          id: workshop.id,
          ownerId: workshop.ownerId,
          name: workshop.name,
          createdAt: workshop.createdAt,
          updatedAt: workshop.updatedAt,
        ),
      ),
    );
  }

  @override
  Future<Either<Failure, WorkshopEntity>> getWorkshop(String workshopId) {
    return safeCall(() => remoteDataSource.getWorkshop(workshopId));
  }
}
