// lib/ui/modify_page/modify_page.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ModifyPage extends StatefulWidget {
  /// 홈에서 전달된 일기 문서
  final QueryDocumentSnapshot doc;

  /// 생성자: doc 파라미터를 받습니다.
  const ModifyPage({
    Key? key,
    required this.doc,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ModifyPage();
}

class _ModifyPage extends State<ModifyPage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 기존 일기 내용을 텍스트 필드에 초기값으로 설정
    textEditingController.text = widget.doc.get('content') as String? ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("마이 로그", style: TextStyle(fontSize: 24)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: textEditingController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: '입력하시오.',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // TODO: 수정 로직 구현 (예: firestore.collection('diaries').doc(widget.doc.id).update({...}))
              },
              child: Text('수정하기'),
            ),
          ),
        ],
      ),
    );
  }
}
