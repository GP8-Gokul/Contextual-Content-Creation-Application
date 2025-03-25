import 'package:flutter/material.dart';

class ContentCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData? icon;
  final Color lightPurple;

  const ContentCard({
    Key? key,
    required this.title,
    required this.content,
    this.icon,
    required this.lightPurple,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) Icon(icon, color: lightPurple, size: 22),
              if (icon != null) const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
