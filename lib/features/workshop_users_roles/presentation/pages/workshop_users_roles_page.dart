import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../manager/workshop_user/workshop_user_cubit.dart';
import '../manager/workshop_user/workshop_user_state.dart';
import '../widgets/workshop_users_roles_widgets.dart';

class WorkshopUsersRolesPage extends StatelessWidget {
  const WorkshopUsersRolesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WorkshopUserCubit>()..loadData(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('WorkshopUsersRoles'),
        ),
        body: BlocBuilder<WorkshopUserCubit, WorkshopUserState>(
          builder: (context, state) {
            if (state is WorkshopUserLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is WorkshopUserError) {
              return Center(child: Text(state.message));
            }
            if (state is WorkshopUserLoaded) {
              return WorkshopUsersRolesList(items: state.items);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
