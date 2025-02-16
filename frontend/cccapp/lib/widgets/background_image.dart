// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class BackgroundImage extends StatelessWidget {
  final String imageName;
  const BackgroundImage({
    super.key,
    required this.imageName,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Image.asset(
        'assets/images/$imageName.jpg',
        fit: BoxFit.cover,
      ),
    );
  }
}
