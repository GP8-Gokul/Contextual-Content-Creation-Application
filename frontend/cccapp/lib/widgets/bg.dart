import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key});

  static const Color backgroundStart = Color(0xFF1A1A1A);
  static const Color backgroundMid = Color(0xFF252525);
  static const Color backgroundEnd = Color(0xFF2D2D2D);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundStart,
            backgroundMid,
            backgroundEnd,
          ],
        ),
      ),
    );
  }
}
