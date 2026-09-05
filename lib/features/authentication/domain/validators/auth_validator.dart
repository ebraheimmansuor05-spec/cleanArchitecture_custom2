// lib/features/authentication/domain/validators/auth_validator.dart

import '../entities/auth_failure.dart';
import '../enums/account_type.dart';
import '../params/auth_credentials.dart';

abstract final class AuthValidator {
  static final RegExp _emailPattern = RegExp(
    r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@"
    r'[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?'
    r'(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$',
  );

  static Map<AuthField, AuthValidationCode> validateLogin(
    LoginCredentials credentials,
  ) {
    final errors = <AuthField, AuthValidationCode>{};

    _validateEmail(credentials.email, errors);

    if (credentials.password.isEmpty) {
      errors[AuthField.password] = AuthValidationCode.required;
    }

    return errors;
  }

  static Map<AuthField, AuthValidationCode> validateRegistration(
    RegistrationCredentials credentials,
  ) {
    final errors = <AuthField, AuthValidationCode>{};

    _validateEmail(credentials.email, errors);

    if (credentials.password.isEmpty) {
      errors[AuthField.password] = AuthValidationCode.required;
    }

    if (credentials.confirmPassword.isEmpty) {
      errors[AuthField.confirmPassword] = AuthValidationCode.required;
    } else if (credentials.password != credentials.confirmPassword) {
      errors[AuthField.confirmPassword] =
          AuthValidationCode.passwordsDoNotMatch;
    }

    if (credentials.accountType == AccountType.owner &&
      (credentials.workshopName?.trim().isEmpty ?? true)) {
      errors[AuthField.workshopName] = AuthValidationCode.required;
    }

    return errors;
  }

  static Map<AuthField, AuthValidationCode> validateRecoveryEmail(
    String email,
  ) {
    final errors = <AuthField, AuthValidationCode>{};

    _validateEmail(email, errors);

    return errors;
  }

  static void _validateEmail(
    String email,
    Map<AuthField, AuthValidationCode> errors,
  ) {
    if (email.isEmpty) {
      errors[AuthField.email] = AuthValidationCode.required;
    } else if (!_emailPattern.hasMatch(email)) {
      errors[AuthField.email] = AuthValidationCode.invalidEmail;
    }
  }
}