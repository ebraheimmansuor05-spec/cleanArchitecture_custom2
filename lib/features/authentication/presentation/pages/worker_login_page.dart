// lib/features/authentication/presentation/pages/login_page.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routing/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/auth_failure.dart';
import '../localization/auth_localization.dart';
import '../manager/authentication_cubit.dart';
import '../manager/authentication_state.dart';
import '../widgets/auth_password_field.dart';
import '../widgets/auth_scaffold.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthenticationCubit>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    TextInput.finishAutofillContext();
    context.read<AuthenticationCubit>().login(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      titleKey: 'authentication.welcome_back',
      subtitleKey: 'authentication.login_subtitle',
      child: BlocBuilder<AuthenticationCubit, AuthenticationState>(
        builder: (context, state) {
          final failure = state is AuthenticationFailureState ? state : null;
          final emailError = failure?.fieldErrors[AuthField.email];
          final passwordError = failure?.fieldErrors[AuthField.password];
          final isLoading = state is AuthenticationLoading;
          return AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  decoration: InputDecoration(
                    labelText: 'authentication.email'.tr(),
                    hintText: 'authentication.email_hint'.tr(),
                    errorText: emailError == null
                        ? null
                        : authValidationLocalizationKey(emailError).tr(),
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                AuthPasswordField(
                  controller: _passwordController,
                  labelKey: 'authentication.password',
                  errorText: passwordError == null
                      ? null
                      : authValidationLocalizationKey(passwordError).tr(),
                  onSubmitted: _submit,
                ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: isLoading
                        ? null
                        : () => context.push(RouteNames.kForgotPasswordPage),
                    child: Text('authentication.forgot_password'.tr()),
                  ),
                ),
                if (failure != null && failure.fieldErrors.isEmpty) ...[
                  _InlineError(
                    message: authErrorLocalizationKey(failure.errorCode).tr(),
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.4,
                            ),
                          )
                        : Text('authentication.sign_in'.tr()),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('authentication.no_account'.tr()),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => context.push(RouteNames.kRegisterPage),
                      child: Text('authentication.create_account'.tr()),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;

  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
      ),
    );
  }
}