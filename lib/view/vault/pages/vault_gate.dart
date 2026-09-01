import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_assist/utils/colors.dart';

import '../data/vault_store.dart';
import 'vault_page.dart';
import 'vault_pin_page.dart';

class VaultGate extends StatefulWidget {
  const VaultGate({super.key});

  @override
  State<VaultGate> createState() => _VaultGateState();
}

class _VaultGateState extends State<VaultGate> {
  String? _error;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _open(),
    );
  }

  Future<void> _open() async {
    try {
      await VaultStore.init();

      if (!mounted) return;

      final hasPin = await VaultStore.hasPin();

      if (!mounted) return;

      final unlocked = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => VaultPinPage(
            setup: !hasPin,
          ),
        ),
      );

      if (!mounted) return;

      if (unlocked == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const VaultPage(),
          ),
        );
      } else {
        Navigator.pop(context);
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final background =
        kIsWeb ? webBackgroundColor : mobileBackgroundColor;

    return Scaffold(
      backgroundColor: background,
      body: Center(
        child: _error == null
            ? const CircularProgressIndicator(
                color: primaryColor,
              )
            : Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      color: primaryColor,
                      size: 48,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Unable to open Vault',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: secondaryColor,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 22),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: mobileBackgroundColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _error = null;
                        });

                        _open();
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
