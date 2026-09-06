import 'package:flutter_clean_architecture_template/features/authentication/domain/entities/auth_failure.dart';
import 'package:flutter_clean_architecture_template/features/authentication/domain/enums/account_type.dart';
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
          workshopName: 'Test Workshop',
          accountType: AccountType.owner,
        ),
      );

      expect(
        errors[AuthField.confirmPassword],
        AuthValidationCode.passwordsDoNotMatch,
      );
    });
    test('does not require workshop name for worker', () {
  final errors = AuthValidator.validateRegistration(
    const RegistrationCredentials(
      email: 'worker@example.com',
      password: '123456',
      confirmPassword: '123456',
      workshopName: '',
      accountType: AccountType.worker,
    ),
  );

  expect(errors.containsKey(AuthField.workshopName), isFalse);
});
  });
}
