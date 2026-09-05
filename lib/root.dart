import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injection_container.dart';
import 'features/authentication/presentation/manager/session_cubit.dart';
import 'features/workshop_users_roles/presentation/manager/workshop_user/workshop_cubit.dart';
import 'features/workshop_users_roles/presentation/manager/workshop_user/workshop_state.dart';
import 'shared/navigation/custom_bottom_nav_bar.dart';

class RootPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const RootPage({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = sl<WorkshopCubit>();
        final user = context.read<SessionCubit>().state.user;

        if (user != null) {
          cubit.loadWorkshopByOwnerId(user.id);
        }

        return cubit;
      },
      child: BlocBuilder<WorkshopCubit, WorkshopState>(
        builder: (context, state) {
          if (state is WorkshopLoading || state is WorkshopInitial) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (state is WorkshopError) {
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.storefront_outlined,
                        size: 64,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Unable to load your workshop.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton(
                        onPressed: () {
                          final user =
                              context.read<SessionCubit>().state.user;

                          if (user != null) {
                            context
                                .read<WorkshopCubit>()
                                .loadWorkshopByOwnerId(user.id);
                          }
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (state is WorkshopLoaded) {
            return Scaffold(
              body: navigationShell,
              bottomNavigationBar: CustomBottomNavBar(
                currentIndex: navigationShell.currentIndex,
                onTap: navigationShell.goBranch,
              ),
            );
          }

          return const Scaffold(
            body: Center(
              child: Text('Workspace is unavailable.'),
            ),
          );
        },
      ),
    );
  }
}