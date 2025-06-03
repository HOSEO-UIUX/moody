import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moody/ui/splash_gpt/gpt_tag.dart';
import 'package:moody/ui/splash_gpt/gpt_api.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';

class WritePage extends StatefulWidget {
  const WritePage({super.key});

  @override
  State<WritePage> createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  final TextEditingController _controller = TextEditingController();
  List<String>? _emotions;
  bool _isAnalyzing = false;

  Future<void> _saveLogToFirestore() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    try {
      final docRef = FirebaseFirestore.instance
          .collection('date')
          .doc('year')
          .collection(year)
          .doc('month')
          .collection(month)
          .doc(day);

      final doc = await docRef.get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final List<Map<String, dynamic>> contents =
            List<Map<String, dynamic>>.from(data['contents'] ?? []);
        contents.add({
          'content': _controller.text,
          'emotions': _emotions,
          'timestamp': DateTime.now(),
        });

        await docRef.update({
          'contents': contents,
          'day': now.day,
        });
      } else {
        await docRef.set({
          'contents': [
            {
              'content': _controller.text,
              'emotions': _emotions,
              'timestamp': DateTime.now(),
            }
          ],
          'day': now.day,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('작성 완료')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $e')),
      );
    }
  }

  void _clearTextField() {
    _controller.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('작성 내용이 초기화되었습니다')),
    );
  }

  Future<void> _analyzeEmotions() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('분석할 내용을 입력해주세요')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final emotions = await GptApi.analyzeEmotions(text);
      setState(() {
        _emotions = emotions;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '마이 로그',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: _isAnalyzing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
                    ),
                  )
                : const Icon(Icons.show_chart, color: Colors.brown),
            onPressed: _isAnalyzing ? null : _analyzeEmotions,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.brown),
            onPressed: _clearTextField,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          children: [
            if (_emotions != null) GptTag(emotions: _emotions!),
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
                    style: const TextStyle(
                      fontFamily: 'OnGleIpParkDaHyun',
                      fontSize: 18,
                      height: 1.4,
                      color: Color(0xff494545),
                    ),
                    decoration: const InputDecoration.collapsed(hintText: ''),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: CupertinoButton(
                color: const Color(0xFF603913),
                borderRadius: BorderRadius.circular(8),
                onPressed: _saveLogToFirestore,
                child: Text(
                  '작성하기',
                  style: GoogleFonts.getFont(
                    'Roboto',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
