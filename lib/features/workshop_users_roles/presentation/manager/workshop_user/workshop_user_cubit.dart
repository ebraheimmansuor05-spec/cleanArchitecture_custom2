import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../shared/mixin/cancelable_safe_cubit_mixin.dart';
import '../../../domain/enums/workshop_member_status.dart';
import '../../../domain/usecases/get_workshop_users_usecase.dart';
import '../../../domain/usecases/ib/features/workshop_users_roles/domain/update_workshop_user_status_usecase.dart';
import 'workshop_user_state.dart';

class WorkshopUserCubit extends Cubit<WorkshopUserState>
    with CancelableSafeCubitMixin<WorkshopUserState> {
  final GetWorkshopUsersUseCase _getWorkshopUsersUseCase;
  final UpdateWorkshopUserStatusUseCase
      _updateWorkshopUserStatusUseCase;

  WorkshopUserCubit(
    this._getWorkshopUsersUseCase,
    this._updateWorkshopUserStatusUseCase,
  ) : super(WorkshopUserInitial());

  Future<void> loadData(String workshopId) async {
    safeEmit(WorkshopUserLoading());

    final result = await runCancelable(
      _getWorkshopUsersUseCase.call(workshopId),
    );

    if (result == null) return;

    result.fold(
      (failure) => safeEmit(
        WorkshopUserError(failure.message),
      ),
      (users) => safeEmit(
        WorkshopUserLoaded(users),
      ),
    );
  }

  Future<void> updateStatus({
    required String workshopUserId,
    required WorkshopMemberStatus status,
    required String workshopId,
  }) async {
    safeEmit(
      WorkshopUserUpdating(
        workshopUserId: workshopUserId,
        status: status,
      ),
    );

    final result = await runCancelable(
      _updateWorkshopUserStatusUseCase.call(
        workshopUserId: workshopUserId,
        status: status,
      ),
    );

    if (result == null) return;

    final failure = result.fold(
      (failure) => failure,
      (_) => null,
    );

    if (failure != null) {
      safeEmit(
        WorkshopUserError(failure.message),
      );
      return;
    }

    await loadData(workshopId);
  }
}