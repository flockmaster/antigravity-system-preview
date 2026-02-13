import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 应用字体排印系统
/// 遵循 base_design_system.md 规范
class AppTypography {
  AppTypography._();

  // ==================== 数据展示字体 (Oswald) ====================
  // 用于: 价格、车速、里程、积分、数字等数据展示
  
  /// 数据展示 - 超大号 (价格主显示)
  static TextStyle dataDisplayXL = GoogleFonts.oswald(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: -1.0,
  );

  /// 数据展示 - 大号 (重要数据)
  static TextStyle dataDisplayL = GoogleFonts.oswald(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: -0.5,
  );

  /// 数据展示 - 中号 (常规数据)
  static TextStyle dataDisplayM = GoogleFonts.oswald(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: -0.2,
  );

  /// 数据展示 - 小号 (辅助数据)
  static TextStyle dataDisplayS = GoogleFonts.oswald(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.0,
  );

  /// 数据展示 - 超小号 (标签数据)
  static TextStyle dataDisplayXS = GoogleFonts.oswald(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.0,
  );

  // ==================== 价格专用样式 ====================
  
  /// 价格 - 主价格 (橙色大号)
  static const TextStyle priceMain = TextStyle(
    fontFamily: 'Oswald',
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Color(0xFFFF6B00),
    height: 1.0,
  );

  /// 价格 - 货币符号
  static const TextStyle priceCurrency = TextStyle(
    fontFamily: 'Oswald',
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Color(0xFFFF6B00),
  );

  /// 价格 - 小号价格
  static const TextStyle priceSmall = TextStyle(
    fontFamily: 'Oswald',
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Color(0xFFFF6B00),
  );

  /// 价格 - 原价 (删除线)
  static const TextStyle priceOriginal = TextStyle(
    fontSize: 12,
    color: Color(0xFF9CA3AF),
    decoration: TextDecoration.lineThrough,
  );

  // ==================== 系统默认字体 (中文/普通文本) ====================
  
  /// 标题 - 大号
  static TextStyle headingL = const TextStyle(
    fontFamily: 'PingFang SC',
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: Color(0xFF111827),
  );

  /// 标题 - 大号 (反白)
  static TextStyle headingLInverse = const TextStyle(
    fontFamily: 'PingFang SC',
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: Colors.white,
  );

  /// 标题 - 中号
  static TextStyle headingM = const TextStyle(
    fontFamily: 'PingFang SC',
    fontSize: 18,
    fontWeight: FontWeight.w900,
    color: Color(0xFF111827),
  );

  /// 标题 - 中号 (反白)
  static TextStyle headingMInverse = const TextStyle(
    fontFamily: 'PingFang SC',
    fontSize: 18,
    fontWeight: FontWeight.w900,
    color: Colors.white,
  );

  /// 标题 - 小号
  static TextStyle headingS = const TextStyle(
    fontFamily: 'PingFang SC',
    fontSize: 16,
    fontWeight: FontWeight.w900,
    color: Color(0xFF111827),
  );

  /// 标题 - 小号 (反白)
  static TextStyle headingSInverse = const TextStyle(
    fontFamily: 'PingFang SC',
    fontSize: 16,
    fontWeight: FontWeight.w900,
    color: Colors.white,
  );

  /// 正文 - 主要
  static const TextStyle bodyPrimary = TextStyle(
    fontSize: 15,
    color: Color(0xFF1F2937),
    height: 1.5,
  );

  /// 正文 - 次要
  static const TextStyle bodySecondary = TextStyle(
    fontSize: 14,
    color: Color(0xFF6B7280),
    height: 1.5,
  );

  /// 说明文字 - 小号
  static const TextStyle captionPrimary = TextStyle(
    fontSize: 12,
    color: Color(0xFF6B7280),
    height: 1.4,
  );

  /// 说明文字 - 超小号
  static const TextStyle captionSecondary = TextStyle(
    fontSize: 11,
    color: Color(0xFF9CA3AF),
    height: 1.4,
  );

  /// 按钮文字
  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  /// 标签文字
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  // ==================== 辅助方法 ====================
  
  /// 创建数据展示样式（带颜色）
  static TextStyle dataDisplay({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.oswald(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height ?? 1.0,
      letterSpacing: letterSpacing ?? -0.5,
    );
  }

  /// 创建价格样式
  static TextStyle price({
    required double fontSize,
    Color color = const Color(0xFFFF6B00),
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return GoogleFonts.oswald(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: 1.0,
      letterSpacing: -0.5,
    );
  }
}

/// 快捷扩展方法
extension TextStyleExtension on TextStyle {
  /// 应用 Oswald 字体（用于数据展示）
  TextStyle get oswald => GoogleFonts.oswald(
    textStyle: this.copyWith(fontWeight: FontWeight.w700), // 强制数字/英文使用 700 字重
    letterSpacing: -0.5,
    height: 1.0,
  ).copyWith(
    fontFamilyFallback: ['PingFang SC', 'sans-serif'],
  );
  
  /// 应用品牌橙色
  TextStyle get brandOrange => copyWith(color: const Color(0xFFFF6B00));
  
  /// 应用品牌金色
  TextStyle get brandGold => copyWith(color: const Color(0xFFE5C07B));
  
  /// 应用主文本色
  TextStyle get textPrimary => copyWith(color: const Color(0xFF1F2937));
  
  /// 应用次要文本色
  TextStyle get textSecondary => copyWith(color: const Color(0xFF6B7280));
}
