import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Home',
          style: TextStyle(fontSize: 100, color: Colors.black),
        ),
      ),
    );
  }
}
