import 'dart:convert';
import 'dart:typed_data';

import 'package:hive_flutter/hive_flutter.dart';

class UserProfile {
  static const String boxName = 'userProfile';
  static const String nameKey = 'name';
  static const String photoKey = 'photoBase64';

  static Box<String> get _box => Hive.box<String>(boxName);

  static Future<void> init() async {
    await Hive.openBox<String>(boxName);
  }

  static String get name {
    return (_box.get(nameKey) ?? '').trim();
  }

  static Uint8List? get photoBytes {
    final encoded = _box.get(photoKey);

    if (encoded == null || encoded.isEmpty) return null;

    try {
      return base64Decode(encoded);
    } on FormatException {
      return null;
    }
  }

  static bool get isComplete {
    return name.isNotEmpty && (photoBytes?.isNotEmpty ?? false);
  }

  static Future<void> saveProfile({
    required String name,
    required Uint8List photo,
  }) async {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      throw ArgumentError('Please enter your name.');
    }

    if (photo.isEmpty) {
      throw ArgumentError('Please select a photo.');
    }

    await _box.putAll({
      nameKey: trimmedName,
      photoKey: base64Encode(photo),
    });
  }

  // Retained for compatibility with the earlier name-only code.
  static Future<void> saveName(String value) async {
    final trimmedName = value.trim();

    if (trimmedName.isEmpty) {
      throw ArgumentError('Please enter your name.');
    }

    await _box.put(nameKey, trimmedName);
  }
}