import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/models/word.dart';
import 'package:word_assistant/core/theme/app_colors.dart';
import 'read_aloud_view_model.dart';

/// View for the Read Aloud stage (第2.5关：大声朗读)
class ReadAloudView extends StackedView<ReadAloudViewModel> {
  final Word word;
  final VoidCallback onNext;
  final Function([String?]) onError;

  const ReadAloudView({
    super.key,
    required this.word,
    required this.onNext,
    required this.onError,
  });

  @override
  ReadAloudViewModel viewModelBuilder(BuildContext context) =>
      ReadAloudViewModel(word: word, onNext: onNext, onError: onError);

  @override
  void onViewModelReady(ReadAloudViewModel viewModel) => viewModel.init();

  @override
  Widget builder(
    BuildContext context,
    ReadAloudViewModel viewModel,
    Widget? child,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          const Spacer(),

          // 单词展示
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: AppColors.slate200.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Column(
              children: [
                // 标签
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.amber50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.amber200),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.megaphone, size: 14, color: AppColors.amber600),
                      SizedBox(width: 6),
                      Text('READ ALOUD', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.amber600, letterSpacing: 0.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 单词
                Text(
                  word.word,
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: AppColors.slate900,
                    letterSpacing: -1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // 音标 + 播放按钮
                GestureDetector(
                  onTap: viewModel.speakWord,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.slate100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.volume2, size: 16, color: AppColors.slate500),
                        const SizedBox(width: 8),
                        Text(
                          word.phonetic,
                          style: const TextStyle(fontSize: 14, color: AppColors.slate500),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 中文释义
                Text(
                  word.meaningForDictation,
                  style: const TextStyle(fontSize: 18, color: AppColors.slate600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 状态反馈区
          if (viewModel.isMatched)
            _buildSuccessFeedback()
          else if (viewModel.showRetryHint)
            _buildRetryHint()
          else if (viewModel.recognizedText.isNotEmpty)
            Text(
              'You said: "${viewModel.recognizedText}"',
              style: const TextStyle(fontSize: 14, color: AppColors.slate500, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            )
          else if (viewModel.attempts > 0) // Explicit feedback for empty result after attempt
             const Text(
              '没听清，请大声读出来～',
              style: TextStyle(fontSize: 14, color: AppColors.orange500, fontWeight: FontWeight.bold),
            )
          else
            const Text(
              '请大声朗读这个单词！',
              style: TextStyle(fontSize: 16, color: AppColors.slate400),
            ),

          const Spacer(),

          // 麦克风按钮
          if (!viewModel.isMatched)
            Listener(
              onPointerDown: (_) => viewModel.startListening(),
              onPointerUp: (_) => viewModel.stopListening(),
              onPointerCancel: (_) => viewModel.stopListening(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: viewModel.isListening ? AppColors.red500 : AppColors.amber500,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (viewModel.isListening ? AppColors.red500 : AppColors.amber500).withValues(alpha: 0.4),
                      blurRadius: viewModel.isListening ? 24 : 12,
                      spreadRadius: viewModel.isListening ? 6 : 2,
                    )
                  ],
                ),
                child: Icon(
                  LucideIcons.mic,
                  color: Colors.white,
                  size: viewModel.isListening ? 40 : 36,
                ),
              ),
            ),
          
          const SizedBox(height: 16),

          Text(
            viewModel.isMatched
                ? 'Perfect! 🎉'
                : (viewModel.isListening ? 'Listening...' : 'Hold to Speak'),
            style: TextStyle(
              fontSize: 14,
              color: viewModel.isMatched ? AppColors.green600 : AppColors.slate400,
              fontWeight: viewModel.isMatched ? FontWeight.bold : FontWeight.normal,
            ),
          ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildSuccessFeedback() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.green100,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.checkCircle, color: AppColors.green600, size: 20),
          SizedBox(width: 8),
          Text('Excellent!', style: TextStyle(color: AppColors.green700, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildRetryHint() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.amber100,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.refreshCw, color: AppColors.amber600, size: 18),
          SizedBox(width: 8),
          Text('再听一遍，跟我读～', style: TextStyle(color: AppColors.amber700, fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}
