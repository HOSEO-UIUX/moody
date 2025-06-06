import 'package:flutter/material.dart';

/// 감정 태그를 표시하는 위젯
///
/// GPT API로부터 분석된 감정들을 해시태그 형태로 표시
/// 각 태그는 갈색 테두리와 텍스트로 구성
class GptTag extends StatelessWidget {
  /// 표시할 감정 태그 리스트
  final List<String> emotions;

  const GptTag({
    super.key,
    required this.emotions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: emotions
          .map((emotion) => Padding(
                padding: const EdgeInsets.only(right: 9),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.brown),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child:
                      Text('#$emotion', style: TextStyle(color: Colors.brown)),
                ),
              ))
          .toList(),
    );
  }
}
