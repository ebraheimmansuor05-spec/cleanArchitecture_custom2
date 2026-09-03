import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../shared/mixin/cancelable_safe_cubit_mixin.dart';
import '../../../domain/usecases/get_roles_usecase.dart';
import 'role_state.dart';

class RoleCubit extends Cubit<RoleState>
    with CancelableSafeCubitMixin<RoleState> {
  final GetRolesUseCase _getRolesUseCase;

  String? _workshopId;

  RoleCubit(this._getRolesUseCase) : super(RoleInitial());

  Future<void> loadRoles(String workshopId) async {
    _workshopId = workshopId;

    safeEmit(RoleLoading());

    final result = await runCancelable(
      _getRolesUseCase.call(workshopId),
    );

    if (result == null) return;

    result.fold(
      (failure) => safeEmit(RoleError(failure.message)),
      (roles) => safeEmit(RoleLoaded(roles)),
    );
  }

  Future<void> retry() async {
    final workshopId = _workshopId;

    if (workshopId == null) return;

    await loadRoles(workshopId);
  }
}