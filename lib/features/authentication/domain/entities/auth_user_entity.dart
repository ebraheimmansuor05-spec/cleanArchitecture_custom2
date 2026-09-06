
import 'package:equatable/equatable.dart';

class AuthUserEntity extends Equatable {
  final String id;
  final String? email;
  final String? displayName;
  final bool isEmailVerified;
  final String? workshopId;
  final String? roleId;

  const AuthUserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    required this.isEmailVerified,
    this.workshopId,
    this.roleId,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        isEmailVerified,
        workshopId,
        roleId,
      ];

  AuthUserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    bool? isEmailVerified,
    String? workshopId,
    String? roleId,
  }) {
    return AuthUserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      workshopId: workshopId ?? this.workshopId,
      roleId: roleId ?? this.roleId,
    );
  }
}