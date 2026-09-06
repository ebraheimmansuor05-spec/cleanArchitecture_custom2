
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/workshop_entity.dart';
import '../repositories/workshop_repository.dart';

class GetWorkshopByOwnerIdUseCase {
  final WorkshopRepository _repository;

  const GetWorkshopByOwnerIdUseCase(this._repository);

  Future<Either<Failure, WorkshopEntity>> call(
    String ownerId,
  ) {
    return _repository.getWorkshopByOwnerId(ownerId);
  }
}

