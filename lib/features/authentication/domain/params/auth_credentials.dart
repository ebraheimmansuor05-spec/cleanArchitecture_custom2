import 'package:equatable/equatable.dart';

class LoginCredentials extends Equatable {
  final String email;
  final String password;

  const LoginCredentials({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class RegistrationCredentials extends Equatable {
  final String email;
  final String password;
  final String confirmPassword;

  const RegistrationCredentials({
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object> get props => [email, password, confirmPassword];
}
