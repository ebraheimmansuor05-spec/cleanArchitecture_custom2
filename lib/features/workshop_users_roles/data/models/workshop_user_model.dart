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
      throw StateError(
        'Workshop user document does not contain data.',
      );
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

  factory WorkshopUserModel.fromMap(
    Map<String, dynamic> map,
  ) {
    final id = map['id'];
    final workshopId = map['workshopId'];
    final userId = map['userId'];
    final roleId = map['roleId'];
    final status = map['status'];
    final joinedAt = map['joinedAt'];
    final workerId = map['workerId'];

    if (id is! String || id.trim().isEmpty) {
      throw const FormatException(
        'Invalid workshop user id.',
      );
    }

    if (workshopId is! String || workshopId.trim().isEmpty) {
      throw const FormatException(
        'Invalid workshop id.',
      );
    }

    if (userId is! String || userId.trim().isEmpty) {
      throw const FormatException(
        'Invalid user id.',
      );
    }

    if (roleId is! String || roleId.trim().isEmpty) {
      throw const FormatException(
        'Invalid role id.',
      );
    }

    if (status is! String || status.trim().isEmpty) {
      throw const FormatException(
        'Invalid workshop member status.',
      );
    }

    final parsedStatus =
        WorkshopMemberStatus.values.firstWhere(
      (value) => value.name == status,
      orElse: () => throw FormatException(
        'Unknown workshop member status: $status',
      ),
    );

    final parsedJoinedAt = _parseJoinedAt(joinedAt);

    return WorkshopUserModel(
      id: id,
      workshopId: workshopId,
      userId: userId,
      roleId: roleId,
      status: parsedStatus,
      joinedAt: parsedJoinedAt,
      workerId: workerId is String ? workerId : null,
    );
  }

  static DateTime _parseJoinedAt(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      final parsed = DateTime.tryParse(value);

      if (parsed != null) {
        return parsed;
      }
    }

    if (value is Map) {
      final seconds =
          value['_seconds'] ?? value['seconds'];

      final nanoseconds =
          value['_nanoseconds'] ??
          value['nanoseconds'] ??
          0;

      if (seconds is num && nanoseconds is num) {
        return DateTime.fromMillisecondsSinceEpoch(
          seconds.toInt() * 1000 +
              (nanoseconds.toInt() ~/ 1000000),
        );
      }
    }

    throw const FormatException(
      'Invalid joinedAt value.',
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