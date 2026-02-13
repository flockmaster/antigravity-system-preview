import 'package:flutter/material.dart';
import 'package:word_assistant/core/theme/app_colors.dart';

/// 呼吸球组件 - 模仿原型的 BreathingOrb
/// 
/// 用于在听写过程中提供视觉反馈，表示正在播报语音。
class BreathingOrb extends StatefulWidget {
  final bool isActive;
  final Color color; // New Color Param
  
  const BreathingOrb({
    super.key, 
    required this.isActive,
    this.color = AppColors.violet600, // Default fallback
  });

  @override
  State<BreathingOrb> createState() => _BreathingOrbState();
}

class _BreathingOrbState extends State<BreathingOrb> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(BreathingOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 放射波纹
        if (widget.isActive)
          ...List.generate(2, (index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  width: 120 + (index * 40 * _controller.value),
                  height: 120 + (index * 40 * _controller.value),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.color.withValues(alpha: 0.3 * (1 - _controller.value)),
                      width: 2,
                    ),
                  ),
                );
              },
            );
          }),
        
        // 核心球体
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color, // Simple color fill or Gradient from param? For simplicity use simple fill or generate gradient
              gradient: LinearGradient(
                colors: [widget.color.withValues(alpha: 0.8), widget.color],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: widget.isActive ? 0.5 : 0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.mic,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
      ],
    );
  }
}
