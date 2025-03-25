import 'package:flutter/material.dart';

class KeywordInputSection extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  // Enhanced custom colors
  static const Color primaryPurple = Color(0xFF9C27B0);
  static const Color darkPurple = Color(0xFF6A1B9A);
  static const Color lightPurple = Color(0xFFE1BEE7);
  static const Color backgroundStart = Color(0xFF1A1A1A);
  static const Color backgroundMid = Color(0xFF252525);
  static const Color accentColor = Color(0xFFAA00FF);

  const KeywordInputSection({
    Key? key,
    required this.controller,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: backgroundMid.withOpacity(0.3),
        border: Border.all(color: primaryPurple.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [darkPurple, primaryPurple],
                stops: const [0.3, 1.0],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Keywords',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enter keywords to search in your document',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type and press enter...',
                      hintStyle: TextStyle(
                        color: lightPurple.withOpacity(0.5),
                      ),
                      filled: true,
                      fillColor: backgroundStart.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: primaryPurple.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: accentColor,
                          width: 2,
                        ),
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: lightPurple,
                      ),
                    ),
                    onSubmitted: (_) => onSubmit(),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [darkPurple, accentColor],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: primaryPurple.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add_rounded),
                    onPressed: onSubmit,
                    color: Colors.white,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
