import 'package:flutter/material.dart';

class GptTag extends StatelessWidget {
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
                  child: Text(emotion),
                ),
              ))
          .toList(),
    );
  }
}
