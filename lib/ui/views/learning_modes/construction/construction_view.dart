import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/models/word.dart';
import 'package:word_assistant/core/theme/app_colors.dart';
import 'construction_view_model.dart';

class ConstructionView extends StackedView<ConstructionViewModel> {
  final Word word;
  final VoidCallback onNext;
  final Function(String) onError;

  const ConstructionView({
    super.key,
    required this.word,
    required this.onNext,
    required this.onError,
  });

  @override
  ConstructionViewModel viewModelBuilder(BuildContext context) =>
      ConstructionViewModel(word: word, onNext: onNext, onError: onError);

  @override
  void onViewModelReady(ConstructionViewModel viewModel) => viewModel.init();

  @override
  Widget builder(
    BuildContext context,
    ConstructionViewModel viewModel,
    Widget? child,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
      child: Column(
        children: [
          const SizedBox(height: 24),
          
          // 中文释义
          Text(
            word.meaningForDictation,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.slate900),
            textAlign: TextAlign.center,
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

          const SizedBox(height: 24),

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
          
          // 槽位区域
          Wrap(
            spacing: 8,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: List.generate(viewModel.slots.length, (index) {
              final tile = viewModel.slots[index];
              return GestureDetector(
                onTap: () => viewModel.onTapSlotTile(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48, height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tile != null 
                        ? (viewModel.isSuccess ? AppColors.emerald500 : AppColors.violet500)
                        : AppColors.slate200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: tile != null ? Colors.transparent : AppColors.slate300,
                      width: 2,
                    ),
                    boxShadow: tile != null 
                       ? [BoxShadow(color: AppColors.violet500.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))] 
                       : [],
                  ),
                  child: Text(
                    tile?.char ?? '',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              );
            }),
          ),
          
          const Spacer(),
          
          // 池区域
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: viewModel.pool.map((tile) {
              return GestureDetector(
                onTap: () => viewModel.onTapPoolTile(tile),
                child: Container(
                  width: 56, height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.slate200, width: 2),
                    boxShadow: [
                      BoxShadow(color: AppColors.slate200.withValues(alpha: 0.5), blurRadius: 4, offset: const Offset(0, 4))
                    ]
                  ),
                  child: Text(
                    tile.char,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.slate800),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 48),
        ],
      ),
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
