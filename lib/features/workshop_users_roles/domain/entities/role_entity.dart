import 'package:equatable/equatable.dart';

import '../enums/permission.dart';

class RoleEntity extends Equatable {
  final String id;
  final String workshopId;
  final String name;
  final String description;
  final List<Permission> permissions;
  final bool isSystemRole;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RoleEntity({
    required this.id,
    required this.workshopId,
    required this.name,
    required this.description,
    required this.permissions,
    required this.isSystemRole,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        workshopId,
        name,
        description,
        permissions,
        isSystemRole,
        createdAt,
        updatedAt,
      ];
}