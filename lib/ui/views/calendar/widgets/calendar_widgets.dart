import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/components/baic_ui_kit.dart';
import 'package:word_assistant/core/theme/app_colors.dart';
import '../../../common/app_typography.dart';
import '../calendar_view_model.dart';

/// 愿望清单奖励卡片
class RewardCard extends StatefulWidget {
  final Reward reward;
  final VoidCallback onTap;

  const RewardCard({
    super.key,
    required this.reward,
    required this.onTap,
  });

  @override
  State<RewardCard> createState() => _RewardCardState();
}

class _RewardCardState extends State<RewardCard> with SingleTickerProviderStateMixin {
  late AnimationController _pingController;

  @override
  void initState() {
    super.initState();
    _pingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaicBounceButton(
      onPressed: widget.onTap,
      child: Container(
        width: 144, // 对应原型 w-36
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.reward.claimed ? Colors.white : AppColors.slate100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.reward.claimed ? AppColors.orange200 : Colors.transparent,
            width: 2,
          ),
          boxShadow: widget.reward.claimed
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Content - Force Center
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: widget.reward.claimed
                          ? Color(int.parse(widget.reward.color))
                          : AppColors.slate300,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: widget.reward.claimed
                          ? [
                              BoxShadow(
                                color: Color(int.parse(widget.reward.color)).withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : null,
                    ),
                    child: Icon(
                      _getIcon(widget.reward.iconType, widget.reward.claimed),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${widget.reward.days} 天连胜',
                    style: AppTypography.tiny.copyWith(color: AppColors.slate600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.reward.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: widget.reward.claimed ? AppColors.slate900 : AppColors.slate400,
                      height: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Notification Dot
            if (widget.reward.claimed)
              Positioned(
                top: 0,
                right: 0,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ScaleTransition(
                      scale: Tween(begin: 1.0, end: 1.5).animate(
                        CurvedAnimation(parent: _pingController, curve: Curves.easeOut),
                      ),
                      child: FadeTransition(
                        opacity: Tween(begin: 1.0, end: 0.0).animate(
                          CurvedAnimation(parent: _pingController, curve: Curves.easeOut),
                        ),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String type, bool claimed) {
    if (!claimed) return LucideIcons.lock;
    switch (type) {
      case 'tv':
        return LucideIcons.tv;
      case 'gift':
        return LucideIcons.gift;
      case 'gamepad':
        return LucideIcons.gamepad2;
      case 'ferris-wheel':
        return LucideIcons.ferrisWheel;
      default:
        return LucideIcons.lock;
    }
  }
}

/// 连续坚持打卡火苗组件
class PulsingFlame extends StatefulWidget {
  const PulsingFlame({super.key});

  @override
  State<PulsingFlame> createState() => _PulsingFlameState();
}

class _PulsingFlameState extends State<PulsingFlame> with SingleTickerProviderStateMixin {
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 96, // 对应原型 w-24
          height: 96,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFDE047).withValues(alpha: 0.3 * _controller.value),
                blurRadius: 15 + (10 * _controller.value),
                spreadRadius: 2 * _controller.value,
              )
            ],
          ),
          child: Center(
            child: Transform.scale(
              scale: 1.0 + (0.1 * _controller.value),
              child: const Icon(
                LucideIcons.flame,
                size: 48,
                color: Color(0xFFFDE047), // yellow-300
              ),
            ),
          ),
        );
      },
    );
  }
}
