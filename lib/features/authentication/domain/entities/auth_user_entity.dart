import 'package:equatable/equatable.dart';

class AuthUserEntity extends Equatable {
  final String id;
  final String? email;
  final String? displayName;
  final bool isEmailVerified;

  const AuthUserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    required this.isEmailVerified,
  });

  @override
  List<Object?> get props => [id, email, displayName, isEmailVerified];
}
