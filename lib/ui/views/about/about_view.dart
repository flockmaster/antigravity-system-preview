import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:word_assistant/core/theme/app_colors.dart';
import 'about_view_model.dart';
import '../../widgets/premium_card.dart';

class AboutView extends StackedView<AboutViewModel> {
  const AboutView({super.key});

  @override
  AboutViewModel viewModelBuilder(BuildContext context) => AboutViewModel();

  @override
  Widget builder(
    BuildContext context,
    AboutViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        title: const Text('关于版本', style: TextStyle(color: AppColors.slate900, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.slate900),
          onPressed: viewModel.navigateBack,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Logo & Version
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.violet500.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(LucideIcons.bookOpen, size: 48, color: AppColors.violet500),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '单词助手',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.slate900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.slate200,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text(
                      'Beta v1.0.2',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 60),

            // Options List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildOptionTile(
                    icon: LucideIcons.fileText,
                    title: '隐私政策',
                    onTap: () => viewModel.showComingSoon('隐私政策'),
                  ),
                  const SizedBox(height: 16),
                  _buildOptionTile(
                    icon: LucideIcons.shieldCheck,
                    title: '服务条款',
                    onTap: () => viewModel.showComingSoon('服务条款'),
                  ),
                  const SizedBox(height: 16),
                  _buildOptionTile(
                    icon: LucideIcons.checkSquare,
                    title: '检查更新',
                    onTap: () => viewModel.showComingSoon('检查更新'),
                  ),
                  const SizedBox(height: 32),
                  
                  // Export Button
                  PremiumCard(
                    onTap: viewModel.exportData,
                    padding: const EdgeInsets.all(20),
                    borderRadius: 20,
                    color: AppColors.violet50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (viewModel.isBusy)
                          const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.violet600)
                          )
                        else
                          const Icon(LucideIcons.uploadCloud, color: AppColors.violet600, size: 20),
                        
                        const SizedBox(width: 12),
                        const Text(
                          '导出学习数据备份',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.violet700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Copyright
            const Text(
              'Copyright © 2024 DictationPal',
              style: TextStyle(color: AppColors.slate400, fontSize: 12),
            ),
            const SizedBox(height: 8),
            const Text(
              'All Rights Reserved',
              style: TextStyle(color: AppColors.slate400, fontSize: 12),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.slate100),
          boxShadow: [
            BoxShadow(
              color: AppColors.slate200.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.slate500),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate700,
                ),
              ),
            ),
            const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.slate300),
          ],
        ),
      ),
    );
  }
}
