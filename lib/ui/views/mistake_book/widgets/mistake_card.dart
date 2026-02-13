import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/models/word.dart';
import 'package:word_assistant/core/theme/app_colors.dart';

class MistakeCard extends StatelessWidget {
  final Word word;
  final bool isSelected;
  final VoidCallback onTap;
  final Function(String) onPlayAudio;

  const MistakeCard({
    super.key,
    required this.word,
    required this.isSelected,
    required this.onTap,
    required this.onPlayAudio,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.violet600 : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.violet600.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Word & Checkbox
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            word.word,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: AppColors.slate900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildAudioButton(context, word.word),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        word.phonetic,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'SF Mono',
                          color: AppColors.slate400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Checkbox
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.violet600 : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.violet600 : AppColors.slate200,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(LucideIcons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Middle: Meaning
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.slate100.withValues(alpha: 0.5)),
              ),
              child: Text(
                word.meaningForDictation, // Or meaningFull if available
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate600,
                ),
              ),
            ),

            const SizedBox(height: 12),
            const Divider(color: AppColors.slate50, thickness: 1),
            const SizedBox(height: 12),

            // Bottom: Sentence
            if (word.sentence.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildSentenceAudioButton(context, word.sentence),
                   const SizedBox(width: 8),
                   Expanded(
                     child: Text(
                       word.sentence,
                       style: const TextStyle(
                         fontSize: 14,
                         color: AppColors.slate500,
                         fontStyle: FontStyle.italic,
                         height: 1.4,
                         fontWeight: FontWeight.w500,
                       ),
                     ),
                   )
                ],
              )
          ],
        ),
      ),
    );
  }

  Widget _buildAudioButton(BuildContext context, String text) {
    return GestureDetector(
      onTap: () => onPlayAudio(text),
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: AppColors.slate50,
          shape: BoxShape.circle,
        ),
        child: const Icon(LucideIcons.volume2, size: 16, color: AppColors.slate400),
      ),
    );
  }

  Widget _buildSentenceAudioButton(BuildContext context, String text) {
     return GestureDetector(
      onTap: () => onPlayAudio(text),
      child: Container(
        padding: const EdgeInsets.all(4),
        child: const Icon(LucideIcons.volume2, size: 14, color: AppColors.slate300),
      ),
    );
  }
}
