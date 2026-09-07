import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/dashboard_preview_content.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  int _noticeId = 0;

  DashboardCubit() : super(const DashboardState.initial());

  @visibleForTesting
  DashboardCubit.withInitialState(super.initialState);

  /// Starts the production Dashboard load path.
  ///
  /// No authoritative, workshop-scoped Dashboard data contract is available
  /// yet. Reporting that dependency as unavailable prevents the approved
  /// design fixture from being mistaken for live workshop data.
  void load() {
    if (state.status == DashboardLoadStatus.loading) return;

    emit(const DashboardState.loading());
    emit(const DashboardState.unavailable());
  }

  void retry() => load();

  void requestAction(DashboardAction action) {
    if (action == DashboardAction.home) return;

    _noticeId++;
    emit(
      state.withActionNotice(
        DashboardActionNotice(id: _noticeId, action: action),
      ),
    );
  }
}
