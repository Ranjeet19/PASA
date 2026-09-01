import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_assist/utils/colors.dart';

import '../data/vault_store.dart';

class AddAccountPage extends StatefulWidget {
  final Map<String, dynamic>? existing;

  const AddAccountPage({
    super.key,
    this.existing,
  });

  @override
  State<AddAccountPage> createState() => _AddAccountPageState();
}

class _AddAccountPageState extends State<AddAccountPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _platformController;
  late final TextEditingController _emailController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _additionalInfoController;

  bool _obscurePassword = true;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();

    final item = widget.existing;

    _platformController = TextEditingController(
      text: item?['platform']?.toString() ?? '',
    );
    _emailController = TextEditingController(
      text: item?['email']?.toString() ?? '',
    );
    _usernameController = TextEditingController(
      text: item?['username']?.toString() ?? '',
    );
    _passwordController = TextEditingController(
      text: item?['password']?.toString() ?? '',
    );
    _additionalInfoController = TextEditingController(
      text: item?['additionalInfo']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _platformController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _additionalInfoController.dispose();

    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;

    setState(() {
      _saving = true;
    });

    try {
      final data = <String, dynamic>{
        'type': 'account',
        'platform': _platformController.text.trim(),
        'email': _emailController.text.trim(),
        'username': _usernameController.text.trim(),
        'password': _passwordController.text,
        'additionalInfo': _additionalInfoController.text.trim(),
      };

      if (_isEditing) {
        await VaultStore.update(
          widget.existing!['id'].toString(),
          data,
        );
      } else {
        await VaultStore.save(data);
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save account.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  InputDecoration _decoration(
    String label,
    IconData icon, {
    String? hint,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: secondaryColor,
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: mobileSearchColor,
      labelStyle: const TextStyle(
        color: secondaryColor,
      ),
      hintStyle: const TextStyle(
        color: secondaryColor,
      ),
      errorStyle: const TextStyle(
        color: Colors.redAccent,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(
          color: primaryColor,
          width: 1.2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
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
        title: Text(
          _isEditing ? 'Edit Account' : 'Add Account',
          style: const TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            18,
            10,
            18,
            30,
          ),
          children: [
            const Text(
              'Account details',
              style: TextStyle(
                color: primaryColor,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Store login information securely inside your Vault.',
              style: TextStyle(
                color: secondaryColor,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 22),
            TextFormField(
              controller: _platformController,
              style: const TextStyle(
                color: primaryColor,
              ),
              textInputAction: TextInputAction.next,
              decoration: _decoration(
                'Platform / App name',
                Icons.apps_rounded,
                hint: 'Instagram, Facebook, Google...',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter the platform name';
                }

                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              style: const TextStyle(
                color: primaryColor,
              ),
              decoration: _decoration(
                'Email',
                Icons.email_outlined,
                hint: 'example@email.com',
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _usernameController,
              textInputAction: TextInputAction.next,
              style: const TextStyle(
                color: primaryColor,
              ),
              decoration: _decoration(
                'Username / UID',
                Icons.person_outline_rounded,
                hint: '@username',
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: const TextStyle(
                color: primaryColor,
              ),
              decoration: _decoration(
                'Password',
                Icons.password_rounded,
                hint: 'Enter password',
                suffix: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: secondaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _additionalInfoController,
              minLines: 4,
              maxLines: 8,
              keyboardType: TextInputType.multiline,
              style: const TextStyle(
                color: primaryColor,
                height: 1.45,
              ),
              decoration: _decoration(
                'Additional information',
                Icons.notes_rounded,
                hint:
                    'Recovery code, backup key, recovery email, 2FA details or anything else...',
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: mobileSearchColor,
                borderRadius: BorderRadius.circular(17),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: secondaryColor,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Use Additional information for recovery codes, backup keys, security notes, recovery email addresses, 2FA details or any other information related to this account.',
                      style: TextStyle(
                        color: secondaryColor,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 54,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: mobileBackgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: mobileBackgroundColor,
                        ),
                      )
                    : Text(
                        _isEditing ? 'Update Account' : 'Save Account',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
