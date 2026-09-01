import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'config/routing/app_router.dart';
import 'config/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'features/authentication/presentation/manager/session_cubit.dart';
import 'features/theme/domain/entities/theme_entity.dart';
import 'features/theme/presentation/manager/theme_cubit.dart';
import 'features/theme/presentation/manager/theme_state.dart';
import 'shared/wrappers/app_providers.dart';
import 'shared/wrappers/app_wrapper.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppProviders(child: _AppView());
  }
}

class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  late final AppRouterController _routerController;

  @override
  void initState() {
    super.initState();
    _routerController = AppRouterController(context.read<SessionCubit>());
  }

  @override
  void dispose() {
    _routerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final isDark =
            state is ThemeSuccess && state.theme.type == ThemeType.dark;
        return ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) => FlavorBanner(
            child: MaterialApp.router(
              title: AppStrings.appName,
              debugShowCheckedModeBanner: false,
              builder: (context, child) =>
                  AppWrapper(child: child ?? const SizedBox.shrink()),
              theme: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
              locale: context.locale,
              routerConfig: _routerController.router,
            ),
          ),
        );
      },
    );
  }
}
