import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../models/dashboard_preview_content.dart';

class DashboardHeader extends StatelessWidget implements PreferredSizeWidget {
  final ValueChanged<DashboardAction> onAction;

  const DashboardHeader({super.key, required this.onAction});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AppBar(
      toolbarHeight: preferredSize.height,
      centerTitle: true,
      leadingWidth: 64,
      leading: _HeaderAction(
        icon: Icons.menu_rounded,
        tooltip: DashboardAction.menu.labelKey.tr(),
        onPressed: () => onAction(DashboardAction.menu),
      ),
      title: Text(
        'dashboard.title'.tr(),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 8),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _HeaderAction(
                icon: Icons.notifications_none_rounded,
                tooltip: DashboardAction.notifications.labelKey.tr(),
                onPressed: () => onAction(DashboardAction.notifications),
              ),
              PositionedDirectional(
                end: 10,
                top: 10,
                child: Semantics(
                  label: 'dashboard.notifications_unread'.tr(),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.surface, width: 1.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _HeaderAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    );
  }
}

class DashboardBottomNavigation extends StatelessWidget {
  final ValueChanged<DashboardAction> onAction;

  const DashboardBottomNavigation({super.key, required this.onAction});

  static const _destinations = [
    _DashboardDestination(
      action: DashboardAction.home,
      icon: Icons.dashboard_rounded,
    ),
    _DashboardDestination(
      action: DashboardAction.orders,
      icon: Icons.receipt_long_outlined,
    ),
    _DashboardDestination(
      action: DashboardAction.production,
      icon: Icons.build_outlined,
    ),
    _DashboardDestination(
      action: DashboardAction.stock,
      icon: Icons.inventory_2_outlined,
    ),
    _DashboardDestination(
      action: DashboardAction.profile,
      icon: Icons.person_outline_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              for (final destination in _destinations)
                Expanded(
                  child: _DashboardNavigationItem(
                    destination: destination,
                    selected: destination.action == DashboardAction.home,
                    onTap: () => onAction(destination.action),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardDestination {
  final DashboardAction action;
  final IconData icon;

  const _DashboardDestination({required this.action, required this.icon});
}

class _DashboardNavigationItem extends StatelessWidget {
  final _DashboardDestination destination;
  final bool selected;
  final VoidCallback onTap;

  const _DashboardNavigationItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = selected
        ? colors.primary
        : colors.onSurface.withValues(alpha: 0.55);
    final label = destination.action.labelKey.tr();

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 7),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(destination.icon, size: 23, color: foreground),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: foreground,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
