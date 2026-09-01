import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    context.read<AuthenticationCubit>().sendPasswordResetEmail(
      _emailController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      titleKey: 'authentication.recovery_title',
      subtitleKey: 'authentication.recovery_subtitle',
      showBackButton: true,
      child: BlocConsumer<AuthenticationCubit, AuthenticationState>(
        listenWhen: (previous, current) =>
            current is AuthenticationSuccess &&
            current.action == AuthenticationAction.passwordReset,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('authentication.recovery_sent'.tr())),
          );
        },
        builder: (context, state) {
          final failure = state is AuthenticationFailureState ? state : null;
          final emailError = failure?.fieldErrors[AuthField.email];
          final isLoading = state is AuthenticationLoading;
          final isSuccess = state is AuthenticationSuccess;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: 'authentication.email'.tr(),
                  hintText: 'authentication.email_hint'.tr(),
                  errorText: emailError == null
                      ? null
                      : authValidationLocalizationKey(emailError).tr(),
                  prefixIcon: const Icon(Icons.mail_outline_rounded),
                ),
              ),
              if (failure != null && failure.fieldErrors.isEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  authErrorLocalizationKey(failure.errorCode).tr(),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              if (isSuccess) ...[
                const SizedBox(height: 16),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    'authentication.recovery_sent'.tr(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
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
                      : Text('authentication.send_reset_link'.tr()),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () => Navigator.of(context).maybePop(),
                child: Text('authentication.back_to_login'.tr()),
              ),
            ],
          );
        },
      ),
    );
  }
}
