import '../../domain/entities/workshop_user_entity.dart';

class WorkshopUserModel extends WorkshopUserEntity {
  const WorkshopUserModel();

  factory WorkshopUserModel.fromJson(Map<String, dynamic> json) {
    return const WorkshopUserModel();
  }

  Map<String, dynamic> toJson() {
    return {};
  }
}
