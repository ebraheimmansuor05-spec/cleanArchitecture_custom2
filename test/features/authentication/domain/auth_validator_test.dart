import 'package:flutter_clean_architecture_template/features/authentication/domain/entities/auth_failure.dart';
import 'package:flutter_clean_architecture_template/features/authentication/domain/params/auth_credentials.dart';
import 'package:flutter_clean_architecture_template/features/authentication/domain/validators/auth_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthValidator', () {
    test('requires email and password for login', () {
      final errors = AuthValidator.validateLogin(
        const LoginCredentials(email: '', password: ''),
      );

      expect(errors[AuthField.email], AuthValidationCode.required);
      expect(errors[AuthField.password], AuthValidationCode.required);
    });

    test('rejects an invalid email', () {
      final errors = AuthValidator.validateLogin(
        const LoginCredentials(email: 'not-an-email', password: 'password'),
      );

      expect(errors[AuthField.email], AuthValidationCode.invalidEmail);
    });

    test('accepts valid login fields without inventing password rules', () {
      final errors = AuthValidator.validateLogin(
        const LoginCredentials(email: 'owner@kitchenflow.test', password: 'x'),
      );

      expect(errors, isEmpty);
    });

    test('requires matching registration confirmation', () {
      final errors = AuthValidator.validateRegistration(
        const RegistrationCredentials(
          email: 'owner@kitchenflow.test',
          password: 'password',
          confirmPassword: 'different',
        ),
      );

      expect(
        errors[AuthField.confirmPassword],
        AuthValidationCode.passwordsDoNotMatch,
      );
    });
  });
}
