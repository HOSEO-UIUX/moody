import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:moody/firebase_options.dart';
import 'package:moody/ui/home_page/home_page.dart';
import 'package:moody/ui/modify_page/modify_page.dart';
import 'package:moody/ui/modify_page/test.dart'; // 파이어베이스 테스트용

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moody App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(), // 홈 화면 위젯
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            // ⭐ Flutter 기본 페이지 이동
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  ModifyPage()),
            );
          },
          child: const Text('Test Page'),
        ),
      ),
      body: const Center(child: Text('Welcome to Moody')),
    );
  }
}
