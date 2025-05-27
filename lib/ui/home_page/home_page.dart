import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ① 현재 선택된 연·월을 저장할 변수
  late DateTime _selectedMonth;
  // ② 연도 피커 인덱스를 저장할 변수
  late int _yearPickerInitialIndex;
  // ③ 월 피커 인덱스를 저장할 변수
  late int _monthPickerInitialIndex;
  // ④ Firestore에서 가져온 테스트 데이터
  String testData = '로딩 중...';

  // ⑤ 선택 가능한 연도 리스트 (예: 2025년부터 2050년까지)
  final List<int> _yearList = List.generate(
    2050 - 2025 + 1,
        (index) => 2025 + index,
  );

  @override
  void initState() {
    super.initState();
    // Firestore 데이터 로드 호출
    _loadData();
    // 앱 실행 시 현재 연·월을 초기값으로 설정
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
    // 피커의 초기 인덱스를 계산
    _yearPickerInitialIndex = _yearList.indexOf(_selectedMonth.year);
    // 현재 연도가 리스트 범위 밖일 경우 기본으로 첫 인덱스를 사용
    if (_yearPickerInitialIndex == -1) {
      _yearPickerInitialIndex = 0;
      _selectedMonth = DateTime(_yearList.first, now.month);
    }
    _monthPickerInitialIndex = _selectedMonth.month - 1;
  }

  // Firestore에서 데이터를 가져오는 함수 (기존 코드 유지)
  Future<void> _loadData() async {
    try {
      final querySnapshot =
      await FirebaseFirestore.instance.collection('test').get();
      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
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

  // 월 선택 모달을 띄우는 메서드 (Cupertino 스타일)
  void _showMonthPicker() {
    // 현재 인덱스 복사
    int tempYearIndex = _yearPickerInitialIndex;
    int tempMonthIndex = _monthPickerInitialIndex;
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            // 상단 취소/완료 버튼 바
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
                      // 선택된 연·월 반영
                      setState(() {
                        _selectedMonth = DateTime(
                          _yearList[tempYearIndex],
                          tempMonthIndex + 1,
                        );
                        _yearPickerInitialIndex = tempYearIndex;
                        _monthPickerInitialIndex = tempMonthIndex;
                      });
                      // 필요 시 데이터 재호출
                      // _loadData();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            // 피커 영역 (연도/월)
            Expanded(
              child: Row(
                children: [
                  // 연도 피커
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: _yearPickerInitialIndex,
                      ),
                      itemExtent: 32,
                      onSelectedItemChanged: (i) {
                        tempYearIndex = i;
                      },
                      children: _yearList
                          .map((y) => Center(child: Text('$y')))
                          .toList(),
                    ),
                  ),
                  // 월 피커
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: _monthPickerInitialIndex,
                      ),
                      itemExtent: 32,
                      onSelectedItemChanged: (i) {
                        tempMonthIndex = i;
                      },
                      children: List.generate(
                        12,
                            (i) => Center(
                          child: Text(
                            '${(i + 1).toString().padLeft(2, '0')}',
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
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 4),
              const Icon(CupertinoIcons.chevron_down, size: 20),
            ],
          ),
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Text(testData),
        ),
      ),
    );
  }
}
