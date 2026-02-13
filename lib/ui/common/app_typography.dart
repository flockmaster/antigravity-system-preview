import 'package:flutter/material.dart';
import 'package:word_assistant/core/theme/app_colors.dart';

/// AppTypography - 统一字体样式规范
/// 对齐 React 原型中的字号、行高与粗细
class AppTypography {
  // --- 标题样式 ---
  
  /// 巨大标题 - 用于首页欢迎语 (对应 text-4xl / 36px-40px)
  static const TextStyle h1 = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w900,
    fontFamily: 'PingFang SC',
    letterSpacing: -1.5,
    color: AppColors.slate900,
    height: 1.1,
  );


  /// 大标题 - 用于弹窗标题 (对应 text-2xl / 24px)
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    fontFamily: 'PingFang SC',
    letterSpacing: -0.5,
    color: AppColors.slate900,
  );


  /// 普通标题 - 用于卡片标题 (对应 text-lg / 18px)
  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w900,
    fontFamily: 'PingFang SC',
    color: AppColors.slate900,
  );


  // --- 正文与副标题 ---

  /// 正文加粗 (对应 text-sm / 14px, bold)
  static const TextStyle bodySmallBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w900,
    color: AppColors.slate900,
  );

  /// 正文普通 (对应 text-sm / 14px)
  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.slate600,
    height: 1.5,
  );

  // --- 标签与备注 ---

  /// 备注文字 (对应 text-xs / 12px)
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.slate400,
  );

  /// 极小备注 (对应 text-[10px])
  static const TextStyle tiny = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.0,
    color: AppColors.slate400,
  );

  /// 品牌副标题 (带 Sparkles 的那个)
  static const TextStyle brandSubtitle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w900,
    letterSpacing: 2.5,
    color: AppColors.violet600,
  );
}
