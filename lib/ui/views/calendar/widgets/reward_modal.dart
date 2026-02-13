import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../calendar_view_model.dart';
import 'package:word_assistant/core/theme/app_colors.dart';
import '../../../common/app_typography.dart';
import '../../../../core/components/baic_ui_kit.dart';

class RewardModal extends StatelessWidget {
  final Reward reward;
  final VoidCallback onClose;

  const RewardModal({
    super.key,
    required this.reward,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 背景遮罩
          GestureDetector(
            onTap: onClose,
            child: Container(
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
          // 弹窗主体
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 顶部彩色区域
                  Container(
                    height: 128,
                    width: double.infinity,
                    color: reward.claimed ? Color(int.parse(reward.color)) : AppColors.slate200,
                    child: Stack(
                      children: [
                        if (reward.claimed)
                          Opacity(
                            opacity: 0.15,
                            child: CustomPaint(
                              painter: PatternPainter(),
                              size: Size.infinite,
                            ),
                          ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: GestureDetector(
                            onTap: onClose,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(LucideIcons.x, size: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 内容区域
                  Transform.translate(
                    offset: const Offset(0, -48),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        children: [
                          // 大图标
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: reward.claimed ? Colors.white : AppColors.slate100,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                reward.claimed ? _getIcon(reward.iconType) : LucideIcons.lock,
                                size: 32,
                                color: reward.claimed ? AppColors.slate900 : AppColors.slate400,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // 标签
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: reward.claimed ? const Color(0xFFD1FAE5) : AppColors.slate100,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              reward.claimed ? '已解锁兑换券' : '再坚持一下',
                              style: AppTypography.tiny.copyWith(
                                color: reward.claimed ? const Color(0xFF047857) : AppColors.slate500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // 标题
                          Text(
                            reward.title,
                            style: AppTypography.h2.copyWith(
                              color: reward.claimed ? AppColors.slate900 : AppColors.slate400,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // 描述
                          Text(
                            reward.claimed ? reward.desc : '需要连续打卡 ${reward.days} 天才能解锁哦！',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall.copyWith(
                              color: reward.claimed ? AppColors.slate500 : AppColors.slate400,
                            ),
                          ),
                          const SizedBox(height: 32),
                          // 底部交互
                          if (reward.claimed)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.slate50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.slate200, width: 2, style: BorderStyle.none), // Simplified transition
                              ),
                              child: const Column(
                                children: [
                                  Text(
                                    '给家长看',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.slate400,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(LucideIcons.ticket, size: 18, color: AppColors.slate900),
                                      SizedBox(width: 8),
                                      Text(
                                        '凭此券兑换',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.slate900),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          else
                            BaicBounceButton(
                              onPressed: onClose,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.slate100,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                  child: Text(
                                    '我知道了',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.slate400),
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String type) {
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

class PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    
    double step = 16;
    for (double i = 0; i < size.width; i += step) {
      for (double j = 0; j < size.height; j += step) {
        canvas.drawCircle(Offset(i, j), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
