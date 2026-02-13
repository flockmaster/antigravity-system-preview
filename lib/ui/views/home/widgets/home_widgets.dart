import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:word_assistant/core/theme/app_colors.dart';
import '../../../common/app_dimensions.dart';
import '../../../common/app_typography.dart';
import '../../../../core/components/baic_ui_kit.dart';

/// 首页顶部欢迎头部
class HomeHeader extends StatelessWidget {
  final String avatarUrl;

  const HomeHeader({
    super.key,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppDimensions.spaceL,
        right: AppDimensions.spaceL,
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SparkleSubtitle(),
              SizedBox(height: 8),
              Text(
                '你好，同学 👋',
                style: AppTypography.h1,
              ),
            ],
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.slate200,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: ClipOval(
              child: avatarUrl.startsWith('http')
                  ? Image.network(
                      avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(LucideIcons.user, color: AppColors.slate400),
                    )
                  : Image.asset(
                      avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(LucideIcons.user, color: AppColors.slate400),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SparkleSubtitle extends StatefulWidget {
  const _SparkleSubtitle();

  @override
  State<_SparkleSubtitle> createState() => _SparkleSubtitleState();
}

class _SparkleSubtitleState extends State<_SparkleSubtitle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.6, end: 1.0).animate(_controller),
      child: const Row(
        children: [
          Icon(LucideIcons.sparkles, size: 16, color: AppColors.violet600),
          SizedBox(width: 8),
          Text(
            'DICTATION PAL',
            style: AppTypography.brandSubtitle,
          ),
        ],
      ),
    );
  }
}

/// 首页大功能卡片 (拍照扫描/粘贴文本)
class HeroFeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String tag;
  final List<Color> glowGradient;
  final Color backgroundColor;
  final Color tagColor;
  final IconData icon;
  final VoidCallback onTap;
  final String? backgroundImage;

  const HeroFeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.glowGradient,
    required this.backgroundColor,
    required this.tagColor,
    required this.icon,
    required this.onTap,
    this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 卡片宽度 = 屏幕宽度 * 0.85 (留出左右边距和第二卡片露头空间)
    final cardWidth = screenWidth * 0.85;
    const cardHeight = 220.0;

    return SizedBox(
      width: cardWidth + 16, // 包含右边距
      height: cardHeight,
      child: BaicBounceButton(
        onPressed: onTap,
        child: Container(
          width: cardWidth,
          height: cardHeight, 
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
            // 外部发光效果 (收紧范围，避免被滚动容器裁切)
            boxShadow: [
              BoxShadow(
                color: glowGradient.first.withValues(alpha: 0.3),
                blurRadius: 15,
                spreadRadius: -5,
              ),
              BoxShadow(
                color: glowGradient.last.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: -3,
                offset: const Offset(8, 5),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          // 使用 Stack 添加装饰圆
          child: Stack(
            children: [
              // 1. Background Image (Lowest layer)
              if (backgroundImage != null)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.6, // Subtle background
                    child: Image.asset(
                      backgroundImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
              // 2. Gradient Overlay (to ensure text readability)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        backgroundColor.withValues(alpha: 0.8),
                        backgroundColor.withValues(alpha: 0.4),
                      ],
                    ),
                  ),
                ),
              ),
              // 装饰圆 1: 右上角 (原型: -top-10 -right-10 w-40 h-40 bg-indigo-500/30 blur-3xl)
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: glowGradient.first.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // 装饰圆 2: 右下角 (原型: bottom-0 right-0 w-32 h-32 bg-violet-500/20 blur-2xl)
              Positioned(
                bottom: -30,
                right: 20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: glowGradient.last.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // 内容
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标签
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Text(
                        tag,
                        style: AppTypography.tiny.copyWith(color: tagColor),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 标题
                    Text(
                      title,
                      style: AppTypography.h2.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    // 描述
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.5), 
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
                // 按钮
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 18, color: AppColors.slate900),
                      const SizedBox(width: 8),
                      Text(
                        title == '拍照扫描' ? '开始扫描' : '粘贴文本',
                        style: AppTypography.bodySmallBold.copyWith(color: AppColors.slate900),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }
}
