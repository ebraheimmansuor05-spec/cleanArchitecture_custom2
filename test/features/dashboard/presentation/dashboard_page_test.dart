import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_architecture_template/features/dashboard/presentation/manager/dashboard_cubit.dart';
import 'package:flutter_clean_architecture_template/features/dashboard/presentation/manager/dashboard_state.dart';
import 'package:flutter_clean_architecture_template/features/dashboard/presentation/models/dashboard_preview_content.dart';
import 'package:flutter_clean_architecture_template/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

late final Map<String, Map<String, dynamic>> _testTranslations;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  Future<void> pumpDashboard(
    WidgetTester tester, {
    required DashboardCubit cubit,
    Locale locale = const Locale('en'),
    Size size = const Size(390, 844),
    double textScaleFactor = 1,
    bool settle = true,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(textScaleFactor)),
              child: child!,
            ),
            home: BlocProvider<DashboardCubit>.value(
              value: cubit,
              child: const DashboardView(),
            ),
          ),
        ),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  testWidgets('renders all major source-backed Dashboard sections', (
    tester,
  ) async {
    final cubit = DashboardCubit()..load();
    addTearDown(cubit.close);

    await pumpDashboard(tester, cubit: cubit);

    expect(find.text('Workshop Overview'), findsOneWidget);
    expect(find.text('Quick Actions'), findsOneWidget);
    expect(find.text("Today's Orders"), findsOneWidget);
    expect(find.text('Live Updates · Preview Data'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Financial Summary'),
      350,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Financial Summary'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Critical Inventory Alert'),
      350,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Worker Activity'), findsOneWidget);
    expect(find.text('Critical Inventory Alert'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('quick action reaches DashboardCubit and reports deferral', (
    tester,
  ) async {
    final cubit = DashboardCubit()..load();
    addTearDown(cubit.close);

    await pumpDashboard(tester, cubit: cubit);
    await tester.tap(find.text('New Order'));
    await tester.pump();

    expect(cubit.state.actionNotice?.action, DashboardAction.newOrder);
    expect(
      find.text(
        'New Order is not available until its owning feature is connected.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loading, empty, partial, and failure states are renderable', (
    tester,
  ) async {
    final loadingCubit = DashboardCubit(
      initialState: const DashboardState.loading(),
    );
    await pumpDashboard(tester, cubit: loadingCubit, settle: false);
    expect(find.byKey(const Key('dashboard-loading')), findsOneWidget);
    await loadingCubit.close();

    final emptyCubit = DashboardCubit(
      initialState: const DashboardState.empty(),
    );
    await pumpDashboard(tester, cubit: emptyCubit);
    expect(find.text('No dashboard data'), findsOneWidget);
    await emptyCubit.close();

    final partialCubit = DashboardCubit(
      initialState: const DashboardState.partial(
        content: DashboardPreviewContent.fromApprovedDesign(),
        unavailableSections: [DashboardSection.financial],
      ),
    );
    await pumpDashboard(tester, cubit: partialCubit);
    expect(
      find.text(
        'Some dashboard sections are unavailable. Available information is still shown.',
      ),
      findsOneWidget,
    );
    await partialCubit.close();

    final failureCubit = DashboardCubit(
      initialState: const DashboardState.failure(
        DashboardFailureReason.unavailable,
      ),
    );
    await pumpDashboard(tester, cubit: failureCubit);
    expect(find.text('Dashboard unavailable'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pump();
    expect(find.text('Workshop Overview'), findsOneWidget);
    await failureCubit.close();
  });

  testWidgets('Arabic Dashboard is RTL and fits a small phone', (tester) async {
    final cubit = DashboardCubit()..load();
    addTearDown(cubit.close);

    await pumpDashboard(
      tester,
      cubit: cubit,
      locale: const Locale('ar'),
      size: const Size(320, 700),
      textScaleFactor: 1.2,
    );

    final title = find.text('لوحة التحكم');
    expect(title, findsOneWidget);
    expect(Directionality.of(tester.element(title)), ui.TextDirection.rtl);
    expect(find.text('الإجراءات السريعة'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('تنبيه حرج للمخزون'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('تنبيه حرج للمخزون'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _FileAssetLoader extends AssetLoader {
  const _FileAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) {
    return Future.value(_testTranslations[locale.languageCode]);
  }
}
