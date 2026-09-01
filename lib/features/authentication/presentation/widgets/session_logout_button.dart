import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../localization/auth_localization.dart';
import '../manager/session_cubit.dart';
import '../manager/session_state.dart';

class SessionLogoutButton extends StatelessWidget {
  final bool expanded;

  const SessionLogoutButton({super.key, this.expanded = true});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SessionCubit, SessionState>(
      listenWhen: (previous, current) => current is SessionFailure,
      listener: (context, state) {
        if (state case SessionFailure(:final errorCode)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authErrorLocalizationKey(errorCode).tr())),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is SessionLoggingOut;
        final button = OutlinedButton.icon(
          onPressed: isLoading
              ? null
              : () => context.read<SessionCubit>().logout(),
          icon: isLoading
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.logout_rounded),
          label: Text(
            (isLoading ? 'authentication.logging_out' : 'authentication.logout')
                .tr(),
          ),
        );
        return expanded
            ? SizedBox(width: double.infinity, child: button)
            : button;
      },
    );
  }
}
