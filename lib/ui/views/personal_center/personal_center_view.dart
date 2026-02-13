import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:word_assistant/core/theme/app_colors.dart';
import 'personal_center_view_model.dart';
// Reuse for style consistency

class PersonalCenterView extends StackedView<PersonalCenterViewModel> {
  const PersonalCenterView({super.key});

  @override
  PersonalCenterViewModel viewModelBuilder(BuildContext context) =>
      PersonalCenterViewModel();

  @override
  void onViewModelReady(PersonalCenterViewModel viewModel) => viewModel.init();

  @override
  Widget builder(
    BuildContext context,
    PersonalCenterViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: CustomScrollView(
        slivers: [
          // 1. Sliver AppBar with Large Header
          SliverAppBar(
            backgroundColor: AppColors.slate50,
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            leading: IconButton(
              icon: const Icon(LucideIcons.chevronLeft, color: AppColors.slate900),
              onPressed: viewModel.navigateBack,
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              // title: Removed as per user request to avoid overlap
              background: _buildHeaderBackground(viewModel),
            ),
          ),

          // 2. Settings List
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '学习设置',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate400,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Data Statistics (NEW)
                  _buildSettingsItem(
                    icon: LucideIcons.barChart2,
                    title: '智学轨迹',
                    subtitle: '查看学习效率与成长趋势',
                    color: AppColors.green500,
                    bgColor: AppColors.green50,
                    onTap: viewModel.navigateToStatistics,
                  ),
                  
                  const SizedBox(height: 16),

                  // Email Report Settings (NEW)
                  _buildSettingsItem(
                    icon: LucideIcons.mail,
                    title: '学习报告',
                    subtitle: '自动发送邮件通知',
                    color: AppColors.indigo500,
                    bgColor: AppColors.indigo50,
                    onTap: viewModel.navigateToEmailSettings,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // TTS Settings
                  _buildSettingsItem(
                    icon: LucideIcons.volume2,
                    title: '语音设置',
                    subtitle: '调整发音语速和声音',
                    color: AppColors.violet500,
                    bgColor: AppColors.violet50,
                    onTap: viewModel.openTtsSettings,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Book Switcher
                  _buildSettingsItem(
                    icon: LucideIcons.book, // Changed icon
                    title: '切换词书',
                    subtitle: '当前: ${viewModel.currentBookLabel}',
                    color: AppColors.orange500,
                    bgColor: AppColors.orange50,
                    onTap: viewModel.showBookSwitcher,
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    '系统',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate400,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tutorial
                  _buildSettingsItem(
                    icon: LucideIcons.bookOpen,
                    title: '使用教程',
                    subtitle: '如何高效使用单词助手',
                    color: AppColors.blue500,
                    bgColor: AppColors.blue50,
                    onTap: () => viewModel.showComingSoon('使用教程'),
                  ),

                  const SizedBox(height: 16),

                  // About
                  _buildSettingsItem(
                    icon: LucideIcons.info,
                    title: '关于版本',
                    subtitle: 'v1.0.2 (Beta)',
                    color: AppColors.slate500,
                    bgColor: AppColors.slate100,
                    onTap: viewModel.navigateToAbout,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBackground(PersonalCenterViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar
          GestureDetector(
            onTap: viewModel.updateNickname, // Mock update
            child: Stack(
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.slate200.withValues(alpha: 0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(viewModel.avatarPath, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.violet500,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.pencil, size: 12, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Nickname
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                viewModel.nickname,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.slate900,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(LucideIcons.sparkles, size: 16, color: AppColors.amber500),
            ],
          ),
          const SizedBox(height: 8),
          // Points Display (Clickable Entry)
          GestureDetector(
            onTap: viewModel.navigateToFormattedShop, // Navigate to Calendar->Shop
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.amber100.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppColors.amber200, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.coins, size: 14, color: AppColors.amber600),
                      const SizedBox(width: 6),
                      Text(
                        '${viewModel.points}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.amber700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '积分',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.amber600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // "Exchange" Hint
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.amber500,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              '去兑换',
                              style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            Icon(LucideIcons.chevronRight, size: 10, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.slate100),
          boxShadow: [
            BoxShadow(
              color: AppColors.slate200.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.slate500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, size: 20, color: AppColors.slate300),
          ],
        ),
      ),
    );
  }
}
