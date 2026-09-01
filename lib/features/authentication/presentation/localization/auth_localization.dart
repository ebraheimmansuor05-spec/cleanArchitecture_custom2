import '../../domain/entities/auth_failure.dart';

String authErrorLocalizationKey(AuthErrorCode code) {
  return switch (code) {
    AuthErrorCode.invalidCredentials =>
      'authentication.errors.invalid_credentials',
    AuthErrorCode.invalidEmail => 'authentication.errors.invalid_email',
    AuthErrorCode.emailAlreadyInUse =>
      'authentication.errors.email_already_in_use',
    AuthErrorCode.weakPassword => 'authentication.errors.weak_password',
    AuthErrorCode.userDisabled => 'authentication.errors.user_disabled',
    AuthErrorCode.tooManyRequests => 'authentication.errors.too_many_requests',
    AuthErrorCode.network => 'authentication.errors.network',
    AuthErrorCode.operationNotAllowed =>
      'authentication.errors.operation_not_allowed',
    AuthErrorCode.sessionExpired => 'authentication.errors.session_expired',
    AuthErrorCode.unknown => 'authentication.errors.unknown',
  };
}

String authValidationLocalizationKey(AuthValidationCode code) {
  return switch (code) {
    AuthValidationCode.required => 'authentication.validation.required',
    AuthValidationCode.invalidEmail =>
      'authentication.validation.invalid_email',
    AuthValidationCode.passwordsDoNotMatch =>
      'authentication.validation.passwords_do_not_match',
  };
}
