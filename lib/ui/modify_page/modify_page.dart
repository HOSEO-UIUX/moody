import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:moody/ui/modify_page/test_read_page1.dart'; //테스트

class ModifyPage extends StatefulWidget {
  final String year;
  final String monthName;
  final String dayId;

  const ModifyPage({
    super.key,
    required this.year,
    required this.monthName,
    required this.dayId,
  });

  @override
  State<ModifyPage> createState() => _ModifyPageState();
}

class _ModifyPageState extends State<ModifyPage> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = true;
  late final String docPath;

  @override
  void initState() {
    super.initState();
    docPath = 'date/year/${widget.year}/month/${widget.monthName}/${widget.dayId}';
    _fetchDiary();
  }

  Future<void> _fetchDiary() async {
    final doc = await FirebaseFirestore.instance.doc(docPath).get();


    if (doc.exists && doc.data() != null) {
      _controller.text = doc['content'] ?? '';
    } else {
      _controller.text = '';
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _updateDiary() async {


    await FirebaseFirestore.instance.doc(docPath).set({
      'content': _controller.text,
      'day': int.parse(widget.dayId),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('수정 완료')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const SizedBox(),
        title: const Text(
          '마이 로그',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart, color: Colors.brown),
            onPressed: () {},
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration.collapsed(hintText: ''),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: _updateDiary,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text(
                '수정하기',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),

    );
  }

}