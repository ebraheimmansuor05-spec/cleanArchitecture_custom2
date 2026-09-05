// lib/features/authentication/presentation/pages/register_page.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routing/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/auth_failure.dart';
import '../../domain/enums/account_type.dart';
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
  final _workshopNameController = TextEditingController();
  AccountType _accountType = AccountType.owner;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _workshopNameController.dispose();
    super.dispose();
  }

  void _submit() {
    TextInput.finishAutofillContext();
    context.read<AuthenticationCubit>().register(
      email: _emailController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      workshopName: _workshopNameController.text,
      accountType: _accountType,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      titleKey: 'authentication.create_account',
      subtitleKey: 'authentication.register_subtitle',
      child: BlocBuilder<AuthenticationCubit, AuthenticationState>(
        builder: (context, state) {
          final failure = state is AuthenticationFailureState ? state : null;
          final emailError = failure?.fieldErrors[AuthField.email];
          final passwordError = failure?.fieldErrors[AuthField.password];
          final workshopNameError = failure?.fieldErrors[AuthField.workshopName];
          final isLoading = state is AuthenticationLoading;

          return AutofillGroup(
            child: SingleChildScrollView(
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
                  ),
                  const SizedBox(height: 16),
                  AuthPasswordField(
                    controller: _confirmPasswordController,
                    labelKey: 'authentication.confirm_password',
                    onSubmitted: _submit,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _workshopNameController,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.organizationName],
                    decoration: InputDecoration(
                      labelText: 'authentication.workshop_name'.tr(),
                      hintText: 'authentication.workshop_name_hint'.tr(),
                      errorText: workshopNameError == null
                          ? null
                          : authValidationLocalizationKey(workshopNameError).tr(),
                      prefixIcon: const Icon(Icons.storefront_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ✅ إصلاح Radio buttons - استخدام value بدلاً من groupValue
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<AccountType>(
                          title: Text('authentication.owner'.tr()),
                          value: AccountType.owner,
                          groupValue: _accountType,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _accountType = value);
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<AccountType>(
                          title: Text('authentication.worker'.tr()),
                          value: AccountType.worker,
                          groupValue: _accountType,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _accountType = value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  if (failure != null && failure.fieldErrors.isEmpty) ...[
                    const SizedBox(height: 8),
                    _InlineError(
                      message: authErrorLocalizationKey(failure.errorCode).tr(),
                    ),
                  ],
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('authentication.have_account'.tr()),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () => context.push(RouteNames.kLoginPage),
                        child: Text('authentication.sign_in'.tr()),
                      ),
                    ],
                  ),
                ],
              ),
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