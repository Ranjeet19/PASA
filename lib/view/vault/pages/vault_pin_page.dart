import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_assist/utils/colors.dart';

import '../data/vault_store.dart';
import '../widgets/pin_pad.dart';

class VaultPinPage extends StatefulWidget {
  final bool setup;
  final bool change;

  const VaultPinPage({
    super.key,
    this.setup = false,
    this.change = false,
  });

  @override
  State<VaultPinPage> createState() => _VaultPinPageState();
}

class _VaultPinPageState extends State<VaultPinPage> {
  String _pin = '';
  String _firstPin = '';
  String? _error;
  bool _busy = false;

  String get _title {
    if (widget.setup) {
      return _firstPin.isEmpty ? 'Create PIN' : 'Confirm PIN';
    }
    if (widget.change) {
      return _firstPin.isEmpty ? 'Current PIN' : 'New PIN';
    }
    return 'Unlock Vault';
  }

  String get _subtitle {
    if (widget.setup) {
      return _firstPin.isEmpty
          ? 'Create a 4-digit PIN to protect your Vault'
          : 'Enter the same PIN again to confirm it';
    }
    if (widget.change) {
      return _firstPin.isEmpty
          ? 'Enter your current PIN'
          : 'Enter your new 4-digit PIN';
    }
    return 'Enter your 4-digit PIN to continue';
  }

  Future<void> _submit(String value) async {
    if (value.length != 4 || _busy) return;

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      if (widget.setup) {
        if (_firstPin.isEmpty) {
          setState(() {
            _firstPin = value;
            _pin = '';
          });
          return;
        }

        if (_firstPin != value) {
          setState(() {
            _firstPin = '';
            _pin = '';
            _error = 'PINs do not match. Try again.';
          });
          return;
        }

        await VaultStore.setPin(value);
        if (mounted) Navigator.pop(context, true);
        return;
      }

      if (widget.change) {
        if (_firstPin.isEmpty) {
          final valid = await VaultStore.verifyPin(value);
          if (!mounted) return;

          if (!valid) {
            setState(() {
              _pin = '';
              _error = 'Current PIN is incorrect.';
            });
            return;
          }

          setState(() {
            _firstPin = value;
            _pin = '';
          });
          return;
        }

        await VaultStore.setPin(value);
        if (!mounted) return;
        Navigator.pop(context, true);
        return;
      }

      final valid = await VaultStore.verifyPin(value);
      if (!mounted) return;

      if (valid) {
        Navigator.pop(context, true);
      } else {
        setState(() {
          _pin = '';
          _error = 'Incorrect PIN. Try again.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pin = '';
        _error = 'Unable to use Vault PIN. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const background = kIsWeb ? webBackgroundColor : mobileBackgroundColor;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          'Vault',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: mobileSearchColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      color: primaryColor,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _title,
                    style: const TextStyle(
                      color: primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: secondaryColor,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 13,
                        height: 13,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index < _pin.length
                              ? primaryColor
                              : mobileSearchColor,
                          border: Border.all(
                            color: secondaryColor.withValues(alpha: .5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
                  if (_busy) ...[
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                  IgnorePointer(
                    ignoring: _busy,
                    child: PinPad(
                      pin: _pin,
                      onChanged: (value) {
                        setState(() {
                          _pin = value;
                          _error = null;
                        });

                        if (value.length == 4) {
                          _submit(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
