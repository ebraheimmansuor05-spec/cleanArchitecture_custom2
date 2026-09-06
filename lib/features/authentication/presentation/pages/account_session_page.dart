import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routing/route_names.dart';
import '../manager/session_cubit.dart';
import '../manager/session_state.dart';
import '../widgets/session_logout_button.dart';

class AccountSessionPage extends StatelessWidget {
  const AccountSessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('authentication.account_session'.tr())),
      body: SafeArea(
        child: BlocBuilder<SessionCubit, SessionState>(
          builder: (context, state) {
            final user = state.user;
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CircleAvatar(
                            radius: 42,
                            child: Text(
                              (user?.email?.isNotEmpty ?? false)
                                  ? user!.email![0].toUpperCase()
                                  : '?',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'authentication.signed_in'.tr(),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user?.email ??
                                'authentication.identity_unavailable'.tr(),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Icon(
                                user?.isEmailVerified == true
                                    ? Icons.verified_rounded
                                    : Icons.info_outline_rounded,
                                size: 18,
                              ),
                              Text(
                                (user?.isEmailVerified == true
                                        ? 'authentication.email_verified'
                                        : 'authentication.email_not_verified')
                                    .tr(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          ElevatedButton.icon(
                            onPressed: () => context.go(RouteNames.kRootPage),
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: Text('authentication.open_workspace'.tr()),
                          ),
                          const SizedBox(height: 12),
                          const SessionLogoutButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
