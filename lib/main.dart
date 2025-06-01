import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:moody/firebase_options.dart';
import 'package:moody/ui/home_page/home_page.dart';
import 'package:moody/ui/modify_page/test_read_page1.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage_Test(),
    );
  }
}