import 'package:flutter/material.dart';

/// 应用尺寸规范
/// 定义圆角、间距、尺寸等设计规范
class AppDimensions {
  AppDimensions._();

  // ==================== 圆角 (Border Radius) ====================
  // 基于 base_design_system.md 规范
  
  /// 圆角 - XS (极小) 4px
  /// 用于：极小标签、内嵌图
  static const double radiusXS = 4.0;
  static const BorderRadius borderRadiusXS = BorderRadius.all(Radius.circular(radiusXS));

  /// 圆角 - S (小) 8px
  /// 用于：标签、辅助输入框、小图标背景
  static const double radiusS = 8.0;
  static const BorderRadius borderRadiusS = BorderRadius.all(Radius.circular(radiusS));
  
  /// 圆角 - M (中) 12px - [标准] 硬朗风格
  /// 用于：功能卡片、列表项、模态窗口
  /// * 修改注：原16.0过于圆润，降级为12.0以增强硬朗感
  static const double radiusM = 12.0;
  static const BorderRadius borderRadiusM = BorderRadius.all(Radius.circular(radiusM));
  
  /// 圆角 - L (大) 16px
  /// 用于：页面级大图卡片(Hero Card)、沉浸式顶部区域、底部抽屉顶角
  static const double radiusL = 16.0;
  static const BorderRadius borderRadiusL = BorderRadius.all(Radius.circular(radiusL));
  
  /// 圆角 - Full (圆形)
  /// 用于：胶囊按钮、圆形功能按键
  static const double radiusFull = 999.0;
  static const BorderRadius borderRadiusFull = BorderRadius.all(Radius.circular(radiusFull));

  /// 圆角 - Beveled (切角) 10px
  /// 用于：特殊硬核卡片
  static const double radiusBeveled = 10.0;

  // ==================== 间距 (Spacing) ====================
  // 基于 base_design_system.md 规范，基数为 4px
  
  /// 间距 - 基数
  static const double spaceBase = 4.0;
  
  /// 间距 - S (小) 8px
  static const double spaceS = 8.0;
  
  /// 间距 - M (中) 16px
  static const double spaceM = 16.0;
  
  /// 间距 - ML (中大) 20px
  static const double spaceML = 20.0;
  
  /// 间距 - L (大) 24px
  static const double spaceL = 24.0;
  
  /// 间距 - XL (超大) 32px
  static const double spaceXL = 32.0;

  /// 间距 - XXL (极大) 48px
  static const double spaceXXL = 48.0;

  // ==================== 内边距 (Padding) ====================
  
  /// 内边距 - 小
  static const EdgeInsets paddingS = EdgeInsets.all(spaceS);
  
  /// 内边距 - 中
  static const EdgeInsets paddingM = EdgeInsets.all(spaceM);
  
  /// 内边距 - 大
  static const EdgeInsets paddingL = EdgeInsets.all(spaceL);
  
  /// 内边距 - 超大
  static const EdgeInsets paddingXL = EdgeInsets.all(spaceXL);
  
  /// 内边距 - 页面水平
  static const EdgeInsets paddingPageH = EdgeInsets.symmetric(horizontal: spaceM);
  
  /// 内边距 - 页面垂直
  static const EdgeInsets paddingPageV = EdgeInsets.symmetric(vertical: spaceM);
  
  /// 内边距 - 页面全部
  static const EdgeInsets paddingPage = EdgeInsets.all(spaceM);

  // ==================== 图标尺寸 (Icon Size) ====================
  
  /// 图标 - 超小
  static const double iconXS = 12.0;
  
  /// 图标 - 小
  static const double iconS = 16.0;
  
  /// 图标 - 中
  static const double iconM = 20.0;
  
  /// 图标 - 大
  static const double iconL = 24.0;
  
  /// 图标 - 超大
  static const double iconXL = 32.0;
  
  /// 图标 - 超超大
  static const double iconXXL = 48.0;

  // ==================== 按钮尺寸 (Button Size) ====================
  
  /// 按钮高度 - 小
  static const double buttonHeightS = 32.0;
  
  /// 按钮高度 - 中
  static const double buttonHeightM = 40.0;
  
  /// 按钮高度 - 大
  static const double buttonHeightL = 48.0;
  
  /// 按钮高度 - 超大
  static const double buttonHeightXL = 52.0;
  
