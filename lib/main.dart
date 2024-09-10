import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_assist/home_page.dart';
import 'package:my_assist/utils/colors.dart';
import 'package:my_assist/view/scrollable_view.dart';
import 'package:my_assist/view/notes.dart';
import 'package:my_assist/view/profile.dart';
// import 'package:my_assist/view/drawer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(NoteAdapter());
  await Hive.openBox<Note>('notes');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
       theme: ThemeData(
        scaffoldBackgroundColor: mobileBackgroundColor, // Set global background color here
      ),

      home:  HomePage(),
    );
  }
}