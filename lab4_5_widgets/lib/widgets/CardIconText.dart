import 'package:flutter/material.dart';

class CardIconText extends StatelessWidget {
  const CardIconText({super.key, required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(children: [Icon(icon), SizedBox(width: 5), Text(text)]),
    );
  }
}
