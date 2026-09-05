import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../manager/dashboard_cubit.dart';
import '../manager/dashboard_state.dart';
import '../models/dashboard_preview_content.dart';
import '../widgets/dashboard_header_and_navigation.dart';
import '../widgets/dashboard_operations.dart';
import '../widgets/dashboard_overview_and_actions.dart';
import '../widgets/dashboard_state_views.dart';
import '../widgets/dashboard_summary_sections.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DashboardCubit>()..load(),
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    void requestAction(DashboardAction action) {
      context.read<DashboardCubit>().requestAction(action);
    }

    return BlocConsumer<DashboardCubit, DashboardState>(
      listenWhen: (previous, current) =>
          previous.actionNotice?.id != current.actionNotice?.id,
      listener: (context, state) {
        final notice = state.actionNotice;
        if (notice == null) return;

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                'dashboard.actions.unavailable'.tr(
                  namedArgs: {'action': notice.action.labelKey.tr()},
                ),
              ),
            ),
          );
      },
      builder: (context, state) {
        return Scaffold(
          appBar: DashboardHeader(onAction: requestAction),
          body: _DashboardStateBody(
            state: state,
            onAction: requestAction,
            onRetry: context.read<DashboardCubit>().retry,
          ),
          floatingActionButton: state.content == null
              ? null
              : FloatingActionButton(
                  tooltip: DashboardAction.primary.labelKey.tr(),
                  onPressed: () => requestAction(DashboardAction.primary),
                  child: const Icon(Icons.add_rounded, size: 30),
                ),
          bottomNavigationBar: DashboardBottomNavigation(
            onAction: requestAction,
          ),
        );
      },
    );
  }
}

class _DashboardStateBody extends StatelessWidget {
  final DashboardState state;
  final ValueChanged<DashboardAction> onAction;
  final VoidCallback onRetry;

  const _DashboardStateBody({
    required this.state,
    required this.onAction,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return switch (state.status) {
      DashboardLoadStatus.initial ||
      DashboardLoadStatus.loading => const DashboardLoadingView(),
      DashboardLoadStatus.empty => DashboardEmptyView(onRetry: onRetry),
      DashboardLoadStatus.failure => DashboardFailureView(onRetry: onRetry),
      DashboardLoadStatus.loaded ||
      DashboardLoadStatus.partial => _DashboardContentView(
        content: state.content!,
        isSourcePreview: state.isSourcePreview,
        unavailableSections: state.unavailableSections,
        onAction: onAction,
      ),
    };
  }
}

class _DashboardContentView extends StatelessWidget {
  final DashboardPreviewContent content;
  final bool isSourcePreview;
  final List<DashboardSection> unavailableSections;
  final ValueChanged<DashboardAction> onAction;

  const _DashboardContentView({
    required this.content,
    required this.isSourcePreview,
    required this.unavailableSections,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[
      const DashboardOverviewCard(),
      DashboardQuickActions(onAction: onAction),
      if (unavailableSections.isNotEmpty)
        DashboardPartialBanner(unavailableSections: unavailableSections),
      DashboardOperationsSection(
        metrics: content.metrics,
        isSourcePreview: isSourcePreview,
      ),
      DashboardFinancialSummary(data: content.financial),
      DashboardWorkerActivitySection(
        activities: content.activities,
        onAction: onAction,
      ),
      DashboardInventoryAlert(data: content.inventoryAlert, onAction: onAction),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = constraints.maxWidth > 720
            ? 720.0
            : constraints.maxWidth;

        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: contentWidth,
            child: CustomScrollView(
              key: const Key('dashboard-content-scroll'),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 36),
                  sliver: SliverList.separated(
                    itemCount: sections.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 28),
                    itemBuilder: (context, index) => sections[index],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
