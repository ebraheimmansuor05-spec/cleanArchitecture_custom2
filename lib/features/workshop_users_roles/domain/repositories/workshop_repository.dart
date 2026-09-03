import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/workshop_entity.dart';

abstract class WorkshopRepository {
  Future<Either<Failure, WorkshopEntity>> createWorkshop(
    WorkshopEntity workshop,
  );

  Future<Either<Failure, WorkshopEntity>> getWorkshop(
    String workshopId,
  );
}