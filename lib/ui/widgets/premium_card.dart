import 'package:flutter/material.dart';
import 'package:word_assistant/core/theme/app_colors.dart';
import '../common/app_dimensions.dart';

/// 高级卡片组件 - 模仿原型的 PremiumCard
/// 
/// 提供玻璃拟态 (Glassmorphism) 效果，包含模糊、边框和柔和阴影。
class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final double? height;
  final double? width;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final double? borderRadius;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.height,
    this.width,
    this.border,
    this.boxShadow,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: height,
        width: width,
        padding: padding ?? const EdgeInsets.all(AppDimensions.spaceM),
        decoration: BoxDecoration(
          color: color ?? AppColors.brandWhite,
          borderRadius: BorderRadius.circular(borderRadius ?? 24), // 对应原型 rounded-[24px]
          border: border ?? Border.all(color: AppColors.brandWhite.withValues(alpha: 0.5)),
          boxShadow: boxShadow ?? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
