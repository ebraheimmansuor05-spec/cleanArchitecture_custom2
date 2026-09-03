import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../shared/mixin/cancelable_safe_cubit_mixin.dart';
import '../../../domain/entities/workshop_entity.dart';
import '../../../domain/usecases/create_workshop_usecase.dart';
import '../../../domain/usecases/get_workshop_usecase.dart';
import 'workshop_state.dart';

class WorkshopCubit extends Cubit<WorkshopState>
    with CancelableSafeCubitMixin<WorkshopState> {
  final CreateWorkshopUseCase _createWorkshopUseCase;
  final GetWorkshopUseCase _getWorkshopUseCase;

  WorkshopCubit(
    this._createWorkshopUseCase,
    this._getWorkshopUseCase,
  ) : super(WorkshopInitial());

  Future<void> createWorkshop(WorkshopEntity workshop) async {
    safeEmit(WorkshopLoading());

    final result = await runCancelable(
      _createWorkshopUseCase.call(workshop),
    );

    if (result == null) return;

    result.fold(
      (failure) => safeEmit(WorkshopError(failure.message)),
      (workshop) => safeEmit(WorkshopCreated(workshop)),
    );
  }

  Future<void> loadWorkshop(String workshopId) async {
    safeEmit(WorkshopLoading());

    final result = await runCancelable(
      _getWorkshopUseCase.call(workshopId),
    );

    if (result == null) return;

    result.fold(
      (failure) => safeEmit(WorkshopError(failure.message)),
      (workshop) => safeEmit(WorkshopLoaded(workshop)),
    );
  }
}