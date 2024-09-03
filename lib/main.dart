import 'package:flutter/material.dart';
import 'package:my_assist/home_page.dart';
import 'package:my_assist/utils/colors.dart';
import 'package:my_assist/view/todo.dart';

void main() {
  runApp(const MyApp());
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

      home: HomePage(),
    );
  }
}