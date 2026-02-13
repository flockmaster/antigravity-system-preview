import 'package:flutter/material.dart';
import 'dart:ui'; // 用于 FontFeature
import 'app_colors.dart';

class AppStyles {
  // ===========================================================================
  // 1. 投影系统 (Shadow) - 极致的微光质感
  // ===========================================================================
  
  /// L1: 基础卡片阴影 (极淡，用于列表卡片)
  /// Opacity 0.04, Blur 14
  static final List<BoxShadow> shadowCard = [
    BoxShadow(
      color: AppColors.shadowBase.withOpacity(0.04),
      offset: const Offset(0, 4),
      blurRadius: 14,
      spreadRadius: 0,
    ),
  ];

  /// L2: 悬浮阴影 (用于 FAB、弹窗、正在拖拽的物体)
  /// Opacity 0.10, Blur 30
  static final List<BoxShadow> shadowFloat = [
    BoxShadow(
      color: AppColors.shadowBase.withOpacity(0.10),
      offset: const Offset(0, 10),
      blurRadius: 30,
      spreadRadius: 0,
    ),
  ];

  // ===========================================================================
  // 2. 字体排印 (Typography)
  // ===========================================================================
  
  // 字体栈：优先西文 Oswald/Roboto，后备中文苹方/黑体
  static const String _fontMechanical = 'Oswald'; 
  static const List<String> _fontFamilyFallback = ['PingFang SC', 'Heiti SC', 'Microsoft YaHei', 'sans-serif'];

  /// [机械感数字] - 用于仪表盘、里程、剩余电量
  /// 特性：等宽数字 (Tabular Figures)，防止数字变化时抖动
  static const TextStyle mechanicalData = TextStyle(
    fontFamily: _fontMechanical,
    fontFamilyFallback: _fontFamilyFallback,
    fontFeatures: [FontFeature.tabularFigures()], 
    fontSize: 28, 
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.1, // 紧凑行高
    letterSpacing: 0.0,
  );

  /// [价格展示] - 专门优化 ¥ 符号和数字的比例
  static TextStyle price(double fontSize, {Color color = AppColors.textPrice}) {
    return TextStyle(
      fontFamily: _fontMechanical,
      fontFamilyFallback: _fontFamilyFallback,
      fontSize: fontSize,
      fontWeight: FontWeight.bold, // 价格一定要粗
      color: color,
      height: 1.0,
      letterSpacing: -0.5, // 数字稍微挤一点，更有冲击力
    );
  }

  // --- 标准文本 ---

  static const TextStyle h1 = TextStyle(
    fontSize: 24, 
    fontWeight: FontWeight.bold, 
    color: AppColors.brandDark, 
    height: 1.4,
    fontFamilyFallback: _fontFamilyFallback,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 18, 
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.textPrimary, 
    height: 1.4,
    fontFamilyFallback: _fontFamilyFallback,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 16, 
    fontWeight: FontWeight.w500, // Medium
    color: AppColors.textPrimary, 
    height: 1.5,
    fontFamilyFallback: _fontFamilyFallback,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 14, 
    fontWeight: FontWeight.normal, 
    color: AppColors.textSecondary, 
    height: 1.5,
    fontFamilyFallback: _fontFamilyFallback,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12, 
    fontWeight: FontWeight.normal, 
    color: AppColors.textTertiary, 
    height: 1.4,
    fontFamilyFallback: _fontFamilyFallback,
  );
}