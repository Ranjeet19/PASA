import 'package:hive_flutter/hive_flutter.dart';

class UserProfile {
  static const String boxName = 'userProfile';
  static const String nameKey = 'name';

  static Future<void> init() async {
    await Hive.openBox<String>(boxName);
  }

  static String get name {
    return (Hive.box<String>(boxName).get(nameKey) ?? '').trim();
  }

  static Future<void> saveName(String value) async {
    final trimmedName = value.trim();

    if (trimmedName.isEmpty) {
      throw ArgumentError('Please enter your name.');
    }

    await Hive.box<String>(boxName).put(nameKey, trimmedName);
  }
}