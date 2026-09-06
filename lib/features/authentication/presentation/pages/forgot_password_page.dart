// lib/features/authentication/presentation/pages/forgot_password_page.dart

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
import '../widgets/auth_scaffold.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthenticationCubit>(),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatefulWidget {
  const _ForgotPasswordView();

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    TextInput.finishAutofillContext();
    context.read<AuthenticationCubit>().sendPasswordResetEmail(
      _emailController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      titleKey: 'authentication.forgot_password',
      subtitleKey: 'authentication.reset_password_subtitle',
      child: BlocBuilder<AuthenticationCubit, AuthenticationState>(
        builder: (context, state) {
          final failure = state is AuthenticationFailureState ? state : null;
          final emailError = failure?.fieldErrors[AuthField.email];
          final isLoading = state is AuthenticationLoading;
          final isSuccess = state is AuthenticationSuccess &&
              state.action == AuthenticationAction.passwordReset;

          return AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isSuccess) ...[
                  _SuccessMessage(
                    message: 'authentication.reset_email_sent'.tr(),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.email],
                  decoration: InputDecoration(
                    labelText: 'authentication.email'.tr(),
                    hintText: 'authentication.email_hint'.tr(),
                    errorText: emailError == null
                        ? null
                        : authValidationLocalizationKey(emailError).tr(),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 16),
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
                        : Text('authentication.send_reset_email'.tr()),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => context.go(RouteNames.kLoginPage),
                  child: Text('authentication.back_to_login'.tr()),
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

class _SuccessMessage extends StatelessWidget {
  final String message;

  const _SuccessMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}