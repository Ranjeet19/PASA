import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_assist/utils/colors.dart';

import '../data/vault_store.dart';
import 'vault_pin_page.dart';

class VaultSettingsPage extends StatelessWidget {
  const VaultSettingsPage({super.key});

  Future<void> _deleteAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: mobileSearchColor,
        title: const Text(
          'Delete all Vault data?',
          style: TextStyle(
            color: primaryColor,
          ),
        ),
        content: const Text(
          'This permanently removes every saved Vault item. This action cannot be undone.',
          style: TextStyle(
            color: secondaryColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: primaryColor,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: primaryColor,
            ),
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await VaultStore.clearAll();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All Vault data deleted.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final background =
        kIsWeb ? webBackgroundColor : mobileBackgroundColor;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          'Vault Settings',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _SettingTile(
            icon: Icons.password_rounded,
            title: 'Change PIN',
            subtitle: 'Update the PIN used to unlock your Vault',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const VaultPinPage(
                    change: true,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _SettingTile(
            icon: Icons.delete_sweep_outlined,
            title: 'Delete Vault data',
            subtitle: 'Permanently remove all saved items',
            destructive: true,
            onTap: () => _deleteAll(context),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool destructive;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: mobileSearchColor,
      borderRadius: BorderRadius.circular(20),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: mobileBackgroundColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            icon,
            color: destructive ? Colors.redAccent : primaryColor,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: destructive ? Colors.redAccent : primaryColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            subtitle,
            style: const TextStyle(
              color: secondaryColor,
              fontSize: 12,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: secondaryColor,
        ),
      ),
    );
  }
}
