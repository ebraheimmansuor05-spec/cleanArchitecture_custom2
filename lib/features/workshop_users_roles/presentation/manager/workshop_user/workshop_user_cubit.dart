// lib/features/workshop_users_roles/presentation/manager/workshop_user/workshop_user_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../shared/mixin/cancelable_safe_cubit_mixin.dart';
import '../../../domain/usecases/get_workshop_users_usecase.dart';
import 'workshop_user_state.dart';

class WorkshopUserCubit extends Cubit<WorkshopUserState>
    with CancelableSafeCubitMixin<WorkshopUserState> {
  final GetWorkshopUsersUseCase _getWorkshopUsersUseCase;

  WorkshopUserCubit(this._getWorkshopUsersUseCase)
      : super(WorkshopUserInitial());

  Future<void> loadData(String workshopId) async {
    safeEmit(WorkshopUserLoading());

    final result = await runCancelable(
      _getWorkshopUsersUseCase.call(workshopId),
    );

    if (result == null) return;

    // ✅ استخدم fold بدلاً من تمرير Either مباشرة
    result.fold(
      (failure) => safeEmit(WorkshopUserError(failure.message)),
      (users) => safeEmit(WorkshopUserLoaded(users)),
    );
  }
}