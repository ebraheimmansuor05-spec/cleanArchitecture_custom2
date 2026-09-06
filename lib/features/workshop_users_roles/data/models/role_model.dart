import '../../domain/entities/role_entity.dart';
import '../../domain/enums/permission.dart';

class RoleModel extends RoleEntity {
  const RoleModel({
    required super.id,
    required super.workshopId,
    required super.name,
    required super.description,
    required super.permissions,
    required super.isSystemRole,
    required super.createdAt,
    required super.updatedAt,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] as String,
      workshopId: json['workshopId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      permissions: (json['permissions'] as List<dynamic>)
          .map(
            (permission) => Permission.values.byName(permission as String),
          )
          .toList(),
      isSystemRole: json['isSystemRole'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workshopId': workshopId,
      'name': name,
      'description': description,
      'permissions': permissions.map((permission) => permission.name).toList(),
      'isSystemRole': isSystemRole,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}