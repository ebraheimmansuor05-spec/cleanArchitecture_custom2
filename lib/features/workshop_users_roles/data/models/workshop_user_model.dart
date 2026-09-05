// lib/features/workshop_users_roles/data/models/workshop_user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/workshop_user_entity.dart';
import '../../domain/enums/workshop_member_status.dart';

class WorkshopUserModel extends WorkshopUserEntity {
  const WorkshopUserModel({
    required super.id,
    required super.workshopId,
    required super.userId,
    required super.roleId,
    required super.status,
    required super.joinedAt,
    super.workerId,
  });

  factory WorkshopUserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    if (data == null) {
      throw StateError('Workshop user document does not contain data.');
    }

    return WorkshopUserModel(
      id: document.id,
      workshopId: data['workshopId'] as String,
      userId: data['userId'] as String,
      roleId: data['roleId'] as String,
      status: WorkshopMemberStatus.values.byName(
        data['status'] as String,
      ),
      joinedAt: (data['joinedAt'] as Timestamp).toDate(),
      workerId: data['workerId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'workshopId': workshopId,
      'userId': userId,
      'roleId': roleId,
      'status': status.name,
      'joinedAt': Timestamp.fromDate(joinedAt),
      if (workerId != null) 'workerId': workerId,
    };
  }

  WorkshopUserEntity toEntity() {
    return WorkshopUserEntity(
      id: id,
      workshopId: workshopId,
      userId: userId,
      roleId: roleId,
      status: status,
      joinedAt: joinedAt,
      workerId: workerId,
    );
  }
}