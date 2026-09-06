import 'package:flutter/material.dart';

import '../../domain/entities/workshop_user_entity.dart';
import '../../domain/enums/workshop_member_status.dart';
import '../../domain/entities/role_entity.dart';
import '../manager/role/role_cubit.dart';
import '../manager/role/role_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WorkshopUsersRolesList extends StatelessWidget {
  final List<WorkshopUserEntity> users;

  const WorkshopUsersRolesList({
    super.key,
    required this.users,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
      children: [
        _WorkshopStaffHeader(
          totalUsers: users.length,
        ),

        const SizedBox(height: 16),

        if (users.isEmpty)
          const _NoUsersFound()
        else
          ...users.map(
            (user) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: WorkshopUserCard(
                user: user,
              ),
            ),
          ),
      ],
    );
  }
}

class _WorkshopStaffHeader extends StatelessWidget {
  final int totalUsers;

  const _WorkshopStaffHeader({
    required this.totalUsers,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Workshop Staff',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF25252D),
          ),
        ),

        const SizedBox(width: 10),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE9F8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$totalUsers Total',
            style: const TextStyle(
              color: Color(0xFF6046A5),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class WorkshopUserCard extends StatelessWidget {
  final WorkshopUserEntity user;

  const WorkshopUserCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(user.status);

    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _UserAvatar(
                userId: user.userId,
                isActive:
                    user.status == WorkshopMemberStatus.active,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _UserInformation(
                  user: user,
                ),
              ),

              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: Color(0xFF777781),
                ),
                onSelected: (value) {},
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit member'),
                  ),
                  PopupMenuItem(
                    value: 'role',
                    child: Text('Change role'),
                  ),
                  PopupMenuItem(
                    value: 'remove',
                    child: Text('Remove member'),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Divider(
            color: Color(0xFFEEEEF2),
            height: 1,
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  icon: Icons.badge_outlined,
                  label: 'Role ID',
                  value: _shortId(user.roleId),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _InfoItem(
                  icon: Icons.calendar_today_outlined,
                  label: 'Joined',
                  value: _formatDate(user.joinedAt),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.person_outline_rounded,
                    size: 18,
                  ),
                  label: const Text('Profile'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6046A5),
                    side: const BorderSide(
                      color: Color(0xFFD8D0EC),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: statusInfo.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusInfo.label,
                    style: TextStyle(
                      color: statusInfo.textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _shortId(String id) {
    if (id.length <= 8) {
      return id;
    }

    return '${id.substring(0, 8)}...';
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _UserAvatar extends StatelessWidget {
  final String userId;
  final bool isActive;

  const _UserAvatar({
    required this.userId,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final initials = userId.isNotEmpty
        ? userId.substring(0, 1).toUpperCase()
        : '?';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: const Color(0xFFEDE9F8),
          child: Text(
            initials,
            style: const TextStyle(
              color: Color(0xFF6046A5),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        if (isActive)
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _UserInformation extends StatelessWidget {
  final WorkshopUserEntity user;

  const _UserInformation({
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _displayUserId(user.userId),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF25252D),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 5),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE9F8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Role: ${_shortRoleId(user.roleId)}',
            style: const TextStyle(
              color: Color(0xFF6046A5),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 7),

        Text(
          'Member ID: ${_shortUserId(user.userId)}',
          style: const TextStyle(
            color: Color(0xFF85858E),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _displayUserId(String userId) {
    if (userId.length <= 12) {
      return userId;
    }

    return '${userId.substring(0, 12)}...';
  }

  String _shortRoleId(String roleId) {
    if (roleId.length <= 8) {
      return roleId;
    }

    return '${roleId.substring(0, 8)}...';
  }

  String _shortUserId(String userId) {
    if (userId.length <= 8) {
      return userId;
    }

    return '${userId.substring(0, 8)}...';
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: const Color(0xFF8A8A94),
        ),

        const SizedBox(width: 7),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9797A0),
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF383840),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NoUsersFound extends StatelessWidget {
  const _NoUsersFound();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFF0EDF8),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: Color(0xFF6046A5),
              size: 34,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'No staff members found',
            style: TextStyle(
              color: Color(0xFF303039),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Try adjusting your search.',
            style: TextStyle(
              color: Color(0xFF85858E),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusInfo {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _StatusInfo({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });
}

_StatusInfo _getStatusInfo(
  WorkshopMemberStatus status,
) {
  switch (status) {
    case WorkshopMemberStatus.pending:
      return const _StatusInfo(
        label: 'Pending',
        backgroundColor: Color(0xFFFFF4E5),
        textColor: Color(0xFFB26A00),
      );

    case WorkshopMemberStatus.active:
      return const _StatusInfo(
        label: 'Active',
        backgroundColor: Color(0xFFE8F5EC),
        textColor: Color(0xFF2E7D46),
      );

    case WorkshopMemberStatus.suspended:
      return const _StatusInfo(
        label: 'Suspended',
        backgroundColor: Color(0xFFF2F2F4),
        textColor: Color(0xFF777781),
      );

    case WorkshopMemberStatus.removed:
      return const _StatusInfo(
        label: 'Removed',
        backgroundColor: Color(0xFFFDECEC),
        textColor: Color(0xFFC62828),
      );
  }
}
class KitchenFlowBottomNavigation extends StatelessWidget {
  const KitchenFlowBottomNavigation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE7E7EB),
          ),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomNavItem(
            icon: Icons.dashboard_outlined,
            label: 'Home',
          ),
          _BottomNavItem(
            icon: Icons.people_outline_rounded,
            label: 'Team',
            isSelected: true,
          ),
          _BottomNavItem(
            icon: Icons.inventory_2_outlined,
            label: 'Inventory',
          ),
          _BottomNavItem(
            icon: Icons.receipt_long_outlined,
            label: 'Orders',
          ),
          _BottomNavItem(
            icon: Icons.more_horiz_rounded,
            label: 'More',
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? const Color(0xFF6046A5)
        : const Color(0xFF92929B);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: color,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: isSelected
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
class RoleAccess extends StatelessWidget {
  final String searchQuery;

  const RoleAccess({
    super.key,
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
          return Center(
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
                  state.message,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    context.read<RoleCubit>().retry();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
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
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              return RoleCard(
                role: roles[index],
              );
            },
          );
        }

        return const _NoRolesFound();
      },
    );
  }
}class RoleCard extends StatelessWidget {
  final RoleEntity role;

  const RoleCard({
    super.key,
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
}class _NoRolesFound extends StatelessWidget {
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
                color: Color(0xFF303039),
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