import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String testData = '로딩 중...';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('test').get();

      if (querySnapshot.docs.isNotEmpty) {
        // 첫 번째 문서의 데이터를 가져옵니다
        DocumentSnapshot doc = querySnapshot.docs.first;
        setState(() {
          testData = doc.get('test') ?? '데이터 없음';
        });
      } else {
        setState(() {
          testData = '문서가 존재하지 않습니다';
        });
      }
    } catch (e) {
      setState(() {
        testData = '에러 발생: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(testData),
      ),
    );
  }
}
