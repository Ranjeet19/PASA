// import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:my_assist/home_page.dart';
import 'package:my_assist/services/user_profile.dart';
import 'package:my_assist/utils/colors.dart';

class NameSetupScreen extends StatefulWidget {
  const NameSetupScreen({super.key});

  @override
  State<NameSetupScreen> createState() => _NameSetupScreenState();
}

class _NameSetupScreenState extends State<NameSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _picker = ImagePicker();

  Uint8List? _photo;
  bool _saving = false;
  bool _picking = false;

  bool get _busy => _saving || _picking;

  @override
  void initState() {
    super.initState();

    _nameController.text = UserProfile.name;
    _photo = UserProfile.photoBytes;

    // Recover a selection if Android restarted the app
    // while the gallery was open.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      _picking = true;
      _recoverPhoto();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _loadPhoto(XFile file) async {
    const maxBytes = 5 * 1024 * 1024;

    if (await file.length() > maxBytes) {
      _showMessage('Please choose a photo smaller than 5 MB.');
      return;
    }

    final bytes = await file.readAsBytes();

    if (bytes.isEmpty || bytes.length > maxBytes) {
      _showMessage('Please choose a valid photo smaller than 5 MB.');
      return;
    }

    // Confirm Flutter can display this image before accepting it.
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: 512,
    );

    try {
      final frame = await codec.getNextFrame();
      frame.image.dispose();
    } finally {
      codec.dispose();
    }

    if (!mounted) return;

    setState(() {
      _photo = bytes;
    });
  }

  Future<void> _recoverPhoto() async {
    try {
      final result = await _picker.retrieveLostData();
      final files = result.files;

      if (files != null && files.isNotEmpty) {
        await _loadPhoto(files.first);
      } else if (result.exception != null) {
        _showMessage('Please select your photo again.');
      }
    } catch (_) {
      _showMessage('Please select your photo again.');
    } finally {
      if (mounted) {
        setState(() {
          _picking = false;
        });
      }
    }
  }

  Future<void> _pickPhoto() async {
    if (_busy) return;

    setState(() {
      _picking = true;
    });

    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        requestFullMetadata: false,
      );

      if (file != null) {
        await _loadPhoto(file);
      }
    } catch (_) {
      _showMessage(
        'Unable to open this photo. Please try a JPG or PNG image.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _picking = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_busy || !_formKey.currentState!.validate()) return;

    final photo = _photo;

    if (photo == null) {
      _showMessage('Please select your profile photo.');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _saving = true;
    });

    try {
      await UserProfile.saveProfile(
        name: _nameController.text,
        photo: photo,
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      _showMessage('Unable to save your profile. Please try again.');
      return;
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const HomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photo = _photo;

    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Welcome to PASA',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Add your name and profile photo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 28),

                    Center(
                      child: Semantics(
                        button: true,
                        label: 'Choose profile photo',
                        child: GestureDetector(
                          onTap: _busy ? null : _pickPhoto,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: primaryColor,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.grey.shade900,
                              backgroundImage:
                                  photo == null ? null : MemoryImage(photo),
                              child: photo == null
                                  ? const Icon(
                                      Icons.add_a_photo_outlined,
                                      size: 36,
                                      color: primaryColor,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ),

                    TextButton(
                      onPressed: _busy ? null : _pickPhoto,
                      child: Text(
                        _picking
                            ? 'Loading photo...'
                            : photo == null
                                ? 'Choose photo'
                                : 'Change photo',
                        style: const TextStyle(color: primaryColor),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _nameController,
                      enabled: !_saving,
                      maxLength: 80,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.name],
                      cursorColor: primaryColor,
                      style: const TextStyle(color: primaryColor),
                      decoration: const InputDecoration(
                        labelText: 'Your name',
                        labelStyle: TextStyle(color: primaryColor),
                        counterStyle: TextStyle(color: primaryColor),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: primaryColor,
                            width: 2,
                          ),
                        ),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name.';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _saveProfile(),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _busy ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: mobileBackgroundColor,
                        disabledBackgroundColor: Colors.grey,
                        disabledForegroundColor: mobileBackgroundColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(_saving ? 'Saving...' : 'Continue'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}