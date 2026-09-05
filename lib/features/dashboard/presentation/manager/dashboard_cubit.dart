import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/dashboard_preview_content.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  int _noticeId = 0;

  DashboardCubit({DashboardState initialState = const DashboardState.initial()})
    : super(initialState);

  /// Loads only the display values supplied by the approved UI reference.
  /// Real workshop data remains deferred until its owning features expose
  /// stable, workshop-scoped contracts.
  void load() {
    if (state.status == DashboardLoadStatus.loading) return;

    emit(const DashboardState.loading());
    emit(
      const DashboardState.preview(
        DashboardPreviewContent.fromApprovedDesign(),
      ),
    );
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
