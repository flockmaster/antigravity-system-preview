import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:word_assistant/core/theme/app_colors.dart';
import 'smart_review_ring_painter.dart';

class SmartReviewDashboard extends StatelessWidget {
  final int needingMasteryCount;
  final int atRiskCount;
  final int stableCount;
  final bool isReviewComplete;

  const SmartReviewDashboard({
    super.key,
    required this.needingMasteryCount,
    required this.atRiskCount,
    required this.stableCount,
    required this.isReviewComplete,
  });

  @override
  Widget build(BuildContext context) {
    Color primaryColor;
    Color bgColor;
    String title;
    String subtitle;
    IconData icon;
    
    final totalCount = needingMasteryCount + atRiskCount + stableCount;
    final urgentCount = needingMasteryCount + atRiskCount;
    
    // Status Logic
    if (isReviewComplete) {
      primaryColor = AppColors.success; // Green
      bgColor = const Color(0xFFECFDF5);
      title = '记忆满格';
      subtitle = '今日防线固若金汤';
      icon = LucideIcons.shieldCheck;
    } else if (urgentCount > 5) {
      primaryColor = AppColors.error; // Red
      bgColor = const Color(0xFFFEF2F2);
      title = '记忆防线告急';
      subtitle = '预计耗时 ${((urgentCount * 1.5).ceil())} 分钟';
      icon = LucideIcons.alertTriangle;
    } else {
      primaryColor = const Color(0xFFF97316); // Orange
      bgColor = const Color(0xFFFFF7ED);
      title = '定期维护时间';
      subtitle = '预计耗时 ${((urgentCount * 1.5).ceil())} 分钟';
      icon = LucideIcons.timer;
    }

    // Progress Calculation (Inverse logic: more urgent items = lower "health" progress)
    // If complete, 1.0. If many urgent, low progress.
    double progress = 1.0;
    if (!isReviewComplete && totalCount > 0) {
      // Calculate "Health": (Total - Urgent) / Total
      progress = (totalCount - urgentCount) / totalCount;
      if (progress < 0.1) progress = 0.1; // Min visual progress
    }

    return Column(
      children: [
        // 1. Huge Ring Dashboard
        Stack(
          alignment: Alignment.center,
          children: [
             // The Ring
             CustomPaint(
               size: const Size(260, 260),
               painter: SmartReviewRingPainter(
                 progress: progress,
                 gradientColors: [
                   primaryColor.withValues(alpha: 0.5),
                   primaryColor,
                 ],
                 backgroundColor: primaryColor.withValues(alpha: 0.1),
                 strokeWidth: 24,
               ),
             ),
             
             // Inner Content
             Column(
               mainAxisSize: MainAxisSize.min,
               children: [
                 Container(
                   padding: const EdgeInsets.all(16),
                   decoration: BoxDecoration(
                     color: bgColor,
                     shape: BoxShape.circle,
                     boxShadow: [
                       BoxShadow(
                         color: primaryColor.withValues(alpha: 0.2),
                         blurRadius: 16,
                         spreadRadius: 4,
                       )
                     ]
                   ),
                   child: Icon(icon, color: primaryColor, size: 48),
                 ),
                 const SizedBox(height: 16),
                 Text(
                   urgentCount > 0 ? '$urgentCount' : 'OK',
                   style: const TextStyle(
                     fontSize: 48, 
                     fontWeight: FontWeight.w900, 
                     color: AppColors.slate900,
                     letterSpacing: -2
                   ),
                 ),
                 Text(
                   urgentCount > 0 ? '待复习' : '状态极佳',
                   style: const TextStyle(
                     fontSize: 14, 
                     fontWeight: FontWeight.bold, 
                     color: AppColors.slate400
                   ),
                 ),
               ],
             ),
          ],
        ),
        
        const SizedBox(height: 32),
        
        // 2. Title & Subtitle
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.slate900),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 16, color: AppColors.slate500, fontWeight: FontWeight.w500),
        ),
        
        const SizedBox(height: 32),
        
        // 3. Stats Row
        if (!isReviewComplete)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
               _buildStatItem('需攻坚', needingMasteryCount, AppColors.error),
               Container(width: 1, height: 24, color: AppColors.slate200),
               _buildStatItem('临界点', atRiskCount, const Color(0xFFF97316)),
               Container(width: 1, height: 24, color: AppColors.slate200),
               _buildStatItem('可巩固', stableCount, AppColors.success),
            ],
          ),
      ],
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          '$value', 
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)
        ),
        Text(
          label, 
          style: const TextStyle(fontSize: 12, color: AppColors.slate400, fontWeight: FontWeight.bold)
        ),
      ],
    );
  }
}
