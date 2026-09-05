// lib/features/workshop_users_roles/data/datasources/workshop_users_roles_remote_data_source.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/workshop_user_model.dart';
import '../models/role_model.dart';
import '../models/workshop_model.dart';

abstract class WorkshopUsersRolesRemoteDataSource {
  Future<List<WorkshopUserModel>> getWorkshopUsers(String workshopId);
  Future<WorkshopModel?> getWorkshop(String workshopId);
  Future<WorkshopModel> createWorkshop(WorkshopModel workshop);
  Future<List<RoleModel>> getRoles(String workshopId);
  
  // ✅ جديد
  Future<WorkshopUserModel> createWorkshopUser(
    WorkshopUserModel user, {
    required String workerId,
  });
  
  // ✅ جديد
  Future<WorkshopUserModel?> getWorkshopUserByUserId(String userId);
}

class FirebaseWorkshopUsersRolesDataSource
    implements WorkshopUsersRolesRemoteDataSource {
  final FirebaseFirestore _firestore;

  const FirebaseWorkshopUsersRolesDataSource(this._firestore);

  @override
  Future<List<WorkshopUserModel>> getWorkshopUsers(String workshopId) async {
    final snapshot = await _firestore
        .collection('workshop_users')
        .where('workshopId', isEqualTo: workshopId)
        .get();

    return snapshot.docs
        .map((doc) => WorkshopUserModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<WorkshopModel?> getWorkshop(String workshopId) async {
    final doc = await _firestore.collection('workshops').doc(workshopId).get();
    if (!doc.exists) return null;
    return WorkshopModel.fromJson(doc.data()!);
  }

  @override
  Future<WorkshopModel> createWorkshop(WorkshopModel workshop) async {
    final docRef = await _firestore.collection('workshops').add(workshop.toJson());
    final doc = await docRef.get();
    return WorkshopModel.fromJson(doc.data()!);
  }

  @override
  Future<List<RoleModel>> getRoles(String workshopId) async {
    final snapshot = await _firestore
        .collection('roles')
        .where('workshopId', isEqualTo: workshopId)
        .get();

    return snapshot.docs
        .map((doc) => RoleModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<WorkshopUserModel> createWorkshopUser(
    WorkshopUserModel user, {
    required String workerId,
  }) async {
    final data = user.toFirestore();
    data['workerId'] = workerId;

    final docRef = await _firestore.collection('workshop_users').add(data);
    final doc = await docRef.get();

    return WorkshopUserModel.fromFirestore(doc);
  }

  @override
  Future<WorkshopUserModel?> getWorkshopUserByUserId(String userId) async {
    final snapshot = await _firestore
        .collection('workshop_users')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return WorkshopUserModel.fromFirestore(snapshot.docs.first);
  }
}