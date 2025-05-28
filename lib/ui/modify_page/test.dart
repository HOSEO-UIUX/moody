import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _TestPage();
}

class _TestPage extends State<TestPage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  var name = "??";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('test page'),),
      body: Center(
        child: Container(
          child: Column(
            children: [
              SizedBox(height: 100,),
              Text(name),
              ElevatedButton(onPressed: () async{
                DocumentSnapshot YspiYClpvYVfmRUh8oAOData = await firestore.collection('test').doc('YspiYClpvYVfmRUh8oAO').get();
                setState(() {
                  name = YspiYClpvYVfmRUh8oAOData['test'];
                });
              },
                  child: Text('load data'))
            ],
          ),
        ),
      ),
    );
  }
}