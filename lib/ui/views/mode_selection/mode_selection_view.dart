import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:word_assistant/core/theme/app_colors.dart';
import '../../common/app_dimensions.dart';
import '../../widgets/premium_card.dart';
import 'mode_selection_view_model.dart';
import '../../../core/models/dictation_session.dart';

class ModeSelectionView extends StackedView<ModeSelectionViewModel> {
  const ModeSelectionView({super.key});

  @override
  Widget builder(
    BuildContext context,
    ModeSelectionViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.slate900),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.spaceL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '选择模式',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.slate900,
                    letterSpacing: -1,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '今天想怎么练习？',
                  style: TextStyle(
                    color: AppColors.slate500,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // 输入方式切换
          _buildInputMethodToggle(viewModel),
          
          const SizedBox(height: 32),
          
          // 模式列表
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceL),
              children: [
                _buildModeCard(
                  id: DictationMode.modeA,
                  title: DictationMode.modeA.label,
                  subtitle: DictationMode.modeA.subtitle,
                  icon: LucideIcons.mic,
                  color: DictationMode.modeA.color,
                  iconColor: DictationMode.modeA.iconColor,
                  viewModel: viewModel,
                ),
                const SizedBox(height: 16),
                _buildModeCard(
                  id: DictationMode.modeB,
                  title: DictationMode.modeB.label,
                  subtitle: DictationMode.modeB.subtitle,
                  icon: LucideIcons.languages,
                  color: DictationMode.modeB.color,
                  iconColor: DictationMode.modeB.iconColor,
                  viewModel: viewModel,
                ),
                const SizedBox(height: 16),
                _buildModeCard(
                  id: DictationMode.modeC,
                  title: DictationMode.modeC.label,
                  subtitle: DictationMode.modeC.subtitle,
                  icon: LucideIcons.bookOpen,
                  color: DictationMode.modeC.color,
                  iconColor: DictationMode.modeC.iconColor,
                  viewModel: viewModel,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputMethodToggle(ModeSelectionViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceL),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.slate200.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            _buildToggleItem('纸笔', LucideIcons.pencil, viewModel.inputMethod == 'paper', () => viewModel.setInputMethod('paper')),
            _buildToggleItem('手机', LucideIcons.keyboard, viewModel.inputMethod == 'digital', () => viewModel.setInputMethod('digital')),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem(String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected ? [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? AppColors.slate900 : AppColors.slate400),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.slate900 : AppColors.slate400,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required DictationMode id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required ModeSelectionViewModel viewModel,
  }) {
    return PremiumCard(
      onTap: () => viewModel.selectMode(id),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.slate400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.slate50,
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.arrowRight, size: 16, color: AppColors.slate300),
          ),
        ],
      ),
    );
  }

  @override
  ModeSelectionViewModel viewModelBuilder(BuildContext context) => ModeSelectionViewModel();
}
