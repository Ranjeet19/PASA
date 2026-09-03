import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_assist/utils/colors.dart';

import '../data/vault_store.dart';
import '../widgets/vault_item_card.dart';
import 'add_account_page.dart';
import 'vault_pin_page.dart';
import 'vault_settings_page.dart';

class VaultPage extends StatefulWidget {
  const VaultPage({super.key});

  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage>
    with WidgetsBindingObserver {
  List<Map<String, dynamic>> _accounts = [];

  bool _loading = true;
  bool _locked = false;
  bool _unlockDialogOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAccounts();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _locked = true;
    }

    if (state == AppLifecycleState.resumed &&
        _locked &&
        !_unlockDialogOpen) {
      _unlockAfterResume();
    }
  }

  Future<void> _unlockAfterResume() async {
    if (!mounted) return;

    _unlockDialogOpen = true;

    final unlocked = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const VaultPinPage(),
      ),
    );

    _unlockDialogOpen = false;

    if (!mounted) return;

    if (unlocked == true) {
      _locked = false;
      await _loadAccounts();
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _loadAccounts() async {
    setState(() {
      _loading = true;
    });

    final accounts = await VaultStore.getByType('account');

    if (!mounted) return;

    setState(() {
      _accounts = accounts;
      _loading = false;
    });
  }

  Future<void> _addAccount() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddAccountPage(),
      ),
    );

    if (changed == true) {
      await _loadAccounts();
    }
  }

  Future<void> _editAccount(
    Map<String, dynamic> account,
  ) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddAccountPage(
          existing: account,
        ),
      ),
    );

    if (changed == true) {
      await _loadAccounts();
    }
  }

  Future<void> _deleteAccount(
    Map<String, dynamic> account,
  ) async {
    final platform =
        account['platform']?.toString() ?? 'this account';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: mobileSearchColor,
        title: const Text(
          'Delete account?',
          style: TextStyle(
            color: primaryColor,
          ),
        ),
        content: Text(
          'Delete $platform permanently?',
          style: const TextStyle(
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

    await VaultStore.delete(
      account['id'].toString(),
    );

    await _loadAccounts();
  }

  Future<void> _showAccount(
    Map<String, dynamic> account,
  ) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: mobileBackgroundColor,
      isScrollControlled: true,
      builder: (_) => _AccountDetailsSheet(
        account: account,
      ),
    );
  }

  void _lockAndExit() {
    _locked = true;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const background =
        kIsWeb ? webBackgroundColor : mobileBackgroundColor;

    return WillPopScope(
      onWillPop: () async {
        _locked = true;
        return true;
      },
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: background,
          foregroundColor: primaryColor,
          elevation: 0,
          title: const Text(
            'Vault',
            style: TextStyle(
              color: primaryColor,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Lock Vault',
              onPressed: _lockAndExit,
              icon: const Icon(
                Icons.lock_outline_rounded,
                color: primaryColor,
              ),
            ),
            IconButton(
              tooltip: 'Settings',
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VaultSettingsPage(),
                  ),
                );

                await _loadAccounts();
              },
              icon: const Icon(
                Icons.settings_outlined,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 6),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: primaryColor,
          foregroundColor: mobileBackgroundColor,
          onPressed: _addAccount,
          icon: const Icon(
            Icons.add_rounded,
          ),
          label: const Text(
            'Add Account',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _loadAccounts,
          color: mobileBackgroundColor,
          backgroundColor: primaryColor,
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                  ),
                )
              : _accounts.isEmpty
                  ? ListView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      padding:
                          const EdgeInsets.fromLTRB(28, 90, 28, 130),
                      children: const [
                        Icon(
                          Icons.lock_outline_rounded,
                          color: primaryColor,
                          size: 62,
                        ),
                        SizedBox(height: 22),
                        Text(
                          'Your Vault is empty',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 9),
                        Text(
                          'Add an account to securely store platform name, email, username, password and additional recovery information.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: secondaryColor,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      padding:
                          const EdgeInsets.fromLTRB(18, 10, 18, 120),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          margin: const EdgeInsets.only(bottom: 18),
                          decoration: BoxDecoration(
                            color: mobileSearchColor,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: secondaryColor.withValues(alpha: .15),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: mobileBackgroundColor,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Icon(
                                  Icons.shield_outlined,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(width: 13),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Private & protected',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_accounts.length} saved account${_accounts.length == 1 ? '' : 's'}',
                                      style: const TextStyle(
                                        color: secondaryColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        ..._accounts.map(
                          (account) => VaultItemCard(
                            item: account,
                            onTap: () => _showAccount(account),
                            onEdit: () => _editAccount(account),
                            onDelete: () => _deleteAccount(account),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}

class _AccountDetailsSheet extends StatefulWidget {
  final Map<String, dynamic> account;

  const _AccountDetailsSheet({
    required this.account,
  });

  @override
  State<_AccountDetailsSheet> createState() =>
      _AccountDetailsSheetState();
}

class _AccountDetailsSheetState
    extends State<_AccountDetailsSheet> {
  bool _showPassword = false;

  Future<void> _copy(
    String value,
  ) async {
    await Clipboard.setData(
      ClipboardData(
        text: value,
      ),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard.'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Widget _field(
    String label,
    String value, {
    bool password = false,
  }) {
    if (value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final visibleValue =
        password && !_showPassword
            ? '••••••••••••'
            : value;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: mobileSearchColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: secondaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                SelectableText(
                  visibleValue,
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (password)
            IconButton(
              onPressed: () {
                setState(() {
                  _showPassword = !_showPassword;
                });
              },
              icon: Icon(
                _showPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: secondaryColor,
              ),
            ),
          IconButton(
            onPressed: () => _copy(value),
            icon: const Icon(
              Icons.copy_outlined,
              color: secondaryColor,
              size: 19,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final account = widget.account;

    final platform =
        account['platform']?.toString() ?? '';

    final email =
        account['email']?.toString() ?? '';

    final username =
        account['username']?.toString() ?? '';

    final password =
        account['password']?.toString() ?? '';

    final additionalInfo =
        account['additionalInfo']?.toString() ?? '';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: secondaryColor.withOpacity(.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                platform.isEmpty ? 'Account' : platform,
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              _field('Email', email),
              _field('Username / UID', username),
              _field(
                'Password',
                password,
                password: true,
              ),
              _field(
                'Additional information',
                additionalInfo,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
