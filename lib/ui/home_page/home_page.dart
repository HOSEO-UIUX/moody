// lib/ui/home_page.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moody/ui/write_page/write_page.dart';
import 'package:moody/ui/modify_page/modify_page.dart';
import 'package:google_fonts/google_fonts.dart'; // 구글 폰트 라이브러리 import

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime _selectedMonth;
  late int _yearPickerInitialIndex;
  late int _monthPickerInitialIndex;

  // Firestore 에서 받아온 일기 문서 리스트
  List<QueryDocumentSnapshot> _diaryDocs = [];
  bool _isLoading = true;

  // 연도 선택 리스트 (2025~2050)
  final List<int> _yearList = List.generate(
    2050 - 2025 + 1,
        (i) => 2025 + i,
  );

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
    _yearPickerInitialIndex = _yearList
        .indexOf(_selectedMonth.year)
        .clamp(0, _yearList.length - 1);
    _monthPickerInitialIndex = _selectedMonth.month - 1;

    // Firestore 로 데이터 로드
    _loadData();
  }

  /// 선택된 연·월의 일기를 Firestore 에서 가져오는 메서드
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final query = await FirebaseFirestore.instance
          .collection('diaries')
          .where('year', isEqualTo: _selectedMonth.year)
          .where('month', isEqualTo: _selectedMonth.month)
          .orderBy('day', descending: true) //최신순 내림차순으로 정렬
          .get();
      setState(() {
        _diaryDocs = query.docs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _diaryDocs = [];
        _isLoading = false;
      });
    }
  }

  /// 연·월 선택 피커
  void _showMonthPicker() {
    int tempYear = _yearPickerInitialIndex;
    int tempMonth = _monthPickerInitialIndex;
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            SizedBox(
              height: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('취소'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('완료'),
                    onPressed: () {
                      setState(() {
                        _selectedMonth = DateTime(
                          _yearList[tempYear],
                          tempMonth + 1,
                        );
                        _yearPickerInitialIndex = tempYear;
                        _monthPickerInitialIndex = tempMonth;
                      });
                      Navigator.of(context).pop();
                      _loadData(); // 월 변경 시 재로드
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: tempYear,
                      ),
                      itemExtent: 32,
                      onSelectedItemChanged: (i) => tempYear = i,
                      children: _yearList
                          .map((y) => Center(child: Text('$y', style: TextStyle(fontSize: 16))))
                          .toList(),
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: tempMonth,
                      ),
                      itemExtent: 32,
                      onSelectedItemChanged: (i) => tempMonth = i,
                      children: List.generate(
                        12,
                            (i) => Center(
                          child: Text(
                            '${(i + 1).toString().padLeft(2, '0')}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground,
        border: const Border(
          bottom: BorderSide(color: Colors.blue, width: 2),
        ),
        middle: GestureDetector(
          onTap: _showMonthPicker,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_selectedMonth.year}. ${_selectedMonth.month.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black, // 날짜 텍스트 색상을 검은색으로 고정
                  fontFamily: 'Pretendard', // Pretendard 폰트 적용
                ),
              ),
              const SizedBox(width: 4),
              const Icon(CupertinoIcons.chevron_down, size: 20),
            ],
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : _diaryDocs.isEmpty
                  ? const Center(
                child: Text(
                  '작성된 일기가 없습니다',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Pretendard', // Pretendard 폰트 적용
                  ),
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _diaryDocs.length,
                itemBuilder: (_, idx) {
                  final doc = _diaryDocs[idx];
                  final ts = doc.get('date') as Timestamp;
                  final date = ts.toDate();
                  const wd = ['일', '월', '화', '수', '목', '금', '토'];
                  final w = wd[date.weekday % 7];
                  final tags = List<String>.from(doc.get('tags') ?? []);
                  final content = doc.get('content') as String? ?? '';

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (_) => ModifyPage(doc: doc),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}($w)',
                            style: GoogleFonts.getFont(
                              'Ownglyph PDH', // Ownglyph PDH 폰트 적용
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: tags
                                .map(
                                  (t) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.brown, width: 1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '#$t',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.brown,
                                    fontFamily: 'Pretendard', // Pretendard 폰트 적용
                                  ),
                                ),
                              ),
                            )
                                .toList(),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            content,
                            style: GoogleFonts.getFont(
                              'Ownglyph PDH', // Ownglyph PDH 폰트 적용
                              fontSize: 14,
                              height: 1.4,
                              color: Colors.black,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          const Divider(height: 1, thickness: 1),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                height: 56,
                child: CupertinoButton(
                  color: const Color(0xFF603913),
                  borderRadius: BorderRadius.circular(8),
                  onPressed: () async => await Navigator.of(context).push(
                    CupertinoPageRoute(builder: (_) => WritePage()),
                  ),
                  child: Text(
                    '일기쓰기',
                    style: GoogleFonts.getFont(
                      'Heading 5 R', // Heading 5 R 폰트 적용
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.white,
                    ),
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
