// lib/features/authentication/data/datasources/auth_remote_data_source.dart

import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/auth_user_entity.dart';

abstract class AuthRemoteDataSource {
  Future<AuthUserEntity> login({
    required String email,
    required String password,
  });

  Future<AuthUserEntity> register({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> sendPasswordResetEmail(String email);
  Future<void> logout();
  Future<AuthUserEntity?> getCurrentUser();
  Stream<AuthUserEntity?> observeAuthState();

  // ✅ جديد: إنشاء مستخدم للعامل
  Future<AuthUserEntity> createUserWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  // ✅ جديد: حذف مستخدم
  Future<void> deleteUser(String userId);
}

class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;

  const FirebaseAuthRemoteDataSource(this._firebaseAuth);

  @override
  Future<AuthUserEntity> login({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _toEntity(credential.user!);
  }

  @override
  Future<AuthUserEntity> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(displayName);
    await credential.user?.reload();
    return _toEntity(_firebaseAuth.currentUser!);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<AuthUserEntity?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    return user != null ? _toEntity(user) : null;
  }

  @override
  Stream<AuthUserEntity?> observeAuthState() {
    return _firebaseAuth.authStateChanges().map((user) {
      return user != null ? _toEntity(user) : null;
    });
  }

  @override
  Future<AuthUserEntity> createUserWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(displayName);
    await credential.user?.reload();
    return _toEntity(_firebaseAuth.currentUser!);
  }

  @override
  Future<void> deleteUser(String userId) async {
    final user = _firebaseAuth.currentUser;
    if (user != null && user.uid == userId) {
      await user.delete();
    }
  }

  AuthUserEntity _toEntity(User user) {
    return AuthUserEntity(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      isEmailVerified: user.emailVerified,
    );
  }
}