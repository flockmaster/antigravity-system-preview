import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../theme/app_dimensions.dart';

/// [BaicBounceButton]
/// 实现设计规范 8.3: Scale 0.98 + Haptic Feedback
class BaicBounceButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool enableHaptic;

  const BaicBounceButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.enableHaptic = true,
  });

  @override
  State<BaicBounceButton> createState() => _BaicBounceButtonState();
}

class _BaicBounceButtonState extends State<BaicBounceButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        if (widget.onPressed != null) {
          _controller.forward();
          if (widget.enableHaptic) HapticFeedback.selectionClick();
        }
      },
      onTapUp: (_) {
        if (widget.onPressed != null) {
          _controller.reverse();
          widget.onPressed!();
        }
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}

/// [BaicSkeleton]
/// 实现设计规范 8.1: 简单的骨架占位，替代转圈圈
class BaicSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const BaicSkeleton({
    super.key, 
    required this.width, 
    required this.height, 
    this.radius = AppDimensions.radiusS
  });

  @override
  Widget build(BuildContext context) {
    // 实际项目中可使用 shimmer 包，这里用灰色色块示意
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6), // 骨架屏专用灰
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}