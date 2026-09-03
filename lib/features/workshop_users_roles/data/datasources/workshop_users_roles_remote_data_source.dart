import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/role_model.dart';
import '../models/workshop_model.dart';
import '../models/workshop_user_model.dart';

abstract class WorkshopUsersRolesRemoteDataSource {
  Future<List<WorkshopUserModel>> fetchWorkshopUsers(
    String workshopId,
  );

  Future<List<RoleModel>> fetchRoles(
    String workshopId,
  );

  Future<RoleModel> createRole(
    RoleModel role,
  );

  Future<RoleModel> updateRole(
    RoleModel role,
  );

  Future<void> deleteRole(
    String workshopId,
    String roleId,
  );

  Future<WorkshopModel> createWorkshop(
    WorkshopModel workshop,
  );

  Future<WorkshopModel> getWorkshop(
    String workshopId,
  );
}

class WorkshopUsersRolesRemoteDataSourceImpl
    implements WorkshopUsersRolesRemoteDataSource {
  final FirebaseFirestore _firestore;

  WorkshopUsersRolesRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<WorkshopUserModel>> fetchWorkshopUsers(
    String workshopId,
  ) async {
    final snapshot = await _firestore
        .collection('workshops')
        .doc(workshopId)
        .collection('members')
        .get();

    return snapshot.docs
        .map(
          (doc) => WorkshopUserModel.fromJson({
            ...doc.data(),
            'id': doc.id,
          }),
        )
        .toList();
  }

  @override
  Future<List<RoleModel>> fetchRoles(
    String workshopId,
  ) async {
    final snapshot = await _firestore
        .collection('workshops')
        .doc(workshopId)
        .collection('roles')
        .get();

    return snapshot.docs
        .map(
          (doc) => RoleModel.fromJson({
            ...doc.data(),
            'id': doc.id,
          }),
        )
        .toList();
  }

  @override
  Future<RoleModel> createRole(
    RoleModel role,
  ) async {
    final doc = await _firestore
        .collection('workshops')
        .doc(role.workshopId)
        .collection('roles')
        .add(role.toJson());

    return RoleModel.fromJson({
      ...role.toJson(),
      'id': doc.id,
    });
  }

  @override
  Future<RoleModel> updateRole(
    RoleModel role,
  ) async {
    await _firestore
        .collection('workshops')
        .doc(role.workshopId)
        .collection('roles')
        .doc(role.id)
        .update(role.toJson());

    return role;
  }

  @override
  Future<void> deleteRole(
    String workshopId,
    String roleId,
  ) {
    return _firestore
        .collection('workshops')
        .doc(workshopId)
        .collection('roles')
        .doc(roleId)
        .delete();
  }

  @override
  Future<WorkshopModel> createWorkshop(
    WorkshopModel workshop,
  ) async {
    final doc = await _firestore
        .collection('workshops')
        .add(workshop.toJson());

    return WorkshopModel.fromJson({
      ...workshop.toJson(),
      'id': doc.id,
    });
  }

  @override
  Future<WorkshopModel> getWorkshop(
    String workshopId,
  ) async {
    final doc = await _firestore
        .collection('workshops')
        .doc(workshopId)
        .get();

    if (!doc.exists || doc.data() == null) {
      throw StateError('Workshop not found.');
    }

    return WorkshopModel.fromJson({
      ...doc.data()!,
      'id': doc.id,
    });
  }
}