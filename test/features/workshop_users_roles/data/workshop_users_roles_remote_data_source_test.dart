// test/features/workshop_users_roles/data/workshop_users_roles_remote_data_source_test.dart

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

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late MockFirebaseFirestore firestore;
  late FirebaseWorkshopUsersRolesDataSource dataSource;

  setUp(() {
    firestore = MockFirebaseFirestore();
    dataSource = FirebaseWorkshopUsersRolesDataSource(firestore);
  });

  group('getRoles', () {
    test('returns roles from the root roles collection', () async {
      final rolesCollection = MockCollectionReference();
      final snapshot = MockQuerySnapshot();
      final roleDocument = MockQueryDocumentSnapshot();

      when(
        () => firestore.collection('roles'),
      ).thenReturn(rolesCollection);

      when(
        () => rolesCollection.where(
          'workshopId',
          isEqualTo: 'workshop-1',
        ),
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
        'permissions': <String>[],
        'isSystemRole': false,
        'createdAt': '2026-01-01T00:00:00.000Z',
        'updatedAt': '2026-01-01T00:00:00.000Z',
      });

      final result = await dataSource.getRoles('workshop-1');

      expect(result, hasLength(1));
      expect(result.first.id, 'role-1');
      expect(result.first.workshopId, 'workshop-1');
      expect(result.first.name, 'Manager');

      verify(
        () => firestore.collection('roles'),
      ).called(1);

      verify(
        () => rolesCollection.where(
          'workshopId',
          isEqualTo: 'workshop-1',
        ),
      ).called(1);

      verify(
        () => rolesCollection.get(),
      ).called(1);
    });
  });

  group('createRole', () {
    test(
      'creates role in the root collection and returns generated id',
      () async {
        final rolesCollection = MockCollectionReference();
        final roleDocument = MockDocumentReference();
        final persistedSnapshot = MockDocumentSnapshot();

        when(
          () => firestore.collection('roles'),
        ).thenReturn(rolesCollection);

        when(
          () => rolesCollection.add(any()),
        ).thenAnswer(
          (_) async => roleDocument,
        );

        when(
          () => roleDocument.id,
        ).thenReturn('generated-role-id');

        when(
          () => roleDocument.get(),
        ).thenAnswer(
          (_) async => persistedSnapshot,
        );

        when(
          () => persistedSnapshot.id,
        ).thenReturn('generated-role-id');

        when(
          () => persistedSnapshot.exists,
        ).thenReturn(true);

        when(
          () => persistedSnapshot.data(),
        ).thenReturn({
          'workshopId': 'workshop-1',
          'name': 'Worker',
          'description': 'Workshop worker',
          'permissions': <String>[],
          'isSystemRole': false,
          'createdAt': '2026-01-01T00:00:00.000Z',
          'updatedAt': '2026-01-01T00:00:00.000Z',
        });

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

        final expectedData = role.toJson()..remove('id');

        final result = await dataSource.createRole(role);

        expect(result.id, 'generated-role-id');
        expect(result.workshopId, 'workshop-1');
        expect(result.name, 'Worker');

        verify(
          () => rolesCollection.add(expectedData),
        ).called(1);

        verify(
          () => roleDocument.get(),
        ).called(1);
      },
    );
  });

  group('updateRole', () {
    test(
      'updates role in the root collection and returns persisted role',
      () async {
        final rolesCollection = MockCollectionReference();
        final roleDocument = MockDocumentReference();
        final persistedSnapshot = MockDocumentSnapshot();

        when(
          () => firestore.collection('roles'),
        ).thenReturn(rolesCollection);

        when(
          () => rolesCollection.doc('role-1'),
        ).thenReturn(roleDocument);

        when(
          () => roleDocument.set(
            any(),
            any(),
          ),
        ).thenAnswer(
          (_) async {},
        );

        when(
          () => roleDocument.get(),
        ).thenAnswer(
          (_) async => persistedSnapshot,
        );

        when(
          () => persistedSnapshot.id,
        ).thenReturn('role-1');

        when(
          () => persistedSnapshot.exists,
        ).thenReturn(true);

        when(
          () => persistedSnapshot.data(),
        ).thenReturn({
          'workshopId': 'workshop-1',
          'name': 'Updated Worker',
          'description': 'Updated description',
          'permissions': <String>[],
          'isSystemRole': false,
          'createdAt': '2026-01-01T00:00:00.000Z',
          'updatedAt': '2026-01-02T00:00:00.000Z',
        });

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

        final expectedData = role.toJson()..remove('id');

        final result = await dataSource.updateRole(role);

        expect(result.id, 'role-1');
        expect(result.workshopId, 'workshop-1');
        expect(result.name, 'Updated Worker');
        expect(result.description, 'Updated description');

        verify(
          () => rolesCollection.doc('role-1'),
        ).called(1);

        verify(
          () => roleDocument.set(
            expectedData,
            any(
              that: isA<SetOptions>(),
            ),
          ),
        ).called(1);

        verify(
          () => roleDocument.get(),
        ).called(1);
      },
    );
  });

  group('deleteRole', () {
    test(
      'deletes role when it belongs to the requested workshop',
      () async {
        final rolesCollection = MockCollectionReference();
        final roleDocument = MockDocumentReference();
        final roleSnapshot = MockDocumentSnapshot();

        when(
          () => firestore.collection('roles'),
        ).thenReturn(rolesCollection);

        when(
          () => rolesCollection.doc('role-1'),
        ).thenReturn(roleDocument);

        when(
          () => roleDocument.get(),
        ).thenAnswer(
          (_) async => roleSnapshot,
        );

        when(
          () => roleSnapshot.exists,
        ).thenReturn(true);

        when(
          () => roleSnapshot.data(),
        ).thenReturn({
          'workshopId': 'workshop-1',
          'name': 'Worker',
          'description': 'Workshop worker',
          'permissions': <String>[],
          'isSystemRole': false,
          'createdAt': '2026-01-01T00:00:00.000Z',
          'updatedAt': '2026-01-01T00:00:00.000Z',
        });

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
          () => firestore.collection('roles'),
        ).called(1);

        verify(
          () => rolesCollection.doc('role-1'),
        ).called(1);

        verify(
          () => roleDocument.get(),
        ).called(1);

        verify(
          () => roleDocument.delete(),
        ).called(1);
      },
    );

    test(
      'does not delete a role belonging to another workshop',
      () async {
        final rolesCollection = MockCollectionReference();
        final roleDocument = MockDocumentReference();
        final roleSnapshot = MockDocumentSnapshot();

        when(
          () => firestore.collection('roles'),
        ).thenReturn(rolesCollection);

        when(
          () => rolesCollection.doc('role-1'),
        ).thenReturn(roleDocument);

        when(
          () => roleDocument.get(),
        ).thenAnswer(
          (_) async => roleSnapshot,
        );

        when(
          () => roleSnapshot.exists,
        ).thenReturn(true);

        when(
          () => roleSnapshot.data(),
        ).thenReturn({
          'workshopId': 'another-workshop',
          'name': 'Worker',
          'description': 'Workshop worker',
          'permissions': <String>[],
          'isSystemRole': false,
          'createdAt': '2026-01-01T00:00:00.000Z',
          'updatedAt': '2026-01-01T00:00:00.000Z',
        });

        expect(
          () => dataSource.deleteRole(
            'workshop-1',
            'role-1',
          ),
          throwsStateError,
        );

        verifyNever(
          () => roleDocument.delete(),
        );
      },
    );
  });
}