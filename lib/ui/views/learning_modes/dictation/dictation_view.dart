import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/models/word.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/baic_shake_widget.dart';
import 'dictation_view_model.dart';

class DictationView extends StackedView<DictationViewModel> {
  final Word word;
  final VoidCallback onNext;
  final Function(String) onError;

  const DictationView({
    super.key,
    required this.word,
    required this.onNext,
    required this.onError,
  });

  @override
  DictationViewModel viewModelBuilder(BuildContext context) =>
      DictationViewModel(word: word, onNext: onNext, onError: onError);

  @override
  void onViewModelReady(DictationViewModel viewModel) => viewModel.init();

  @override
  Widget builder(
    BuildContext context,
    DictationViewModel viewModel,
    Widget? child,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 48, // 减去 padding
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'BOSS BATTLE',
                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2, color: AppColors.violet500),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '听写挑战',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.slate900),
                  ),
                  
                  const SizedBox(height: 32),

                  // 音频播放按钮（居中大按钮）
                  GestureDetector(
                    onTap: viewModel.playAudio,
                    child: Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.violet500,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: AppColors.violet500.withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: const Icon(LucideIcons.headphones, size: 40, color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    '点击播放读音',
                    style: TextStyle(color: AppColors.slate400),
                  ),

                  const SizedBox(height: 16),

                  // 查看答案按钮
                  _buildHelpButton(
                    icon: LucideIcons.eye,
                    label: '实在不会？查看答案',
                    onTap: viewModel.showCorrectAnswer,
                    color: AppColors.amber500,
                  ),

                  const SizedBox(height: 16),

                  // 显示正确答案（如果用户点击了查看）
                  if (viewModel.showAnswer) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.amber100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.amber300),
                      ),
                      child: Text(
                        word.word,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.amber700,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 输入框
                  BaicShakeWidget(
                    isShake: viewModel.isShake,
                    child: TextField(
                      autofocus: true,
                      onChanged: viewModel.updateInput,
                      onSubmitted: (_) => viewModel.checkAnswer(),
                      textAlign: TextAlign.center,
                      autocorrect: true,
                      enableSuggestions: true,
                      keyboardType: TextInputType.text,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.slate900),
                      decoration: InputDecoration(
                        hintText: '输入你听到的单词...',
                        hintStyle: const TextStyle(color: AppColors.slate300, fontSize: 16),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      ),
                    ),
                  ),

                  if (viewModel.showHint) ...[
                    const SizedBox(height: 12),
                    Text(
                      '提示：它的意思是 "${word.meaningForDictation}"',
                      style: const TextStyle(color: AppColors.amber500, fontWeight: FontWeight.bold),
                    ),
                  ],

                  const Spacer(),
                  const SizedBox(height: 24),

                  // 提交按钮
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: viewModel.checkAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.slate900,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text('提交', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 构建辅助按钮
  Widget _buildHelpButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
