import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moody/ui/write_page/write_page.dart';



class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime _selectedMonth;
  late int _yearPickerInitialIndex;
  late int _monthPickerInitialIndex;
  String testData = '로딩 중...';

  final List<int> _yearList = List.generate(
    2050 - 2025 + 1,
        (index) => 2025 + index,
  );

  @override
  void initState() {
    super.initState();
    _loadData();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
    _yearPickerInitialIndex = _yearList.indexOf(_selectedMonth.year);
    if (_yearPickerInitialIndex == -1) {
      _yearPickerInitialIndex = 0;
      _selectedMonth = DateTime(_yearList.first, now.month);
    }
    _monthPickerInitialIndex = _selectedMonth.month - 1;
  }

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

  void _showMonthPicker() {
    int tempYearIndex = _yearPickerInitialIndex;
    int tempMonthIndex = _monthPickerInitialIndex;
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
                          _yearList[tempYearIndex],
                          tempMonthIndex + 1,
                        );
                        _yearPickerInitialIndex = tempYearIndex;
                        _monthPickerInitialIndex = tempMonthIndex;
                      });
                      Navigator.of(context).pop();
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
                          child: Text('${(i + 1).toString().padLeft(2, '0')}'),
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
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text(testData),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CupertinoButton.filled(
                onPressed: () async {
                  await Navigator.of(context).push(
                    CupertinoPageRoute(builder: (_) => WritePage()),
                  );
                  _loadData();
                },
                child: const Text('일기쓰기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}