import 'package:hive_flutter/hive_flutter.dart';

class UserProfile {
  static const boxName = 'userProfile';
  static const nameKey = 'name';

  static Box<String> get box => Hive.box<String>(boxName);

  static Future<void> init() async {
    await Hive.openBox<String>(boxName);
  }

  static String get name => (box.get(nameKey) ?? '').trim();

  static Future<void> saveName(String value) async {
    final name = value.trim();
    if (name.isEmpty) {
      throw ArgumentError('Please enter your name.');
    }
    await box.put(nameKey, name);
  }
}
