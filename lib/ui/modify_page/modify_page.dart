import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moody/ui/splash_gpt/gpt_tag.dart';
import 'package:moody/ui/splash_gpt/gpt_api.dart';
import 'package:flutter/cupertino.dart';

class ModifyPage extends StatefulWidget {
  final String year; // 선택된 연도
  final String monthName; // 선택된 월 이름
  final String dayId; // 선택된 날짜의 ID
  final DateTime selectedTimestamp; // 해당 일기의 타임스탬프

  const ModifyPage({
    super.key,
    required this.year,
    required this.monthName,
    required this.dayId,
    required this.selectedTimestamp,
  });

  @override
  State<ModifyPage> createState() => _ModifyPageState();
}

class _ModifyPageState extends State<ModifyPage> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = true;
  late final String docPath; // Firestore 문서 경로
  List<String>? _emotions;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    // Firestore 문서 경로 지정
    docPath =
        'date/year/${widget.year}/month/${widget.monthName}/${widget.dayId}';
    _fetchDiary(); // 일기 데이터 불러오기
  }

  //해당 날짜의 일기 불러오기
  Future<void> _fetchDiary() async {
    final doc = await FirebaseFirestore.instance.doc(docPath).get();

    if (doc.exists && doc.data() != null) {
      final data = doc.data() as Map<String, dynamic>;
      final List<dynamic> rawContents = data['contents'] ?? [];

      // 각 일기 항목을 Map으로 변환 및 timestamp 변환
        final List<Map<String, dynamic>> contents = rawContents.map((item) {
        final map = Map<String, dynamic>.from(item);
        if (map['timestamp'] is Timestamp) {
          map['timestamp'] = (map['timestamp'] as Timestamp).toDate();
        }
        return map;
      }).toList();
      // 선택한 timestamp와 일치하는 항목 찾기
      final selectedEntry = contents.firstWhere(
          (entry) => entry['timestamp'] == widget.selectedTimestamp,
          orElse: () => <String, dynamic>{});

      // 해당 항목이 있으면 텍스트 필드와 감정 태그 업데이트
      if (selectedEntry.isNotEmpty) {
        _controller.text = selectedEntry['content'] ?? '';
        setState(() {
          _emotions = selectedEntry['emotions'] != null
              ? List<String>.from(selectedEntry['emotions'])
              : null;
        });
      }
    } else {
      _controller.text = '';
    }

    setState(() {
      _loading = false;
    });
  }

  // DB에 일기 내용 수정 업데이트
  Future<void> _updateDiary() async {
    final doc = await FirebaseFirestore.instance.doc(docPath).get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data() as Map<String, dynamic>;
      final List<dynamic> rawContents = data['contents'] ?? [];
      final List<Map<String, dynamic>> contents = rawContents.map((item) {
        final map = Map<String, dynamic>.from(item);
        if (map['timestamp'] is Timestamp) {
          map['timestamp'] = (map['timestamp'] as Timestamp).toDate();
        }
        return map;
      }).toList();

      // 수정 대상 항목 찾기
      final int indexToUpdate = contents.indexWhere(
          (entry) => entry['timestamp'] == widget.selectedTimestamp);

      if (indexToUpdate != -1) {
        contents[indexToUpdate] = {
          'content': _controller.text,
          'emotions': _emotions,
          'timestamp': DateTime.now(), // Update timestamp on modification
        };
      }

      // DB에 업데이트
      await FirebaseFirestore.instance.doc(docPath).update({
        'contents': contents,
        'day': int.parse(widget.dayId),
      });
    }

    // 완료 메세지
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('수정 완료', style: GoogleFonts.getFont('Roboto')),
      ),
    );
    Navigator.pop(context, true);
  }

  // GPT를 통한 감정 분석 실행
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
      final emotions = await GptApi.analyzeEmotions(text);// GPT API 호출
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

  // 삭제 알림창
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
              final doc = await FirebaseFirestore.instance.doc(docPath).get();
              if (doc.exists && doc.data() != null) {
                final data = doc.data() as Map<String, dynamic>;
                final List<dynamic> rawContents = data['contents'] ?? [];
                final List<Map<String, dynamic>> contents =
                    rawContents.map((item) {
                  final map = Map<String, dynamic>.from(item);
                  if (map['timestamp'] is Timestamp) {
                    map['timestamp'] = (map['timestamp'] as Timestamp).toDate();
                  }
                  return map;
                }).toList();

                // 선택된 타임스탬프와 일치하지 않는 항목만 필터링
                contents.removeWhere(
                    (entry) => entry['timestamp'] == widget.selectedTimestamp);

                await FirebaseFirestore.instance.doc(docPath).update({
                  'contents': contents,
                  'day': int.parse(widget.dayId),
                });
              }
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
          // 삭제 버튼
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.brown),
            onPressed: _showDeleteDialog,
          ),
        ],
      ),
      // 데이터 로딩 중이면 로딩 표시
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (_emotions != null) GptTag(emotions: _emotions!),// 감정 태그 표시
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
                          decoration:
                              const InputDecoration.collapsed(hintText: ''),
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
                      onPressed: _updateDiary,
                      child: Text(
                        '수정하기',
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
