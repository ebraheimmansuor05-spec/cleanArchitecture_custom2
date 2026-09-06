// lib/features/workshop_users_roles/domain/entities/workshop_user_entity.dart

import 'package:equatable/equatable.dart';

import '../enums/workshop_member_status.dart';

class WorkshopUserEntity extends Equatable {
  final String id;
  final String workshopId;
  final String userId;
  final String roleId;
  final WorkshopMemberStatus status;
  final DateTime joinedAt;
  final String? workerId;

  const WorkshopUserEntity({
    required this.id,
    required this.workshopId,
    required this.userId,
    required this.roleId,
    required this.status,
    required this.joinedAt,
    this.workerId,
  });

  @override
  List<Object?> get props => [
        id,
        workshopId,
        userId,
        roleId,
        status,
        joinedAt,
        workerId,
      ];
}