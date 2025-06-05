import 'package:flutter/material.dart';

class CardIconText extends StatelessWidget {
  const CardIconText({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
  });
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, top: 6, right: 10, bottom: 6),
        child: Row(children: [Icon(icon, size: 16), Text(text)]),
      ),
    );
  }
}