  /// 按钮圆角 - 默认
  static const double buttonRadius = 24.0;
  static const BorderRadius buttonBorderRadius = BorderRadius.all(Radius.circular(buttonRadius));

  // ==================== 输入框尺寸 (Input Size) ====================
  
  /// 输入框高度 - 小
  static const double inputHeightS = 36.0;
  
  /// 输入框高度 - 中
  static const double inputHeightM = 44.0;
  
  /// 输入框高度 - 大
  static const double inputHeightL = 52.0;

  // ==================== 卡片尺寸 (Card Size) ====================
  
  /// 卡片内边距 - 小
  static const EdgeInsets cardPaddingS = EdgeInsets.all(12.0);
  
  /// 卡片内边距 - 中
  static const EdgeInsets cardPaddingM = EdgeInsets.all(16.0);
  
  /// 卡片内边距 - 大
  static const EdgeInsets cardPaddingL = EdgeInsets.all(20.0);
  
  /// 卡片外边距
  static const EdgeInsets cardMargin = EdgeInsets.symmetric(horizontal: spaceL);

  // ==================== 边框宽度 (Border Width) ====================
  
  /// 边框 - 细
  static const double borderWidthThin = 1.0;
  
  /// 边框 - 中
  static const double borderWidthMedium = 1.5;
  
  /// 边框 - 粗
  static const double borderWidthThick = 2.0;

  // ==================== 阴影 (Shadow) ====================
  // 基于 base_design_system.md 规范
  
  /// 阴影 - L1 (常规)
  /// 用于：列表项、静态卡片
  /// rgba(0,0,0,0.04), Blur: 14px, Offset: (0, 2)
  static List<BoxShadow> get shadowL1 => [
    BoxShadow(
      color: const Color(0x0A000000), // rgba(0,0,0,0.04)
      blurRadius: 14,
      offset: const Offset(0, 2),
    ),
  ];
  
  /// 阴影 - L2 (高悬浮)
  /// 用于：模态弹窗、选中态
  /// rgba(0,0,0,0.10), Blur: 30px, Offset: (0, 10)
  static List<BoxShadow> get shadowL2 => [
    BoxShadow(
      color: const Color(0x1A000000), // rgba(0,0,0,0.10)
      blurRadius: 30,
      offset: const Offset(0, 10),
    ),
  ];
  
  /// 阴影 - 按钮
  static List<BoxShadow> get shadowButton => [
    BoxShadow(
      color: const Color(0x33000000),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // ==================== 动画时长 (Duration) ====================
  
  /// 动画 - 快速
  static const Duration durationFast = Duration(milliseconds: 150);
  
  /// 动画 - 正常
  static const Duration durationNormal = Duration(milliseconds: 300);
  
  /// 动画 - 慢速
  static const Duration durationSlow = Duration(milliseconds: 500);

  // ==================== 其他尺寸 ====================
  
  /// 头像尺寸 - 小
  static const double avatarS = 32.0;
  
  /// 头像尺寸 - 中
  static const double avatarM = 48.0;
  
  /// 头像尺寸 - 大
  static const double avatarL = 64.0;
  
  /// 头像尺寸 - 超大
  static const double avatarXL = 96.0;
  
  /// 底部导航栏高度
  static const double bottomNavHeight = 56.0;
  
  /// 顶部导航栏高度
  static const double topNavHeight = 56.0;
  
  /// 列表项高度 - 小
  static const double listItemHeightS = 48.0;
  
  /// 列表项高度 - 中
  static const double listItemHeightM = 56.0;
  
  /// 列表项高度 - 大
  static const double listItemHeightL = 72.0;
}

/// 尺寸扩展方法
extension DimensionExtension on double {
  /// 转换为 SizedBox 高度
  SizedBox get verticalSpace => SizedBox(height: this);
  
  /// 转换为 SizedBox 宽度
  SizedBox get horizontalSpace => SizedBox(width: this);
  
  /// 转换为 EdgeInsets (全部)
  EdgeInsets get padding => EdgeInsets.all(this);
  
  /// 转换为 EdgeInsets (水平)
  EdgeInsets get paddingH => EdgeInsets.symmetric(horizontal: this);
  
  /// 转换为 EdgeInsets (垂直)
  EdgeInsets get paddingV => EdgeInsets.symmetric(vertical: this);
  
  /// 转换为 BorderRadius
  BorderRadius get radius => BorderRadius.circular(this);
}
