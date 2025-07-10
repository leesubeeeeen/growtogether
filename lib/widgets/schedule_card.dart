import 'package:flutter/material.dart';

class ScheduleCard extends StatelessWidget {
  final String title;
  final String time;
  final String content;
  final String place;
  final String person;
  final Color backgroundColor;
  final IconData icon;

  const ScheduleCard({
    super.key,
    required this.title,
    required this.time,
    required this.content,
    required this.place,
    required this.person,
    required this.backgroundColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              const Icon(Icons.more_vert, size: 18),
            ],
          ),
          const SizedBox(height: 4),
          Text(content),
          const SizedBox(height: 6),
          Text('📍 $place'),
          Text('👨‍👩‍👧 $person'),
        ],
      ),
    );
  }
}