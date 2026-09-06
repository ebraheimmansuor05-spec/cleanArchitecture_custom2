// lib/features/authentication/data/datasources/auth_remote_data_source.dart

import 'package:firebase_auth/firebase_auth.dart';

import '../models/auth_user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthUserModel> login({
    required String email,
    required String password,
  });

  Future<AuthUserModel> register({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> sendPasswordResetEmail(String email);
  Future<void> logout();
  Future<AuthUserModel?> getCurrentUser();
  Stream<AuthUserModel?> observeAuthState();

  // إنشاء مستخدم للعامل.
  // سيبقى موجودًا حاليًا حتى نعيد بناء Worker Creation
  // بشكل آمن في طبقة الـbackend.
  Future<AuthUserModel> createUserWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> deleteUser(String userId);
}

class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;

  const FirebaseAuthRemoteDataSource(this._firebaseAuth);

  @override
  Future<AuthUserModel> login({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'لم يتم العثور على المستخدم بعد تسجيل الدخول.',
      );
    }

    return AuthUserModel.fromFirebaseUser(user);
  }

  @override
  Future<AuthUserModel> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'تعذر إنشاء حساب المستخدم.',
      );
    }

    await user.updateDisplayName(displayName);
    await user.reload();

    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'تعذر استرجاع المستخدم بعد إنشاء الحساب.',
      );
    }

    return AuthUserModel.fromFirebaseUser(currentUser);
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
  Future<AuthUserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;

    return user != null ? AuthUserModel.fromFirebaseUser(user) : null;
  }

  @override
  Stream<AuthUserModel?> observeAuthState() {
    return _firebaseAuth.authStateChanges().map(
      (user) => user != null ? AuthUserModel.fromFirebaseUser(user) : null,
    );
  }

  @override
  Future<AuthUserModel> createUserWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'تعذر إنشاء حساب العامل.',
      );
    }

    await user.updateDisplayName(displayName);
    await user.reload();

    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'تعذر استرجاع المستخدم بعد إنشاء الحساب.',
      );
    }

    return AuthUserModel.fromFirebaseUser(currentUser);
  }

  @override
  Future<void> deleteUser(String userId) async {
    final user = _firebaseAuth.currentUser;

    if (user != null && user.uid == userId) {
      await user.delete();
    }
  }
}