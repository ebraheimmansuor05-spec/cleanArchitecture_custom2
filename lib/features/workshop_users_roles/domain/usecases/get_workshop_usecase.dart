import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/use_cases/use_case.dart';
import '../entities/workshop_entity.dart';
import '../repositories/workshop_repository.dart';

class GetWorkshopUseCase
    implements UseCase<WorkshopEntity, String> {
  final WorkshopRepository repository;

  GetWorkshopUseCase(this.repository);

  @override
  Future<Either<Failure, WorkshopEntity>> call([
    String? param,
  ]) {
    if (param == null) {
      throw ArgumentError('Workshop ID is required.');
    }

    return repository.getWorkshop(param);
  }
}