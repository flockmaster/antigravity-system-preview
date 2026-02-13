import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/models/word.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/baic_shake_widget.dart';
import 'recall_view_model.dart';

class RecallView extends StackedView<RecallViewModel> {
  final Word word;
  final VoidCallback onNext;
  final VoidCallback? onError;

  const RecallView({
    super.key,
    required this.word,
    required this.onNext,
    this.onError,
  });

  @override
  RecallViewModel viewModelBuilder(BuildContext context) =>
      RecallViewModel(word: word, onNext: onNext, onError: onError ?? () {});

  @override
  void onViewModelReady(RecallViewModel viewModel) => viewModel.init();

  @override
  Widget builder(
    BuildContext context,
    RecallViewModel viewModel,
    Widget? child,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 中文释义
                    Text(
                      word.meaningForDictation,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.slate900),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '/${word.phonetic}/',
                      style: const TextStyle(fontSize: 14, color: AppColors.slate400, fontFamily: 'RobotoMono'),
                    ),

                    const SizedBox(height: 16),

                    // 辅助按钮行：朗读 & 查看答案
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 朗读英文按钮
                        _buildHelpButton(
                          icon: LucideIcons.volume2,
                          label: '朗读',
                          onTap: viewModel.playAudio,
                          color: AppColors.violet500,
                        ),
                        const SizedBox(width: 16),
                        // 查看答案按钮
                        _buildHelpButton(
                          icon: LucideIcons.eye,
                          label: '答案',
                          onTap: viewModel.showCorrectAnswer,
                          color: AppColors.amber500,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

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
                      const SizedBox(height: 24),
                    ],

                    // 遮罩单词显示 (带高亮逻辑)
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 4,
                      children: List.generate(word.word.length, (index) {
                        final char = word.word[index];
                        final isMasked = viewModel.mask[index];
                        final isMatched = index < viewModel.matchLength;
                        
                        Color textColor;
                        String displayChar;
                        
                        if (isMatched) {
                          // 已匹配：显示字符，绿色
                          textColor = AppColors.emerald500;
                          displayChar = char;
                        } else if (isMasked) {
                          // 被遮蔽且未匹配：显示下划线，灰色
                          textColor = AppColors.slate300;
                          displayChar = '_';
                        } else {
                          // 未遮蔽且未匹配：显示原字符，黑色
                          textColor = AppColors.slate900;
                          displayChar = char;
                        }

                        return Text(
                          displayChar,
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                            letterSpacing: 4.0
                          ),
                        );
                      }),
                    ),
                    
                    const SizedBox(height: 48),

                    // 输入框
                    BaicShakeWidget(
                      isShake: viewModel.isShake,
                      child: TextField(
                        autofocus: true,
                        onChanged: viewModel.updateInput,
                        onSubmitted: (_) => viewModel.checkAnswer(),
                        textAlign: TextAlign.center,
                        autocorrect: false, // 关闭自动纠错以真实反映拼写
                        enableSuggestions: false,
                        keyboardType: TextInputType.text,
                        maxLines: 1,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.violet900),
                        decoration: InputDecoration(
                          hintText: '根据提示拼写完整单词',
                          hintStyle: const TextStyle(color: AppColors.slate300),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: viewModel.checkAnswer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.violet600,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('检查', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    
                    // 键盘适配间距
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 20 : 0),
                  ],
                ),
              ),
            ),
          ),
        );
      }
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
