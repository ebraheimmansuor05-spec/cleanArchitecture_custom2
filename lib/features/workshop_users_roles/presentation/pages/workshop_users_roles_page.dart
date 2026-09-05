
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/role_entity.dart';
import '../manager/role/role_cubit.dart';
import '../manager/role/role_state.dart';
import '../manager/workshop_user/workshop_cubit.dart';
import '../manager/workshop_user/workshop_state.dart';
import '../manager/workshop_user/workshop_user_cubit.dart';
import '../manager/workshop_user/workshop_user_state.dart';
import '../widgets/workshop_users_roles_widgets.dart';

class WorkshopUsersRolesPage extends StatefulWidget {
  const WorkshopUsersRolesPage({super.key});

  @override
  State<WorkshopUsersRolesPage> createState() =>
      _WorkshopUsersRolesPageState();
}

class _WorkshopUsersRolesPageState extends State<WorkshopUsersRolesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 2,
      vsync: this,
    );

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();

    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkshopCubit, WorkshopState>(
      builder: (context, workshopState) {
        if (workshopState is WorkshopInitial ||
            workshopState is WorkshopLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (workshopState is WorkshopError) {
          return _WorkshopErrorState(
            message: workshopState.message,
          );
        }

        if (workshopState is! WorkshopLoaded) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Workshop is unavailable.',
              ),
            ),
          );
        }

        final workshopId = workshopState.workshop.id;

        return _buildWorkspacePage(
          workshopId,
        );
      },
    );
  }

  Widget _buildWorkspacePage(String workshopId) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<WorkshopUserCubit>()
            ..loadData(workshopId),
        ),
        BlocProvider(
          create: (_) => sl<RoleCubit>()
            ..loadRoles(workshopId),
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              if (Scaffold.of(context).hasDrawer) {
                Scaffold.of(context).openDrawer();
              }
            },
            icon: const Icon(
              Icons.menu_rounded,
              color: Color(0xFF25252D),
            ),
          ),
          title: const Text(
            'TEAM & ACCESS',
            style: TextStyle(
              color: Color(0xFF25252D),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          centerTitle: true,
          actions: [
            Stack(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: Color(0xFF25252D),
                  ),
                ),
                Positioned(
                  top: 11,
                  right: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53935),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            const Divider(
              height: 1,
              color: Color(0xFFE7E7EB),
            ),
            Expanded(
              child: Column(
                children: [
                  _SearchSection(
                    controller: _searchController,
                    onFilterPressed: () {
                      _showFilterBottomSheet(context);
                    },
                  ),
                  _TeamTabs(
                    controller: _tabController,
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _StaffDirectory(
                          workshopId: workshopId,
                          searchQuery: _searchQuery,
                        ),
                        _RoleAccess(
                          searchQuery: _searchQuery,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showAddMemberBottomSheet(context);
          },
          backgroundColor: const Color(0xFF6046A5),
          elevation: 4,
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return const SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Filters will be added here.',
            ),
          ),
        );
      },
    );
  }

  void _showAddMemberBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return const SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Add workshop member flow will be implemented here.',
            ),
          ),
        );
      },
    );
  }
}

class _WorkshopErrorState extends StatelessWidget {
  final String message;

  const _WorkshopErrorState({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.storefront_outlined,
                size: 56,
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to load workshop.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchSection extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onFilterPressed;

  const _SearchSection({
    required this.controller,
    required this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        16,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE0E0E5),
                ),
              ),
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Color(0xFF6F7078),
                  ),
                  hintText: 'Search staff or roles...',
                  hintStyle: TextStyle(
                    color: Color(0xFF8B8C94),
                    fontSize: 16,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 17,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE0E0E5),
              ),
            ),
            child: IconButton(
              onPressed: onFilterPressed,
              icon: const Icon(
                Icons.filter_list_rounded,
                color: Color(0xFF4B4B55),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamTabs extends StatelessWidget {
  final TabController controller;

  const _TeamTabs({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE0E0E5),
        ),
      ),
      child: TabBar(
        controller: controller,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        labelColor: const Color(0xFF303039),
        unselectedLabelColor: const Color(0xFF62626D),
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(
            text: 'Staff Directory',
          ),
          Tab(
            text: 'Role Access',
          ),
        ],
      ),
    );
  }
}

class _StaffDirectory extends StatelessWidget {
  final String searchQuery;
  final String workshopId;

  const _StaffDirectory({
    required this.searchQuery,
    required this.workshopId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkshopUserCubit, WorkshopUserState>(
      builder: (context, state) {
        if (state is WorkshopUserLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is WorkshopUserError) {
          return _ErrorState(
            message: state.message,
            onRetry: () {
              context
                  .read<WorkshopUserCubit>()
                  .loadData(workshopId);
            },
          );
        }

        if (state is WorkshopUserLoaded) {
          final query = searchQuery.toLowerCase().trim();

          final users = state.users.where((user) {
            if (query.isEmpty) {
              return true;
            }

            return user.userId.toLowerCase().contains(query) ||
                user.roleId.toLowerCase().contains(query) ||
                user.status.name.toLowerCase().contains(query);
          }).toList();

          return WorkshopUsersRolesList(
            users: users,
          );
        }

        return const _EmptyState();
      },
    );
  }
}

class _RoleAccess extends StatelessWidget {
  final String searchQuery;

  const _RoleAccess({
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoleCubit, RoleState>(
      builder: (context, state) {
        if (state is RoleLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is RoleError) {
          return _ErrorState(
            message: state.message,
            onRetry: () {
              context.read<RoleCubit>().retry();
            },
          );
        }

        if (state is RoleLoaded) {
          final query = searchQuery.toLowerCase().trim();

          final roles = state.roles.where((role) {
            if (query.isEmpty) {
              return true;
            }

            return role.name.toLowerCase().contains(query) ||
                role.description.toLowerCase().contains(query);
          }).toList();

          if (roles.isEmpty) {
            return const _NoRolesFound();
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              20,
              24,
              20,
              100,
            ),
            itemCount: roles.length,
            separatorBuilder: (_, _) => const SizedBox(
              height: 14,
            ),
            itemBuilder: (context, index) {
              return _RoleCard(
                role: roles[index],
              );
            },
          );
        }

        return const _NoRolesFound();
      },
    );
  }
}

class _RoleCard extends StatelessWidget {
  final RoleEntity role;

  const _RoleCard({
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE8E8ED),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9F8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_outlined,
                  color: Color(0xFF6046A5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  role.name,
                  style: const TextStyle(
                    color: Color(0xFF25252D),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            role.description,
            style: const TextStyle(
              color: Color(0xFF777781),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Permissions',
            style: TextStyle(
              color: Color(0xFF25252D),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: role.permissions.map((permission) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F3F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  permission.name,
                  style: const TextStyle(
                    color: Color(0xFF555660),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Color(0xFFE05A5A),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.groups_outlined,
            size: 56,
            color: Color(0xFF9A9AA3),
          ),
          SizedBox(height: 16),
          Text(
            'No workshop members yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first team member to get started.',
            style: TextStyle(
              color: Color(0xFF7A7A84),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoRolesFound extends StatelessWidget {
  const _NoRolesFound();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.admin_panel_settings_outlined,
              size: 56,
              color: Color(0xFF9A9AA3),
            ),
            SizedBox(height: 16),
            Text(
              'No roles found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'There are no roles matching your search.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF85858E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
