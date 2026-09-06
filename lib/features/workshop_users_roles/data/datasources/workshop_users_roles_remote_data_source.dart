import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/role_model.dart';
import '../models/workshop_model.dart';
import '../models/workshop_user_model.dart';

abstract class WorkshopUsersRolesRemoteDataSource {
  Future<List<WorkshopUserModel>> getWorkshopUsers(String workshopId);

  Future<WorkshopModel?> getWorkshop(String workshopId);

  Future<WorkshopModel> createWorkshop(WorkshopModel workshop);

  Future<List<RoleModel>> getRoles(String workshopId);

  Future<RoleModel> createRole(RoleModel role);

  Future<RoleModel> updateRole(RoleModel role);

  Future<void> deleteRole(
    String workshopId,
    String roleId,
  );

  Future<WorkshopUserModel> createWorkshopUser(
    WorkshopUserModel user, {
    required String workerId,
  });

  Future<WorkshopUserModel?> getWorkshopUserByUserId(String userId);
}

class FirebaseWorkshopUsersRolesDataSource
    implements WorkshopUsersRolesRemoteDataSource {
  final FirebaseFirestore _firestore;

  const FirebaseWorkshopUsersRolesDataSource(this._firestore);

  @override
  Future<List<WorkshopUserModel>> getWorkshopUsers(
    String workshopId,
  ) async {
    final snapshot = await _firestore
        .collection('workshop_users')
        .where(
          'workshopId',
          isEqualTo: workshopId,
        )
        .get();

    return snapshot.docs
        .map(
          WorkshopUserModel.fromFirestore,
        )
        .toList();
  }

  @override
  Future<WorkshopModel?> getWorkshop(
    String workshopId,
  ) async {
    final doc = await _firestore
        .collection('workshops')
        .doc(workshopId)
        .get();

    if (!doc.exists) {
      return null;
    }

    final data = doc.data();

    if (data == null) {
      return null;
    }

    return WorkshopModel.fromJson({
      ...data,
      'id': doc.id,
    });
  }

  @override
  Future<WorkshopModel> createWorkshop(
    WorkshopModel workshop,
  ) async {
    final docRef = await _firestore
        .collection('workshops')
        .add(
          workshop.toJson(),
        );

    final doc = await docRef.get();

    final data = doc.data();

    if (data == null) {
      throw StateError(
        'Workshop document was created but no data was returned.',
      );
    }

    return WorkshopModel.fromJson({
      ...data,
      'id': doc.id,
    });
  }

  @override
  Future<List<RoleModel>> getRoles(
    String workshopId,
  ) async {
    final snapshot = await _firestore
        .collection('roles')
        .where(
          'workshopId',
          isEqualTo: workshopId,
        )
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
    final data = role.toJson();

    data.remove('id');

    final docRef = await _firestore
        .collection('roles')
        .add(data);

    final doc = await docRef.get();

    final persistedData = doc.data();

    if (persistedData == null) {
      throw StateError(
        'Role document was created but no data was returned.',
      );
    }

    return RoleModel.fromJson({
      ...persistedData,
      'id': doc.id,
    });
  }

  @override
  Future<RoleModel> updateRole(
    RoleModel role,
  ) async {
    if (role.id.trim().isEmpty) {
      throw ArgumentError(
        'Cannot update a role without a role id.',
      );
    }

    final docRef = _firestore
        .collection('roles')
        .doc(role.id);

    final data = role.toJson();

    data.remove('id');

    await docRef.set(
      data,
      SetOptions(merge: false),
    );

    final doc = await docRef.get();

    final persistedData = doc.data();

    if (!doc.exists || persistedData == null) {
      throw StateError(
        'Role was updated but could not be read afterwards.',
      );
    }

    return RoleModel.fromJson({
      ...persistedData,
      'id': doc.id,
    });
  }

  @override
  Future<void> deleteRole(
    String workshopId,
    String roleId,
  ) async {
    if (workshopId.trim().isEmpty) {
      throw ArgumentError(
        'Cannot delete a role without a workshop id.',
      );
    }

    if (roleId.trim().isEmpty) {
      throw ArgumentError(
        'Cannot delete a role without a role id.',
      );
    }

    final docRef = _firestore
        .collection('roles')
        .doc(roleId);

    final doc = await docRef.get();

    if (!doc.exists) {
      throw StateError(
        'Role does not exist.',
      );
    }

    final data = doc.data();

    if (data == null) {
      throw StateError(
        'Role document exists but contains no data.',
      );
    }

    if (data['workshopId'] != workshopId) {
      throw StateError(
        'Role does not belong to the requested workshop.',
      );
    }

    await docRef.delete();
  }

  @override
  Future<WorkshopUserModel> createWorkshopUser(
    WorkshopUserModel user, {
    required String workerId,
  }) async {
    final data = user.toFirestore();

    data['workerId'] = workerId;

    final docRef = await _firestore
        .collection('workshop_users')
        .add(data);

    final doc = await docRef.get();

    return WorkshopUserModel.fromFirestore(doc);
  }

  @override
  Future<WorkshopUserModel?> getWorkshopUserByUserId(
    String userId,
  ) async {
    final snapshot = await _firestore
        .collection('workshop_users')
        .where(
          'userId',
          isEqualTo: userId,
        )
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return WorkshopUserModel.fromFirestore(
      snapshot.docs.first,
    );
  }
}