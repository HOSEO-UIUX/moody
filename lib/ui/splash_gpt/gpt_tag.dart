import 'package:flutter/material.dart';

class GptTag extends StatelessWidget {
  const GptTag({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.brown),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text('IMSI11'),
        ),
        SizedBox(width: 9),
        Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.brown),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text('IMSI22222222'),
        ),
      ],
    );
  }
}
