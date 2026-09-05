// lib/features/authentication/domain/params/auth_credentials.dart

import '../enums/account_type.dart';

class LoginCredentials {
  final String email;
  final String password;

  const LoginCredentials({
    required this.email,
    required this.password,
  });
}

class RegistrationCredentials {
  final String email;
  final String password;
  final String confirmPassword;
  final String? workshopName;
  final AccountType accountType;

  const RegistrationCredentials({
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.workshopName,
    required this.accountType,
  });
}

// ✅ جديد: بيانات تسجيل الدخول للعامل (نفس LoginCredentials لكن للتوضيح)
class WorkerLoginCredentials {
  final String email;
  final String password;

  const WorkerLoginCredentials({
    required this.email,
    required this.password,
  });
}

// ✅ جديد: بيانات إنشاء عامل بواسطة Owner
class CreateWorkerCredentials {
  final String email;
  final String password;
  final String displayName;
  final String phone;
  final String roleId;
  final String workshopId;

  const CreateWorkerCredentials({
    required this.email,
    required this.password,
    required this.displayName,
    required this.phone,
    required this.roleId,
    required this.workshopId,
  });
}