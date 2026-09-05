import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../shared/widgets/custom_shimmer.dart';
import '../../../../../shared/widgets/no_data_found_widget.dart';
import '../models/dashboard_preview_content.dart';

class DashboardLoadingView extends StatelessWidget {
  const DashboardLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const Key('dashboard-loading'),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
      children: [
        CustomShimmer(
          width: MediaQuery.sizeOf(context).width,
          height: 166,
          borderRadius: 18,
        ),
        const SizedBox(height: 28),
        const CustomShimmer(width: 110, height: 14),
        const SizedBox(height: 14),
        const Row(
          children: [
            CustomShimmer(width: 58, height: 58, borderRadius: 16),
            SizedBox(width: 14),
            CustomShimmer(width: 58, height: 58, borderRadius: 16),
            SizedBox(width: 14),
            CustomShimmer(width: 58, height: 58, borderRadius: 16),
          ],
        ),
        const SizedBox(height: 30),
        const CustomShimmer(width: 100, height: 14),
        const SizedBox(height: 14),
        const Row(
          children: [
            Expanded(
              child: CustomShimmer(
                width: double.infinity,
                height: 150,
                borderRadius: 16,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: CustomShimmer(
                width: double.infinity,
                height: 150,
                borderRadius: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(
              child: CustomShimmer(
                width: double.infinity,
                height: 150,
                borderRadius: 16,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: CustomShimmer(
                width: double.infinity,
                height: 150,
                borderRadius: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DashboardEmptyView extends StatelessWidget {
  final VoidCallback onRetry;

  const DashboardEmptyView({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return _DashboardCenteredState(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NoDataFoundWidget(
            title: 'dashboard.states.empty_title'.tr(),
            message: 'dashboard.states.empty_message'.tr(),
            customIcon: Icon(
              Icons.dashboard_customize_outlined,
              size: 72,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.34),
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('dashboard.states.retry'.tr()),
          ),
        ],
      ),
    );
  }
}

class DashboardFailureView extends StatelessWidget {
  final VoidCallback onRetry;

  const DashboardFailureView({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return _DashboardCenteredState(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: colors.error),
            const SizedBox(height: 18),
            Text(
              'dashboard.states.failure_title'.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'dashboard.states.failure_message'.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.62),
              ),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text('dashboard.states.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardPartialBanner extends StatelessWidget {
  final List<DashboardSection> unavailableSections;

  const DashboardPartialBanner({super.key, required this.unavailableSections});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            colors.error.withValues(alpha: 0.06),
            colors.surface,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.error.withValues(alpha: 0.16)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded, color: colors.error, size: 21),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'dashboard.states.partial_message'.tr(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.72),
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCenteredState extends StatelessWidget {
  final Widget child;

  const _DashboardCenteredState({required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: child,
        ),
      ),
    );
  }
}
