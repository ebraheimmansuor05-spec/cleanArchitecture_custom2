import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/use_cases/use_case.dart';
import '../entities/workshop_entity.dart';
import '../repositories/workshop_repository.dart';

class CreateWorkshopUseCase
    implements UseCase<WorkshopEntity, WorkshopEntity> {
  final WorkshopRepository repository;

  CreateWorkshopUseCase(this.repository);

  @override
  Future<Either<Failure, WorkshopEntity>> call([
    WorkshopEntity? param,
  ]) {
    if (param == null) {
      throw ArgumentError('Workshop is required.');
    }

    return repository.createWorkshop(param);
  }
}