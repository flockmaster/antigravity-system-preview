import 'package:flutter/material.dart';

enum PetMood {
  happy,
  sad,
  neutral,
  surprised,
  sleeping
}

class PetMoodDisplay extends StatelessWidget {
  final PetMood mood;
  final double size;

  const PetMoodDisplay({
    super.key,
    this.mood = PetMood.neutral,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    // Placeholder for actual assets. 
    // In Phase 4B, we would replace these with Lottie or SVG assets.
    String textEmoji;
    Color bgColor;

    switch (mood) {
      case PetMood.happy:
        textEmoji = '🐶✨';
        bgColor = const Color(0xFFFFF7ED); // Orange 50
        break;
      case PetMood.sad:
        textEmoji = '🐶💧';
         bgColor = const Color(0xFFF1F5F9); // Slate 100
        break;
      case PetMood.surprised:
        textEmoji = '🐶⁉️';
        bgColor = const Color(0xFFFEF2F2); // Red 50
        break;
      case PetMood.sleeping:
        textEmoji = '🐶💤';
        bgColor = const Color(0xFFF0FDFA); // Teal 50
        break;
      case PetMood.neutral:
        textEmoji = '🐶';
        bgColor = Colors.white;
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
        border: Border.all(color: Colors.white, width: 4),
      ),
      child: Text(
        textEmoji,
        style: TextStyle(fontSize: size * 0.5),
      ),
    );
  }
}
