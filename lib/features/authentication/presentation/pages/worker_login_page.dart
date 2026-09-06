
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

class WorkerLoginPage extends StatelessWidget {
  const WorkerLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthenticationCubit>(),
      child: const _WorkerLoginView(),
    );
  }
}

class _WorkerLoginView extends StatefulWidget {
  const _WorkerLoginView();

  @override
  State<_WorkerLoginView> createState() => _WorkerLoginViewState();
}

class _WorkerLoginViewState extends State<_WorkerLoginView> {
  final _workerLoginIdController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _workerLoginIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    TextInput.finishAutofillContext();

    context.read<AuthenticationCubit>().workerLogin(
          workerLoginId: _workerLoginIdController.text,
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      titleKey: 'authentication.worker_login_title',
      subtitleKey: 'authentication.worker_login_subtitle',
      child: BlocBuilder<AuthenticationCubit, AuthenticationState>(
        builder: (context, state) {
          final failure =
              state is AuthenticationFailureState ? state : null;

          final loginIdError =
              failure?.fieldErrors[AuthField.email];

          final passwordError =
              failure?.fieldErrors[AuthField.password];

          final isLoading = state is AuthenticationLoading;

          return AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _workerLoginIdController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.characters,
                  autofillHints: const [
                    AutofillHints.username,
                  ],
                  decoration: InputDecoration(
                    labelText:
                        'authentication.worker_login_id'.tr(),
                    hintText:
                        'authentication.worker_login_id_hint'.tr(),
                    errorText: loginIdError == null
                        ? null
                        : authValidationLocalizationKey(
                            loginIdError,
                          ).tr(),
                    prefixIcon: const Icon(
                      Icons.badge_outlined,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AuthPasswordField(
                  controller: _passwordController,
                  labelKey: 'authentication.password',
                  errorText: passwordError == null
                      ? null
                      : authValidationLocalizationKey(
                          passwordError,
                        ).tr(),
                  onSubmitted: _submit,
                ),
                const SizedBox(height: 12),
                if (failure != null &&
                    failure.fieldErrors.isEmpty) ...[
                  _InlineError(
                    message: authErrorLocalizationKey(
                      failure.errorCode,
                    ).tr(),
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
                        : Text(
                            'authentication.worker_sign_in'.tr(),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => context.go(
                            RouteNames.kLoginPage,
                          ),
                  child: Text(
                    'authentication.owner_login'.tr(),
                  ),
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

  const _InlineError({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .errorContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: Theme.of(context)
                .colorScheme
                .onErrorContainer,
          ),
        ),
      ),
    );
  }
}

