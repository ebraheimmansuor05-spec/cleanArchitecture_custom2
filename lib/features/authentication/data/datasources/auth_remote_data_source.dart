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
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<void> logout();

  AuthUserModel? getCurrentUser();

  Stream<AuthUserModel?> observeAuthState();
}

class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;

  const FirebaseAuthRemoteDataSource(this.firebaseAuth);

  @override
  Future<AuthUserModel> login({
    required String email,
    required String password,
  }) async {
    final credential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw StateError('Authentication provider returned no user.');
    }
    return AuthUserModel.fromFirebaseUser(user);
  }

  @override
  Future<AuthUserModel> register({
    required String email,
    required String password,
  }) async {
    final credential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw StateError('Authentication provider returned no user.');
    }
    return AuthUserModel.fromFirebaseUser(user);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> logout() => firebaseAuth.signOut();

  @override
  AuthUserModel? getCurrentUser() {
    final user = firebaseAuth.currentUser;
    return user == null ? null : AuthUserModel.fromFirebaseUser(user);
  }

  @override
  Stream<AuthUserModel?> observeAuthState() {
    return firebaseAuth.authStateChanges().map(
      (user) => user == null ? null : AuthUserModel.fromFirebaseUser(user),
    );
  }
}
