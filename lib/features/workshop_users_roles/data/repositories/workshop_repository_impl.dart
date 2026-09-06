// lib/features/workshop_users_roles/data/repositories/workshop_repository_impl.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/workshop_entity.dart';
import '../../domain/repositories/workshop_repository.dart';
import '../datasources/workshop_users_roles_remote_data_source.dart';
import '../models/workshop_model.dart';

class WorkshopRepositoryImpl implements WorkshopRepository {
  final WorkshopUsersRolesRemoteDataSource _remoteDataSource;

  const WorkshopRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, WorkshopEntity>> createWorkshop(
    WorkshopEntity workshop,
  ) async {
    try {
      final model = WorkshopModel(
        id: workshop.id,
        ownerId: workshop.ownerId,
        name: workshop.name,
        createdAt: workshop.createdAt,
        updatedAt: workshop.updatedAt,
      );
      final created = await _remoteDataSource.createWorkshop(model);
      return Right(created);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WorkshopEntity>> getWorkshop(String workshopId) async {
    try {
      final model = await _remoteDataSource.getWorkshop(workshopId);
      if (model == null) {
        return Left(AuthFailure('Workshop not found'));
      }
      return Right(model);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WorkshopEntity>> getWorkshopByOwnerId(
    String ownerId,
  ) async {
    try {
      // مؤقتاً - سيتم تنفيذها لاحقاً
      return Left(AuthFailure('Get workshop by owner not implemented yet'));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}