import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../models/dashboard_preview_content.dart';
import 'dashboard_overview_and_actions.dart';

class DashboardOperationsSection extends StatelessWidget {
  final List<DashboardMetricPreview> metrics;
  final bool isSourcePreview;

  const DashboardOperationsSection({
    super.key,
    required this.metrics,
    required this.isSourcePreview,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashboardSectionHeading(
          titleKey: 'dashboard.operations.title',
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              (isSourcePreview
                      ? 'dashboard.operations.live_preview'
                      : 'dashboard.operations.live_updates')
                  .tr(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.35,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = 12.0;
            final useSingleColumn = constraints.maxWidth < 300;
            final itemWidth = useSingleColumn
                ? constraints.maxWidth
                : (constraints.maxWidth - gap) / 2;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final metric in metrics)
                  SizedBox(
                    width: itemWidth,
                    height: 156,
                    child: _DashboardMetricCard(metric: metric),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _DashboardMetricCard extends StatelessWidget {
  final DashboardMetricPreview metric;

  const _DashboardMetricCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    final spec = _MetricSpec.fromKind(metric.kind);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final background = isDark
        ? Color.alphaBlend(spec.tint.withValues(alpha: 0.1), colors.surface)
        : spec.background;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? colors.outline.withValues(alpha: 0.3)
              : const Color(0xFFE9E7EC),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withValues(alpha: 0.08),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Icon(spec.icon, color: spec.tint, size: 21),
                ),
                const Spacer(),
                if (metric.displayDelta case final delta?)
                  Directionality(
                    textDirection: ui.TextDirection.ltr,
                    child: Text(
                      '↗ $delta',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF20A35A),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              spec.labelKey.tr(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.66),
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Directionality(
              textDirection: ui.TextDirection.ltr,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  metric.displayValue,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              spec.supportingKey.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.55),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricSpec {
  final String labelKey;
  final String supportingKey;
  final IconData icon;
  final Color tint;
  final Color background;

  const _MetricSpec({
    required this.labelKey,
    required this.supportingKey,
    required this.icon,
    required this.tint,
    required this.background,
  });

  factory _MetricSpec.fromKind(DashboardMetricKind kind) {
    return switch (kind) {
      DashboardMetricKind.todaysOrders => const _MetricSpec(
        labelKey: 'dashboard.operations.todays_orders',
        supportingKey: 'dashboard.operations.pending_pickup',
        icon: Icons.trending_up_rounded,
        tint: Color(0xFF6D52B8),
        background: Color(0xFFF4F1F8),
      ),
      DashboardMetricKind.lateOrders => const _MetricSpec(
        labelKey: 'dashboard.operations.late_orders',
        supportingKey: 'dashboard.operations.action_required',
        icon: Icons.warning_amber_rounded,
        tint: Color(0xFFD04B43),
        background: Color(0xFFF9F1F1),
      ),
      DashboardMetricKind.inProgress => const _MetricSpec(
        labelKey: 'dashboard.operations.in_progress',
        supportingKey: 'dashboard.operations.workshop_floor',
        icon: Icons.schedule_rounded,
        tint: Color(0xFF6B6B73),
        background: Color(0xFFF8F8FA),
      ),
      DashboardMetricKind.lowStock => const _MetricSpec(
        labelKey: 'dashboard.operations.low_stock',
        supportingKey: 'dashboard.operations.aluminum_extrusions',
        icon: Icons.inventory_2_outlined,
        tint: Color(0xFFD04B43),
        background: Color(0xFFF9F1F1),
      ),
    };
  }
}
