import 'package:equatable/equatable.dart';

import '../models/dashboard_preview_content.dart';

enum DashboardLoadStatus { initial, loading, loaded, empty, partial, failure }

enum DashboardFailureReason { unavailable }

class DashboardActionNotice extends Equatable {
  final int id;
  final DashboardAction action;

  const DashboardActionNotice({required this.id, required this.action});

  @override
  List<Object?> get props => [id, action];
}

class DashboardState extends Equatable {
  final DashboardLoadStatus status;
  final DashboardPreviewContent? content;
  final List<DashboardSection> unavailableSections;
  final DashboardFailureReason? failureReason;
  final DashboardActionNotice? actionNotice;
  final bool isSourcePreview;

  const DashboardState._({
    required this.status,
    this.content,
    this.unavailableSections = const [],
    this.failureReason,
    this.actionNotice,
    this.isSourcePreview = false,
  });

  const DashboardState.initial() : this._(status: DashboardLoadStatus.initial);

  const DashboardState.loading() : this._(status: DashboardLoadStatus.loading);

  const DashboardState.preview(DashboardPreviewContent content)
    : this._(
        status: DashboardLoadStatus.loaded,
        content: content,
        isSourcePreview: true,
      );

  const DashboardState.empty() : this._(status: DashboardLoadStatus.empty);

  const DashboardState.partial({
    required DashboardPreviewContent content,
    required List<DashboardSection> unavailableSections,
  }) : this._(
         status: DashboardLoadStatus.partial,
         content: content,
         unavailableSections: unavailableSections,
         isSourcePreview: true,
       );

  const DashboardState.failure(DashboardFailureReason reason)
    : this._(status: DashboardLoadStatus.failure, failureReason: reason);

  DashboardState withActionNotice(DashboardActionNotice notice) {
    return DashboardState._(
      status: status,
      content: content,
      unavailableSections: unavailableSections,
      failureReason: failureReason,
      actionNotice: notice,
      isSourcePreview: isSourcePreview,
    );
  }

  @override
  List<Object?> get props => [
    status,
    content,
    unavailableSections,
    failureReason,
    actionNotice,
    isSourcePreview,
  ];
}
