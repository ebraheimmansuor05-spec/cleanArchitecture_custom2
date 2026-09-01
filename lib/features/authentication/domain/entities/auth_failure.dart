import '../../../../core/errors/failures.dart';

enum AuthErrorCode {
  invalidCredentials,
  invalidEmail,
  emailAlreadyInUse,
  weakPassword,
  userDisabled,
  tooManyRequests,
  network,
  operationNotAllowed,
  sessionExpired,
  unknown,
}

enum AuthField { email, password, confirmPassword }

enum AuthValidationCode { required, invalidEmail, passwordsDoNotMatch }

class AuthenticationFailure extends AuthFailure {
  final AuthErrorCode code;

  const AuthenticationFailure(
    this.code, [
    super.message = 'Authentication could not be completed.',
  ]);
}

class AuthValidationFailure extends ValidationFailure {
  final Map<AuthField, AuthValidationCode> errors;

  const AuthValidationFailure(this.errors)
    : super('Please correct the highlighted fields.');
}
