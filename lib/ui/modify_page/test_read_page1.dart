import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moody/ui/write_page/write_page.dart';
import 'package:moody/ui/modify_page/modify_page.dart';

class HomePage_Test extends StatefulWidget {
  const HomePage_Test({Key? key}) : super(key: key);

  @override
  State<HomePage_Test> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage_Test> {
  late DateTime _selectedMonth;
  late int _yearPickerInitialIndex;
  late int _monthPickerInitialIndex;

  final List<int> _yearList = List.generate(2050 - 2025 + 1, (index) => 2025 + index);
  final String monthName = '05';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
    _yearPickerInitialIndex = _yearList.indexOf(_selectedMonth.year);
    if (_yearPickerInitialIndex == -1) {
      _yearPickerInitialIndex = 0;
      _selectedMonth = DateTime(_yearList.first, now.month);
    }
    _monthPickerInitialIndex = _selectedMonth.month - 1;
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
                      scrollController: FixedExtentScrollController(initialItem: _yearPickerInitialIndex),
                      itemExtent: 32,
                      onSelectedItemChanged: (i) => tempYearIndex = i,
                      children: _yearList.map((y) => Center(child: Text('$y'))).toList(),
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(initialItem: _monthPickerInitialIndex),
                      itemExtent: 32,
                      onSelectedItemChanged: (i) => tempMonthIndex = i,
                      children: List.generate(12, (i) => Center(child: Text('${(i + 1).toString().padLeft(2, '0')}'))),
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

  Widget _buildDiaryList() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('date')
          .doc('year')
          .collection('${_selectedMonth.year}')
          .doc('month')
          .collection('${_selectedMonth.month.toString().padLeft(2, '0')}')
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CupertinoActivityIndicator());

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text('해당 월의 일기가 없습니다.'));

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final dayId = doc.id;
            final content = doc['content'] ?? '';

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => ModifyPage(
                      year: '${_selectedMonth.year}',
                      monthName: monthName,
                      dayId: dayId,
                    ),
                  ),
                ).then((result) {
                  if (result == true) {
                    setState(() {}); // 수정 결과 반영 (일기 리스트 새로고침)
                  }
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.brown),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_selectedMonth.year}. ${_selectedMonth.month.toString().padLeft(2, '0')}. $dayId',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(content.length > 100 ? '${content.substring(0, 100)}...' : content),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground,
        border: const Border(bottom: BorderSide(color: Colors.blue, width: 2)),
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
            Expanded(child: _buildDiaryList()),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      CupertinoPageRoute(builder: (_) => WritePage()),
                    );
                    if (result == true) {
                      setState(() {});
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    '일기쓰기',
                    style: TextStyle(color: Colors.white),
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
