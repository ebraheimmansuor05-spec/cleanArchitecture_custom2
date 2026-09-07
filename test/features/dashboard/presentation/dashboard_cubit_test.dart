import 'package:flutter_clean_architecture_template/features/dashboard/presentation/manager/dashboard_cubit.dart';
import 'package:flutter_clean_architecture_template/features/dashboard/presentation/manager/dashboard_state.dart';
import 'package:flutter_clean_architecture_template/features/dashboard/presentation/models/dashboard_preview_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('starts in the initial state', () async {
    final cubit = DashboardCubit();

    expect(cubit.state, const DashboardState.initial());

    await cubit.close();
  });

  test(
    'production load reports unavailable data without preview fallback',
    () async {
      final cubit = DashboardCubit();
      final states = <DashboardState>[];
      final subscription = cubit.stream.listen(states.add);

      cubit.load();
      await Future<void>.delayed(Duration.zero);

      expect(states, [
        const DashboardState.loading(),
        const DashboardState.unavailable(),
      ]);
      expect(cubit.state.content, isNull);
      expect(cubit.state.isSourcePreview, isFalse);

      await subscription.cancel();
      await cubit.close();
    },
  );

  test('approved design preview remains an explicit test-only state', () async {
    final cubit = DashboardCubit.withInitialState(
      const DashboardState.preview(
        DashboardPreviewContent.fromApprovedDesign(),
      ),
    );

    expect(cubit.state.status, DashboardLoadStatus.loaded);
    expect(cubit.state.isSourcePreview, isTrue);

    await cubit.close();
  });

  test('unavailable action feedback preserves displayed content', () async {
    final cubit = DashboardCubit.withInitialState(
      const DashboardState.preview(
        DashboardPreviewContent.fromApprovedDesign(),
      ),
    );
    final contentBeforeAction = cubit.state.content;

    cubit.requestAction(DashboardAction.newOrder);

    expect(cubit.state.content, same(contentBeforeAction));
    expect(cubit.state.actionNotice?.action, DashboardAction.newOrder);
    expect(cubit.state.actionNotice?.id, 1);

    cubit.requestAction(DashboardAction.inventory);
    expect(cubit.state.actionNotice?.id, 2);

    await cubit.close();
  });

  test('selecting the current Home destination is a safe no-op', () async {
    final cubit = DashboardCubit.withInitialState(
      const DashboardState.preview(
        DashboardPreviewContent.fromApprovedDesign(),
      ),
    );
    final stateBeforeAction = cubit.state;

    cubit.requestAction(DashboardAction.home);

    expect(cubit.state, stateBeforeAction);

    await cubit.close();
  });
}
