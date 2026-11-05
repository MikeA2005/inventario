import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String quantity;

  const MetricCard({
    super.key,
    required this.title,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14.0,
              color: Color.fromARGB(255, 1, 9, 19),
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            quantity,
            style: const TextStyle(
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172554),
            ),
          ),
        ],
      ),
    );
  }
}
