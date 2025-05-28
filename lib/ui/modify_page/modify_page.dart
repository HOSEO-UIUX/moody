import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ModifyPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _ModifyPage();
}

class _ModifyPage extends State<ModifyPage> {

FirebaseFirestore firestore = FirebaseFirestore.instance;
TextEditingController textEditingController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(  // 마이 로그 //////////////////////////////////
        title: Text("마이 로그", style: TextStyle(fontSize: 24)),
        centerTitle: true,
      ),

      body: Column(
        children: [
          Container( //내용  / 텍스트필드////////////////////////////////////////////////////
            child:
            TextField(
              controller: textEditingController,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: '입력하시오.',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          
          Container(   //수정하기 버튼 /////////////////////////////////////////////////
            child: ElevatedButton(onPressed: (){

            }, child: Text('수정하기')),
          )
        ],
      ),
    );
  }
}