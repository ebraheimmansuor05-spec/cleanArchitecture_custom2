import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../models/dashboard_preview_content.dart';
import 'dashboard_overview_and_actions.dart';

class DashboardFinancialSummary extends StatelessWidget {
  final DashboardFinancialPreview data;

  const DashboardFinancialSummary({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'dashboard.financial.title'.tr(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(
                Icons.attach_money_rounded,
                color: colors.onSurface.withValues(alpha: 0.55),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'dashboard.financial.subtitle'.tr(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final revenue = _FinancialValue(
                labelKey: 'dashboard.financial.total_revenue',
                displayValue: data.revenueDisplayValue,
                valueColor: const Color(0xFF169B55),
              );
              final pending = _FinancialValue(
                labelKey: 'dashboard.financial.pending_payments',
                displayValue: data.pendingPaymentsDisplayValue,
                valueColor: const Color(0xFFBF352E),
              );

              if (constraints.maxWidth < 270) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [revenue, const SizedBox(height: 16), pending],
                );
              }

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: revenue),
                    VerticalDivider(color: theme.dividerColor, width: 28),
                    Expanded(child: pending),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Text(
                  'dashboard.financial.revenue_goal'.tr(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Directionality(
                textDirection: ui.TextDirection.ltr,
                child: Text(
                  '${data.revenueGoalDisplayValue} ${'dashboard.financial.achieved'.tr()}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: data.revenueGoalProgress,
              minHeight: 8,
              backgroundColor: colors.onSurface.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _FinancialValue extends StatelessWidget {
  final String labelKey;
  final String displayValue;
  final Color valueColor;

  const _FinancialValue({
    required this.labelKey,
    required this.displayValue,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          labelKey.tr(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 3),
        Directionality(
          textDirection: ui.TextDirection.ltr,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              displayValue,
              maxLines: 1,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DashboardWorkerActivitySection extends StatelessWidget {
  final List<DashboardActivityPreview> activities;
  final ValueChanged<DashboardAction> onAction;

  const DashboardWorkerActivitySection({
    super.key,
    required this.activities,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashboardSectionHeading(
          titleKey: 'dashboard.activity.title',
          trailing: TextButton.icon(
            onPressed: () => onAction(DashboardAction.viewAllActivity),
            label: Text('dashboard.actions.view_all'.tr()),
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.chevron_right_rounded, size: 18),
          ),
        ),
        const SizedBox(height: 8),
        for (var index = 0; index < activities.length; index++) ...[
          _ActivityTile(activity: activities[index], index: index),
          if (index != activities.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final DashboardActivityPreview activity;
  final int index;

  const _ActivityTile({required this.activity, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final avatarColors = [
      const Color(0xFFD9E5F8),
      const Color(0xFFE8E1FA),
      const Color(0xFFE1ECEB),
    ];

    return _DashboardCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: avatarColors[index % avatarColors.length],
                foregroundColor: colors.primary,
                child: const Icon(Icons.engineering_outlined, size: 25),
              ),
              PositionedDirectional(
                end: -1,
                bottom: 1,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF21B65D),
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.surface, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        activity.workerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      activity.timeKey.tr(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.52),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _activityMessageKey(activity.kind).tr(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.66),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _activityMessageKey(DashboardActivityKind kind) => switch (kind) {
    DashboardActivityKind.weldingCompleted =>
      'dashboard.activity.welding_completed',
    DashboardActivityKind.measurementsUpdated =>
      'dashboard.activity.measurements_updated',
    DashboardActivityKind.productionStarted =>
      'dashboard.activity.production_started',
  };
}

class DashboardInventoryAlert extends StatelessWidget {
  final DashboardInventoryAlertPreview data;
  final ValueChanged<DashboardAction> onAction;

  const DashboardInventoryAlert({
    super.key,
    required this.data,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final alertColor = colors.error;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          alertColor.withValues(alpha: 0.07),
          colors.surface,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: alertColor.withValues(alpha: 0.12)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 310;
          final content = Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: alertColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: alertColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'dashboard.inventory_alert.title'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: alertColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'dashboard.inventory_alert.message'.tr(
                        namedArgs: {'count': data.itemCount.toString()},
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.62),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final button = FilledButton(
            onPressed: () => onAction(DashboardAction.refill),
            style: FilledButton.styleFrom(
              backgroundColor: alertColor,
              foregroundColor: colors.onError,
              minimumSize: const Size(82, 46),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: Text('dashboard.actions.refill'.tr()),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [content, const SizedBox(height: 14), button],
            );
          }

          return Row(
            children: [
              Expanded(child: content),
              const SizedBox(width: 12),
              button,
            ],
          );
        },
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _DashboardCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
