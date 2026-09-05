import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/workshop_user_entity.dart';

abstract class WorkshopUsersRolesRepository {
  Future<Either<Failure, List<WorkshopUserEntity>>> getWorkshopUsers();
}
