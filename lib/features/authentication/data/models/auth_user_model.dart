import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/auth_user_entity.dart';

class AuthUserModel {
  final String id;
  final String? email;
  final String? displayName;
  final bool isEmailVerified;

  const AuthUserModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.isEmailVerified,
  });

  factory AuthUserModel.fromFirebaseUser(User user) {
    return AuthUserModel(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      isEmailVerified: user.emailVerified,
    );
  }

  AuthUserEntity toEntity() {
    return AuthUserEntity(
      id: id,
      email: email,
      displayName: displayName,
      isEmailVerified: isEmailVerified,
    );
  }
}
