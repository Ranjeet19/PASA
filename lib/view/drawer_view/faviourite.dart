import 'package:flutter/material.dart';

class FavView extends StatelessWidget {
  const FavView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: const Center(
          child: Text(
            'Favourite View',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}