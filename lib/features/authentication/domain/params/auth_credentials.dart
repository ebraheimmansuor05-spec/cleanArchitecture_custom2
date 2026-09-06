import 'package:equatable/equatable.dart';
import '../enums/account_type.dart';
 
class LoginCredentials extends Equatable {
  final String email;
  final String password;

  const LoginCredentials({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class RegistrationCredentials extends Equatable {
  final String email;
  final String password;
  final String confirmPassword;
  final String workshopName;
  final AccountType accountType;

  const RegistrationCredentials({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.workshopName,
    required this.accountType,
  });

  @override
  List<Object> get props => [
        email,
        password,
        confirmPassword,
        workshopName,
        accountType,
      ];
}