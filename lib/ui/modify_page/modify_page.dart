import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moody/ui/splash_gpt/gpt_tag.dart';
import 'package:moody/ui/splash_gpt/gpt_api.dart';

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
  List<String>? _emotions;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    docPath =
        'date/year/${widget.year}/month/${widget.monthName}/${widget.dayId}';
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
      SnackBar(
        content: Text('수정 완료', style: GoogleFonts.getFont('Roboto')),
      ),
    );
    Navigator.pop(context, true);
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

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('삭제 확인',
            style: GoogleFonts.getFont('Roboto', fontWeight: FontWeight.bold)),
        content:
            Text('정말 이 일기를 삭제하시겠습니까?', style: GoogleFonts.getFont('Roboto')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소', style: GoogleFonts.getFont('Roboto')),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.doc(docPath).delete();
              Navigator.pop(context);
              Navigator.pop(context, true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('삭제 완료', style: GoogleFonts.getFont('Roboto'))),
              );
            },
            child: Text('삭제',
                style: GoogleFonts.getFont('Roboto', color: Colors.red)),
          ),
        ],
      ),
    );
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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          '마이 로그',
          style: GoogleFonts.getFont(
            'Roboto',
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
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
            onPressed: _showDeleteDialog,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
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
                          style: GoogleFonts.getFont('Roboto', fontSize: 14),
                          decoration:
                              const InputDecoration.collapsed(hintText: ''),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _updateDiary,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text(
                        '수정하기',
                        style: GoogleFonts.getFont(
                          'Roboto',
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
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
