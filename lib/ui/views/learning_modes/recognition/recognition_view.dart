import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/models/word.dart';
import 'package:word_assistant/core/theme/app_colors.dart';
import 'recognition_view_model.dart';

class RecognitionView extends StackedView<RecognitionViewModel> {
  final Word word;
  final VoidCallback onNext;
  final VoidCallback? onError;

  const RecognitionView({
    super.key,
    required this.word,
    required this.onNext,
    this.onError,
  });

  @override
  RecognitionViewModel viewModelBuilder(BuildContext context) =>
      RecognitionViewModel(word: word, onNext: onNext, onError: onError);

  @override
  void onViewModelReady(RecognitionViewModel viewModel) => viewModel.init();

  @override
  Widget builder(
    BuildContext context,
    RecognitionViewModel viewModel,
    Widget? child,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Sound Button (Big)
          GestureDetector(
            onTap: viewModel.playAudioManually,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppColors.slate200.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: const Icon(LucideIcons.volume2, size: 40, color: AppColors.violet500),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '听音选义',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.slate400),
          ),
          
          const Spacer(),

          // Options Grid/List
          ...viewModel.options.map((option) => _buildOption(option, viewModel)),

          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildOption(String option, RecognitionViewModel viewModel) {
    bool isSelected = viewModel.selectedOption == option;
    bool? isCorrect = viewModel.isCorrect;

    Color bgColor = Colors.white;
    Color borderColor = Colors.transparent;
    Color textColor = AppColors.slate700;

    if (isSelected) {
      if (isCorrect == true) {
        bgColor = AppColors.emerald500;
        textColor = Colors.white;
      } else if (isCorrect == false) {
        bgColor = AppColors.red500;
        textColor = Colors.white;
      }
    }

    return GestureDetector(
      onTap: () => viewModel.selectOption(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
             if (!isSelected)
               BoxShadow(color: AppColors.slate200.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Text(
          option,
          style: TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
