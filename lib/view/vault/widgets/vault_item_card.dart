import 'package:flutter/material.dart';
import 'package:my_assist/utils/colors.dart';

class VaultItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const VaultItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final platform =
        item['platform']?.toString().trim().isNotEmpty == true
            ? item['platform'].toString()
            : 'Account';

    final username = item['username']?.toString() ?? '';
    final email = item['email']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: mobileSearchColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: secondaryColor.withValues(alpha: .16),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: mobileBackgroundColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.language_rounded,
            color: primaryColor,
          ),
        ),
        title: Text(
          platform,
          style: const TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            username.isNotEmpty ? username : email,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: secondaryColor,
            ),
          ),
        ),
        trailing: PopupMenuButton<String>(
          color: mobileSearchColor,
          icon: const Icon(
            Icons.more_vert_rounded,
            color: secondaryColor,
          ),
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'edit',
              child: Text(
                'Edit',
                style: TextStyle(
                  color: primaryColor,
                ),
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text(
                'Delete',
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
