import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:word_assistant/core/theme/app_colors.dart';
import '../../../../core/components/baic_ui_kit.dart';

class HomeFeatureSlider extends StatelessWidget {
  final VoidCallback onScanTap;
  final VoidCallback onPasteTap;

  const HomeFeatureSlider({
    super.key,
    required this.onScanTap,
    required this.onPasteTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: PageView(
          clipBehavior: Clip.none,
          controller: PageController(viewportFraction: 0.87),
          padEnds: false, // Align left
          children: [
            // Card 1: Camera Scan
            Padding(
              padding: const EdgeInsets.only(right: 16.0), // gap-4
              child: _FeatureCard(
                title: '拍照提取',
                subtitle: '自动识别课本生词，生成复习列表。',
                tag: '智能识别',
                buttonText: '立即开始',
                color: AppColors.violet600,
                gradientColors: [AppColors.violet600, AppColors.violet600.withValues(alpha: 0.8)],
                icon: LucideIcons.camera,
                tagIcon: LucideIcons.sparkles,
                tagIconColor: Colors.yellowAccent,
                onTap: onScanTap,
                bgImage: 'assets/images/card_bg_scan.png',
              ),
            ),
            
            // Card 2: Paste Text
            Padding(
              padding: const EdgeInsets.only(right: 16.0), // gap-4
              child: _FeatureCard(
                title: '文本导入',
                subtitle: '复制粘贴微信群作业，一键整理。',
                tag: '快捷导入',
                buttonText: '去粘贴',
                color: AppColors.orange500,
                gradientColors: [AppColors.orange500, AppColors.orange500.withValues(alpha: 0.8)],
                icon: LucideIcons.clipboardPaste,
                isDotTag: true,
                onTap: onPasteTap,
                bgImage: 'assets/images/card_bg_paste.png',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String tag;
  final String buttonText;
  final Color color;
  final List<Color> gradientColors;
  final IconData icon;
  final IconData? tagIcon;
  final Color? tagIconColor;
  final bool isDotTag;
  final VoidCallback onTap;
  final String? bgImage;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.buttonText,
    required this.color,
    required this.gradientColors,
    required this.icon,
    this.tagIcon,
    this.tagIconColor,
    this.isDotTag = false,
    required this.onTap,
    this.bgImage,
  });

  @override
  Widget build(BuildContext context) {
    return BaicBounceButton(
      onPressed: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background Image (if exists)
            if (bgImage != null)
               Positioned.fill(
                child: Opacity(
                  opacity: 0.4,
                  child: Image.asset(bgImage!, fit: BoxFit.cover),
                ),
               ),

            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [...gradientColors, Colors.transparent],
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            if (tagIcon != null) ...[
                              Icon(tagIcon, size: 10, color: tagIconColor ?? Colors.white),
                              const SizedBox(width: 4),
                            ],
                            if (isDotTag) ...[
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF86EFAC), // green-300
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Icon Circle
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Icon(icon, color: Colors.white, size: 20),
                      ),
                    ],
                  ),

                  // Bottom Text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: color == AppColors.violet600 ? AppColors.violet100 : AppColors.orange100,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              buttonText,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: color == AppColors.violet600 ? AppColors.violet600 : AppColors.orange600,
                              ), // violet-700 / orange-700
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              LucideIcons.arrowRight,
                              size: 12,
                              color: color == AppColors.violet600 ? AppColors.violet600 : AppColors.orange600,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
