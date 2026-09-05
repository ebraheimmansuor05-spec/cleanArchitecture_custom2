import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../models/dashboard_preview_content.dart';

class DashboardSectionHeading extends StatelessWidget {
  final String titleKey;
  final Widget? trailing;

  const DashboardSectionHeading({
    super.key,
    required this.titleKey,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final title = Text(
      titleKey.tr(),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.62),
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (trailing != null && constraints.maxWidth < 360) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              title,
              const SizedBox(height: 8),
              Align(alignment: AlignmentDirectional.centerEnd, child: trailing),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: title),
            ?trailing,
          ],
        );
      },
    );
  }
}

class DashboardOverviewCard extends StatelessWidget {
  const DashboardOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.16),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            colors.primary.withValues(alpha: 0.9),
            const Color(0xFF232238),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.loose,
        children: [
          PositionedDirectional(
            end: -18,
            top: -26,
            child: Icon(
              Icons.factory_outlined,
              size: 180,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          PositionedDirectional(
            end: 34,
            top: 34,
            child: Icon(
              Icons.query_stats_rounded,
              size: 66,
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: AlignmentDirectional.topCenter,
                  end: AlignmentDirectional.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.58),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 126),
              child: Align(
                alignment: AlignmentDirectional.bottomStart,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'dashboard.workshop_overview'.tr(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'dashboard.workshop_overview_subtitle'.tr(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardQuickActions extends StatelessWidget {
  final ValueChanged<DashboardAction> onAction;

  const DashboardQuickActions({super.key, required this.onAction});

  static const _items = [
    _QuickActionItem(
      action: DashboardAction.newOrder,
      icon: Icons.add_rounded,
      background: Color(0xFF6D52B8),
      foreground: Colors.white,
    ),
    _QuickActionItem(
      action: DashboardAction.inventory,
      icon: Icons.inventory_2_outlined,
      background: Color(0xFF605A72),
      foreground: Colors.white,
    ),
    _QuickActionItem(
      action: DashboardAction.logs,
      icon: Icons.monitor_heart_outlined,
      background: Color(0xFF34323A),
      foreground: Colors.white,
    ),
    _QuickActionItem(
      action: DashboardAction.employees,
      icon: Icons.group_outlined,
      background: Color(0xFFE9E4F9),
      foreground: Color(0xFF5B3B9F),
    ),
    _QuickActionItem(
      action: DashboardAction.payment,
      icon: Icons.attach_money_rounded,
      background: Color(0xFF2FA557),
      foreground: Colors.white,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DashboardSectionHeading(titleKey: 'dashboard.quick_actions'),
        const SizedBox(height: 14),
        SizedBox(
          height: 102,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final item = _items[index];
              return SizedBox(
                width: 70,
                child: _QuickActionButton(
                  item: item,
                  onPressed: () => onAction(item.action),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _QuickActionItem {
  final DashboardAction action;
  final IconData icon;
  final Color background;
  final Color foreground;

  const _QuickActionItem({
    required this.action,
    required this.icon,
    required this.background,
    required this.foreground,
  });
}

class _QuickActionButton extends StatelessWidget {
  final _QuickActionItem item;
  final VoidCallback onPressed;

  const _QuickActionButton({required this.item, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final label = item.action.labelKey.tr();

    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: item.background,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: item.background.withValues(alpha: 0.2),
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Icon(item.icon, color: item.foreground, size: 27),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.05,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
