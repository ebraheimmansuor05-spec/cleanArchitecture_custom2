import 'package:easy_localization/easy_localization.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture_template/core/di/injection_container.dart';
import 'package:flutter_clean_architecture_template/features/authentication/domain/usecases/auth_use_cases.dart';
import 'package:flutter_clean_architecture_template/features/authentication/presentation/manager/authentication_cubit.dart';
import 'package:flutter_clean_architecture_template/features/authentication/presentation/manager/session_cubit.dart';
import 'package:flutter_clean_architecture_template/features/authentication/presentation/pages/forgot_password_page.dart';
import 'package:flutter_clean_architecture_template/features/authentication/presentation/pages/login_page.dart';
import 'package:flutter_clean_architecture_template/features/authentication/presentation/pages/register_page.dart';
import 'package:flutter_clean_architecture_template/features/authentication/presentation/widgets/session_logout_button.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../helpers/fakes.dart';

late final Map<String, Map<String, dynamic>> _testTranslations;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAuthRepository repository;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    _testTranslations = {
      'en':
          jsonDecode(await File('assets/translations/en.json').readAsString())
              as Map<String, dynamic>,
      'ar':
          jsonDecode(await File('assets/translations/ar.json').readAsString())
              as Map<String, dynamic>,
    };
  });

  setUp(() {
    repository = FakeAuthRepository();
    sl.registerFactory(
      () => AuthenticationCubit(
        loginUseCase: LoginUseCase(repository),
        registerUseCase: RegisterUseCase(repository),
        sendPasswordResetUseCase: SendPasswordResetUseCase(repository),
      ),
    );
  });

  tearDown(() async {
    await repository.close();
    await sl.reset();
  });

  Future<void> pumpLocalizedPage(
    WidgetTester tester, {
    required Widget page,
    Locale locale = const Locale('en'),
  }) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: locale,
        useOnlyLangCode: true,
        assetLoader: const _FileAssetLoader(),
        child: Builder(
          builder: (context) => MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: page,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('login fields render and submission reaches Cubit/use case', (
    tester,
  ) async {
    await pumpLocalizedPage(tester, page: const LoginPage());

    expect(find.text('Email address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'owner@kitchenflow.test');
    await tester.enterText(fields.at(1), 'password');
    await tester.tap(find.text('Sign in'));
    await tester.pump();

    expect(repository.loginCalls, 1);
    expect(repository.lastLoginCredentials?.email, 'owner@kitchenflow.test');
  });

  testWidgets('login validation errors are rendered from Cubit state', (
    tester,
  ) async {
    await pumpLocalizedPage(tester, page: const LoginPage());

    await tester.tap(find.text('Sign in'));
    await tester.pump();

    expect(find.text('This field is required.'), findsNWidgets(2));
    expect(repository.loginCalls, 0);
  });

  testWidgets('password recovery submission reaches Cubit/use case', (
    tester,
  ) async {
    await pumpLocalizedPage(tester, page: const ForgotPasswordPage());

    await tester.enterText(find.byType(TextField), 'owner@kitchenflow.test');
    await tester.tap(find.text('Send reset link'));
    await tester.pump();

    expect(repository.resetCalls, 1);
    expect(repository.lastResetEmail, 'owner@kitchenflow.test');
  });

  testWidgets('registration is limited to identity credentials', (
    tester,
  ) async {
    await pumpLocalizedPage(tester, page: const RegisterPage());

    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(3));
    await tester.enterText(fields.at(0), 'owner@kitchenflow.test');
    await tester.enterText(fields.at(1), 'password');
    await tester.enterText(fields.at(2), 'password');
    final submitButton = find.text('Create account');
    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pump();

    expect(repository.registerCalls, 1);
    expect(
      repository.lastRegistrationCredentials?.email,
      'owner@kitchenflow.test',
    );
  });

  testWidgets('Arabic login renders right-to-left', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpLocalizedPage(
      tester,
      page: const LoginPage(),
      locale: const Locale('ar'),
    );

    final loginText = find.text('تسجيل الدخول').first;
    expect(loginText, findsOneWidget);
    expect(Directionality.of(tester.element(loginText)), ui.TextDirection.rtl);
    expect(tester.takeException(), isNull);
  });

  testWidgets('logout button communicates through SessionCubit', (
    tester,
  ) async {
    final sessionCubit = _RecordingSessionCubit(repository);

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        useOnlyLangCode: true,
        assetLoader: const _FileAssetLoader(),
        child: Builder(
          builder: (context) => MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: Scaffold(
              body: BlocProvider<SessionCubit>.value(
                value: sessionCubit,
                child: const SessionLogoutButton(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pump();

    expect(sessionCubit.logoutCalls, 1);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await sessionCubit.close();
  });
}

class _FileAssetLoader extends AssetLoader {
  const _FileAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) =>
      Future.value(_testTranslations[locale.languageCode]);
}

class _RecordingSessionCubit extends SessionCubit {
  int logoutCalls = 0;

  _RecordingSessionCubit(FakeAuthRepository repository)
    : super(
        checkSessionUseCase: CheckSessionUseCase(repository),
        observeAuthStateUseCase: ObserveAuthStateUseCase(repository),
        logoutUseCase: LogoutUseCase(repository),
      );

  @override
  Future<void> logout() async {
    logoutCalls++;
  }
}
