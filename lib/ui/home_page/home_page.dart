// lib/ui/home_page.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moody/ui/write_page/write_page.dart';
import 'package:moody/ui/modify_page/modify_page.dart';
import 'package:google_fonts/google_fonts.dart'; // Google Fonts 패키지 import

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
    // 현재 연·월로 초기화
    _selectedMonth = DateTime(now.year, now.month);
    _yearPickerInitialIndex =
        _yearList.indexOf(_selectedMonth.year).clamp(0, _yearList.length - 1);
    _monthPickerInitialIndex = _selectedMonth.month - 1;

    // 초기 데이터 로드
    _loadData();
  }

  /// ================================================
  /// Firestore의 중첩된 컬렉션 구조를 타고
  /// 해당 연·월의 문서들을 가져오는 메서드
  /// ================================================
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true; // 로딩 인디케이터 표시
    });

    try {
      // 연·월을 두 자리 문자열로 변환 (ex: "2025", "05")
      final String yearStr = _selectedMonth.year.toString();
      final String monthStr = _selectedMonth.month.toString().padLeft(2, '0');

      // 중첩된 경로를 타고 들어가서 해당 월의 문서 전체 가져오기
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('date')       // (1) 최상위 컬렉션: date
          .doc('year')              // (2) 년도 구분 문서 ID: year
          .collection(yearStr)      // (3) 연도별 컬렉션: ex) "2025"
          .doc('month')             // (4) 월 구분 문서 ID: month
          .collection(monthStr)     // (5) 월별 컬렉션: ex) "05"
          .orderBy('day', descending: false) // day 필드 기준 내림차순 정렬
          .get();

      // 가져온 문서 리스트를 상태에 저장하고 로딩 해제
      setState(() {
        _diaryDocs = querySnapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      // 에러 발생 시 빈 리스트로 만들고 로딩 해제
      setState(() {
        _diaryDocs = [];
        _isLoading = false;
      });
      debugPrint('→ _loadData() 중 에러 발생: $e');
    }
  }

  /// 연·월 선택용 CupertinoPicker 팝업
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
            // 상단에 취소/완료 버튼
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
                      // 선택된 연·월을 _selectedMonth로 반영
                      setState(() {
                        _selectedMonth = DateTime(
                          _yearList[tempYear],
                          tempMonth + 1,
                        );
                        _yearPickerInitialIndex = tempYear;
                        _monthPickerInitialIndex = tempMonth;
                      });
                      Navigator.of(context).pop();
                      _loadData(); // 월 변경하면 데이터 재로드
                    },
                  ),
                ],
              ),
            ),

            // 하단에 두 개의 피커(연도, 월)
            Expanded(
              child: Row(
                children: [
                  // 연도 피커
                  Expanded(
                    child: CupertinoPicker(
                      scrollController:
                      FixedExtentScrollController(initialItem: tempYear),
                      itemExtent: 32,
                      onSelectedItemChanged: (i) => tempYear = i,
                      children: _yearList
                          .map((y) => Center(
                          child:
                          Text('$y', style: const TextStyle(fontSize: 16))))
                          .toList(),
                    ),
                  ),
                  // 월 피커
                  Expanded(
                    child: CupertinoPicker(
                      scrollController:
                      FixedExtentScrollController(initialItem: tempMonth),
                      itemExtent: 32,
                      onSelectedItemChanged: (i) => tempMonth = i,
                      children: List.generate(
                        12,
                            (i) => Center(
                          child: Text(
                            '${(i + 1).toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 16),
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
              // 상단에 “YYYY. MM” 형태로 표시 (Pretendard 폰트 적용)
              Text(
                '${_selectedMonth.year}. ${_selectedMonth.month.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: 'Pretendard',
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
              // 1) 로딩 중이면 인디케이터 표시
                  ? const Center(child: CupertinoActivityIndicator())
              // 2) 로딩 완료 후 문서가 없으면 안내문 표시
                  : _diaryDocs.isEmpty
                  ? const Center(
                child: Text(
                  '작성된 일기가 없습니다',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Pretendard',
                  ),
                ),
              )
              // 3) 문서가 있으면 ListView.builder 로 나열
                  : ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _diaryDocs.length,
                itemBuilder: (_, idx) {
                  final doc = _diaryDocs[idx];

                  // (A) 문서 ID("01","02",...)를 정수로 변환 → dayNumber
                  final int dayNumber = int.parse(doc.id);
                  // (B) 선택된 연·월 + dayNumber로 DateTime 생성
                  final DateTime date = DateTime(
                    _selectedMonth.year,
                    _selectedMonth.month,
                    dayNumber,
                  );
                  const wd = ['일', '월', '화', '수', '목', '금', '토'];
                  final String w = wd[date.weekday % 7];

                  // (C) doc.data()로 Map<String,dynamic> 가져오기
                  final data = doc.data() as Map<String, dynamic>;

                  // (D) tags 필드가 있으면 List<String>으로, 없으면 빈 리스트
                  final List<String> tags = data.containsKey('tags')
                      ? List<String>.from(data['tags'])
                      : <String>[];

                  // (E) content 필드가 있으면 가져오고, 없으면 빈 문자열
                  final String content =
                  data.containsKey('content') ? data['content'] as String : '';

                  return GestureDetector(
                    onTap: () {
                      // 수정 페이지로 이동할 때, 연도/월/일을 넘겨 줌
                      final String yearStr =
                      _selectedMonth.year.toString();
                      final String monthStr = _selectedMonth.month
                          .toString()
                          .padLeft(2, '0');
                      final String dayId = doc.id;

                      Navigator.of(context)
                          .push(
                        CupertinoPageRoute(
                          builder: (_) => ModifyPage(
                            year: yearStr,
                            monthName: monthStr,
                            dayId: dayId,
                          ),
                        ),
                      )
                          .then((result) {
                        if (result == true) {
                          // 수정 후 돌아오면 데이터 새로고침
                          _loadData();
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // (1) 날짜 표시 (ex: 2025.05.01(금)), Google Fonts 'Roboto' 적용
                          Text(
                            '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}($w)',
                            style: GoogleFonts.getFont(
                              'Roboto',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // (2) 해시태그 목록 (없으면 빈 리스트라 아무것도 안 그려짐)
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: tags
                                .map(
                                  (t) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.brown, width: 1),
                                  borderRadius:
                                  BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '#$t',
                                  style: GoogleFonts.getFont(
                                    'Roboto',
                                    fontSize: 12,
                                    color: Colors.brown,
                                  ),
                                ),
                              ),
                            )
                                .toList(),
                          ),
                          const SizedBox(height: 6),

                          // (3) 내용 미리보기 (content 필드 값 혹은 빈 문자열)
                          Text(
                            content,
                            style: GoogleFonts.getFont(
                              'Roboto',
                              fontSize: 14,
                              height: 1.4,
                              color: Colors.black,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),

                          // (4) 구분선
                          const Divider(height: 1, thickness: 1),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // (5) 맨 아래 '일기쓰기' 버튼 (Google Fonts 'Roboto' 적용)
            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                height: 56,
                child: CupertinoButton(
                  color: const Color(0xFF603913),
                  borderRadius: BorderRadius.circular(8),
                  onPressed: () async {
                    await Navigator.of(context).push(
                      CupertinoPageRoute(builder: (_) => const WritePage()),
                    );
                    _loadData(); // 작성 후 돌아오면 리프레시
                  },
                  child: Text(
                    '일기쓰기',
                    style: GoogleFonts.getFont(
                      'Roboto',
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
