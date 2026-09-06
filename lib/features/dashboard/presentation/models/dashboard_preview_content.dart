import 'package:equatable/equatable.dart';

enum DashboardAction {
  menu,
  notifications,
  newOrder,
  inventory,
  logs,
  employees,
  payment,
  viewAllActivity,
  refill,
  primary,
  home,
  orders,
  production,
  stock,
  profile,
}

extension DashboardActionLocalization on DashboardAction {
  String get labelKey => switch (this) {
    DashboardAction.menu => 'dashboard.actions.menu',
    DashboardAction.notifications => 'dashboard.actions.notifications',
    DashboardAction.newOrder => 'dashboard.actions.new_order',
    DashboardAction.inventory => 'dashboard.actions.inventory',
    DashboardAction.logs => 'dashboard.actions.logs',
    DashboardAction.employees => 'dashboard.actions.employees',
    DashboardAction.payment => 'dashboard.actions.payment',
    DashboardAction.viewAllActivity => 'dashboard.actions.view_all',
    DashboardAction.refill => 'dashboard.actions.refill',
    DashboardAction.primary => 'dashboard.actions.primary',
    DashboardAction.home => 'dashboard.navigation.home',
    DashboardAction.orders => 'dashboard.navigation.orders',
    DashboardAction.production => 'dashboard.navigation.production',
    DashboardAction.stock => 'dashboard.navigation.stock',
    DashboardAction.profile => 'dashboard.navigation.profile',
  };
}

enum DashboardMetricKind { todaysOrders, lateOrders, inProgress, lowStock }

enum DashboardActivityKind {
  weldingCompleted,
  measurementsUpdated,
  productionStarted,
}

enum DashboardSection { operations, financial, workerActivity, inventoryAlert }

/// Display-only values copied from the approved Dashboard reference screen.
///
/// These values are deliberately kept in Presentation and must never be treated
/// as connected workshop data or as business calculations.
class DashboardPreviewContent extends Equatable {
  final List<DashboardMetricPreview> metrics;
  final DashboardFinancialPreview financial;
  final List<DashboardActivityPreview> activities;
  final DashboardInventoryAlertPreview inventoryAlert;

  const DashboardPreviewContent({
    required this.metrics,
    required this.financial,
    required this.activities,
    required this.inventoryAlert,
  });

  const DashboardPreviewContent.fromApprovedDesign()
    : metrics = const [
        DashboardMetricPreview(
          kind: DashboardMetricKind.todaysOrders,
          displayValue: '12',
          displayDelta: '+2',
        ),
        DashboardMetricPreview(
          kind: DashboardMetricKind.lateOrders,
          displayValue: '03',
        ),
        DashboardMetricPreview(
          kind: DashboardMetricKind.inProgress,
          displayValue: '28',
        ),
        DashboardMetricPreview(
          kind: DashboardMetricKind.lowStock,
          displayValue: '05',
        ),
      ],
      financial = const DashboardFinancialPreview(
        revenueDisplayValue: r'$42,850',
        pendingPaymentsDisplayValue: r'$12,400',
        revenueGoalDisplayValue: '85%',
        revenueGoalProgress: 0.85,
      ),
      activities = const [
        DashboardActivityPreview(
          kind: DashboardActivityKind.weldingCompleted,
          workerName: 'Marcus Chen',
          timeKey: 'dashboard.activity.time_12m',
        ),
        DashboardActivityPreview(
          kind: DashboardActivityKind.measurementsUpdated,
          workerName: 'Sarah Miller',
          timeKey: 'dashboard.activity.time_45m',
        ),
        DashboardActivityPreview(
          kind: DashboardActivityKind.productionStarted,
          workerName: 'David K.',
          timeKey: 'dashboard.activity.time_1h',
        ),
      ],
      inventoryAlert = const DashboardInventoryAlertPreview(itemCount: 3);

  @override
  List<Object?> get props => [metrics, financial, activities, inventoryAlert];
}

class DashboardMetricPreview extends Equatable {
  final DashboardMetricKind kind;
  final String displayValue;
  final String? displayDelta;

  const DashboardMetricPreview({
    required this.kind,
    required this.displayValue,
    this.displayDelta,
  });

  @override
  List<Object?> get props => [kind, displayValue, displayDelta];
}

class DashboardFinancialPreview extends Equatable {
  final String revenueDisplayValue;
  final String pendingPaymentsDisplayValue;
  final String revenueGoalDisplayValue;
  final double revenueGoalProgress;

  const DashboardFinancialPreview({
    required this.revenueDisplayValue,
    required this.pendingPaymentsDisplayValue,
    required this.revenueGoalDisplayValue,
    required this.revenueGoalProgress,
  });

  @override
  List<Object?> get props => [
    revenueDisplayValue,
    pendingPaymentsDisplayValue,
    revenueGoalDisplayValue,
    revenueGoalProgress,
  ];
}

class DashboardActivityPreview extends Equatable {
  final DashboardActivityKind kind;
  final String workerName;
  final String timeKey;

  const DashboardActivityPreview({
    required this.kind,
    required this.workerName,
    required this.timeKey,
  });

  @override
  List<Object?> get props => [kind, workerName, timeKey];
}

class DashboardInventoryAlertPreview extends Equatable {
  final int itemCount;

  const DashboardInventoryAlertPreview({required this.itemCount});

  @override
  List<Object?> get props => [itemCount];
}
