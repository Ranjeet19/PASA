import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class VaultStore {
  VaultStore._();

  static const String _boxName = 'pasa_vault_box';
  static const String _encryptionKeyName = 'pasa_vault_encryption_key';
  static const String _pinHashName = 'pasa_vault_pin_hash';
  static const String _pinSaltName = 'pasa_vault_pin_salt';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Box<Map>? _box;
  static Future<void>? _initFuture;

  static Future<void> init() {
    return _initFuture ??= _initialize();
  }

  static Future<void> _initialize() async {
    if (_box != null && _box!.isOpen) return;

    await Hive.initFlutter();

    var encodedKey = await _secureStorage.read(key: _encryptionKeyName);

    if (encodedKey == null || encodedKey.isEmpty) {
      final random = Random.secure();
      final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));
      encodedKey = base64UrlEncode(keyBytes);

      await _secureStorage.write(
        key: _encryptionKeyName,
        value: encodedKey,
      );
    }

    final encryptionKey = base64Url.decode(encodedKey);

    if (encryptionKey.length != 32) {
      throw StateError('Invalid Vault encryption key.');
    }

    _box = await Hive.openBox<Map>(
      _boxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }

  static Box<Map> get box {
    final currentBox = _box;

    if (currentBox == null || !currentBox.isOpen) {
      throw StateError(
        'Vault storage is not initialized. Call await VaultStore.init() first.',
      );
    }

    return currentBox;
  }

  static Future<bool> hasPin() async {
    final hash = await _secureStorage.read(key: _pinHashName);
    final salt = await _secureStorage.read(key: _pinSaltName);

    return hash != null &&
        hash.isNotEmpty &&
        salt != null &&
        salt.isNotEmpty;
  }

  static String _hashPin(String pin, String salt) {
    return sha256.convert(utf8.encode('$salt:$pin')).toString();
  }

  static Future<void> setPin(String pin) async {
    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      throw ArgumentError('PIN must contain exactly 4 digits.');
    }

    final random = Random.secure();
    final salt = base64UrlEncode(
      List<int>.generate(32, (_) => random.nextInt(256)),
    );

    await _secureStorage.write(key: _pinSaltName, value: salt);
    await _secureStorage.write(
      key: _pinHashName,
      value: _hashPin(pin, salt),
    );
  }

  static Future<bool> verifyPin(String pin) async {
    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      return false;
    }

    final savedHash = await _secureStorage.read(key: _pinHashName);
    final salt = await _secureStorage.read(key: _pinSaltName);

    if (savedHash == null ||
        savedHash.isEmpty ||
        salt == null ||
        salt.isEmpty) {
      return false;
    }

    return _hashPin(pin, salt) == savedHash;
  }

  static Future<bool> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    final valid = await verifyPin(currentPin);

    if (!valid) return false;

    await setPin(newPin);

    return true;
  }

  static Future<void> save(Map<String, dynamic> data) async {
    await init();

    final random = Random.secure();
    final id =
        '${DateTime.now().microsecondsSinceEpoch}_${random.nextInt(1000000)}';

    final item = Map<String, dynamic>.from(data);

    item['id'] = id;
    item['createdAt'] = DateTime.now().toIso8601String();

    await box.put(id, item);
  }

  static Future<void> update(
    String id,
    Map<String, dynamic> data,
  ) async {
    await init();

    final old = box.get(id);
    final item = Map<String, dynamic>.from(data);

    item['id'] = id;
    item['createdAt'] =
        old?['createdAt']?.toString() ?? DateTime.now().toIso8601String();
    item['updatedAt'] = DateTime.now().toIso8601String();

    await box.put(id, item);
  }

  static Future<List<Map<String, dynamic>>> getAll() async {
    await init();

    final items = box.values
        .map((value) => Map<String, dynamic>.from(value))
        .toList();

    items.sort(
      (a, b) => (b['createdAt']?.toString() ?? '')
          .compareTo(a['createdAt']?.toString() ?? ''),
    );

    return items;
  }

  static Future<List<Map<String, dynamic>>> getByType(String type) async {
    final allItems = await getAll();
    return allItems.where((item) => item['type'] == type).toList();
  }

  static Future<Map<String, dynamic>?> getItem(String id) async {
    await init();
    final value = box.get(id);

    if (value == null) return null;

    return Map<String, dynamic>.from(value);
  }

  static Future<void> delete(String id) async {
    await init();
    await box.delete(id);
  }

  static Future<void> clearAll() async {
    await init();
    await box.clear();
  }
}
