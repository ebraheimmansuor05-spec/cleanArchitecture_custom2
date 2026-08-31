import 'package:flutter/material.dart';

import '../../domain/entities/workshop_user_entity.dart';

/// A simple ListView for WorkshopUser items.
/// Replace this with your own UI implementation.
class WorkshopUsersRolesList extends StatelessWidget {
  final List<WorkshopUserEntity> items;

  const WorkshopUsersRolesList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('No items found.'));
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          title: Text(item.toString()),
        );
      },
    );
  }
}
