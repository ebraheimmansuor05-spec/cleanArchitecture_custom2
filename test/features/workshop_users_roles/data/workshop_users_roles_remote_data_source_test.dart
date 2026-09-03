// ignore_for_file: subtype_of_sealed_class

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_clean_architecture_template/features/workshop_users_roles/data/datasources/workshop_users_roles_remote_data_source.dart';
import 'package:flutter_clean_architecture_template/features/workshop_users_roles/data/models/role_model.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late MockFirebaseFirestore firestore;
  late WorkshopUsersRolesRemoteDataSourceImpl dataSource;

  setUp(() {
    firestore = MockFirebaseFirestore();
    dataSource = WorkshopUsersRolesRemoteDataSourceImpl(firestore);
  });

  group('fetchRoles', () {
    test('returns roles from Firestore', () async {
      final workshopsCollection = MockCollectionReference();
      final workshopDocument = MockDocumentReference();
      final rolesCollection = MockCollectionReference();
      final snapshot = MockQuerySnapshot();
      final roleDocument = MockQueryDocumentSnapshot();

      when(
        () => firestore.collection('workshops'),
      ).thenReturn(workshopsCollection);

      when(
        () => workshopsCollection.doc('workshop-1'),
      ).thenReturn(workshopDocument);

      when(
        () => workshopDocument.collection('roles'),
      ).thenReturn(rolesCollection);

      when(
        () => rolesCollection.get(),
      ).thenAnswer(
        (_) async => snapshot,
      );

      when(
        () => snapshot.docs,
      ).thenReturn([roleDocument]);

      when(
        () => roleDocument.id,
      ).thenReturn('role-1');

      when(
        () => roleDocument.data(),
      ).thenReturn({
        'workshopId': 'workshop-1',
        'name': 'Manager',
        'description': 'Workshop manager',
        'permissions': [],
        'isSystemRole': false,
       'createdAt': '2026-01-01T00:00:00.000Z',
'updatedAt': '2026-01-01T00:00:00.000Z',
      });

      final result = await dataSource.fetchRoles('workshop-1');

      expect(result, hasLength(1));
      expect(result.first.id, 'role-1');
      expect(result.first.name, 'Manager');

      verify(
        () => firestore.collection('workshops'),
      ).called(1);

      verify(
        () => workshopsCollection.doc('workshop-1'),
      ).called(1);

      verify(
        () => workshopDocument.collection('roles'),
      ).called(1);

      verify(
        () => rolesCollection.get(),
      ).called(1);
    });
  });

  group('createRole', () {
    test('creates role and returns role with generated id', () async {
      final workshopsCollection = MockCollectionReference();
      final workshopDocument = MockDocumentReference();
      final rolesCollection = MockCollectionReference();
      final roleDocument = MockDocumentReference();

      when(
        () => firestore.collection('workshops'),
      ).thenReturn(workshopsCollection);

      when(
        () => workshopsCollection.doc('workshop-1'),
      ).thenReturn(workshopDocument);

      when(
        () => workshopDocument.collection('roles'),
      ).thenReturn(rolesCollection);

      when(
        () => rolesCollection.add(any()),
      ).thenAnswer(
        (_) async => roleDocument,
      );

      when(
        () => roleDocument.id,
      ).thenReturn('generated-role-id');

      final role = RoleModel(
        id: '',
        workshopId: 'workshop-1',
        name: 'Worker',
        description: 'Workshop worker',
        permissions: const [],
        isSystemRole: false,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final result = await dataSource.createRole(role);

      expect(result.id, 'generated-role-id');
      expect(result.workshopId, 'workshop-1');
      expect(result.name, 'Worker');

      verify(
        () => rolesCollection.add(role.toJson()),
      ).called(1);
    });
  });

  group('updateRole', () {
    test('updates role and returns the same role', () async {
      final workshopsCollection = MockCollectionReference();
      final workshopDocument = MockDocumentReference();
      final rolesCollection = MockCollectionReference();
      final roleDocument = MockDocumentReference();

      when(
        () => firestore.collection('workshops'),
      ).thenReturn(workshopsCollection);

      when(
        () => workshopsCollection.doc('workshop-1'),
      ).thenReturn(workshopDocument);

      when(
        () => workshopDocument.collection('roles'),
      ).thenReturn(rolesCollection);

      when(
        () => rolesCollection.doc('role-1'),
      ).thenReturn(roleDocument);

      when(
        () => roleDocument.update(any()),
      ).thenAnswer(
        (_) async {},
      );

      final role = RoleModel(
        id: 'role-1',
        workshopId: 'workshop-1',
        name: 'Updated Worker',
        description: 'Updated description',
        permissions: const [],
        isSystemRole: false,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 2),
      );

      final result = await dataSource.updateRole(role);

      expect(result, role);

      verify(
        () => roleDocument.update(role.toJson()),
      ).called(1);
    });
  });

  group('deleteRole', () {
    test('deletes role from Firestore', () async {
      final workshopsCollection = MockCollectionReference();
      final workshopDocument = MockDocumentReference();
      final rolesCollection = MockCollectionReference();
      final roleDocument = MockDocumentReference();

      when(
        () => firestore.collection('workshops'),
      ).thenReturn(workshopsCollection);

      when(
        () => workshopsCollection.doc('workshop-1'),
      ).thenReturn(workshopDocument);

      when(
        () => workshopDocument.collection('roles'),
      ).thenReturn(rolesCollection);

      when(
        () => rolesCollection.doc('role-1'),
      ).thenReturn(roleDocument);

      when(
        () => roleDocument.delete(),
      ).thenAnswer(
        (_) async {},
      );

      await dataSource.deleteRole(
        'workshop-1',
        'role-1',
      );

      verify(
        () => roleDocument.delete(),
      ).called(1);
    });
  });
}