import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/auth_failure.dart';
import '../localization/auth_localization.dart';
import '../manager/authentication_cubit.dart';
import '../manager/authentication_state.dart';
import '../widgets/auth_password_field.dart';
import '../widgets/auth_scaffold.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthenticationCubit>(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    TextInput.finishAutofillContext();
    context.read<AuthenticationCubit>().register(
      email: _emailController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      titleKey: 'authentication.register_title',
      subtitleKey: 'authentication.register_subtitle',
      showBackButton: true,
      child: BlocBuilder<AuthenticationCubit, AuthenticationState>(
        builder: (context, state) {
          final failure = state is AuthenticationFailureState ? state : null;
          final isLoading = state is AuthenticationLoading;
          String? fieldError(AuthField field) {
            final code = failure?.fieldErrors[field];
            return code == null
                ? null
                : authValidationLocalizationKey(code).tr();
          }

          return AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newUsername],
                  decoration: InputDecoration(
                    labelText: 'authentication.email'.tr(),
                    errorText: fieldError(AuthField.email),
                    prefixIcon: const Icon(Icons.mail_outline_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                AuthPasswordField(
                  controller: _passwordController,
                  labelKey: 'authentication.password',
                  errorText: fieldError(AuthField.password),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AuthPasswordField(
                  controller: _confirmPasswordController,
                  labelKey: 'authentication.confirm_password',
                  errorText: fieldError(AuthField.confirmPassword),
                  onSubmitted: _submit,
                ),
                if (failure != null && failure.fieldErrors.isEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    authErrorLocalizationKey(failure.errorCode).tr(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
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
                        : Text('authentication.create_account'.tr()),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => Navigator.of(context).maybePop(),
                  child: Text('authentication.already_account'.tr()),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
