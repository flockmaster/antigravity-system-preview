import 'package:flutter/material.dart';

/// 应用颜色系统 (V4.0 Merged Version)
/// 结合了完整的架构定义与现代化调色板
class AppColors {
  AppColors._();

  // ==================== 1. 品牌色 (Brand) ====================
  
  /// 品牌主色 - 越野橙 (活力/操作/价格)
  /// 用于：主按钮、价格数字、强引导
  static const Color brandOrange = Color(0xFFFF6B00);
  
  /// 品牌辅助色 - 香槟金 (尊贵/VIP/选中态)
  /// [优化]：调整为更具金属质感的香槟金，原 E5C07B 略显焦黄
  static const Color brandGold = Color(0xFFD4B08C); 
  
  /// 品牌深色 - 深空黑 (标题/重视觉)
  static const Color brandBlack = Color(0xFF111827); // 比纯黑 111111 多了一点蓝灰倾向，更有质感
  
  /// 品牌深色别名 (用于标题等)
  static const Color brandDark = brandBlack;

  // ==================== 0. Tailwind Palette (Legacy Compatibility) ====================
  // --- Slate 色系 (系统基础色) ---
  static const Color slate50 = Color(0xFFF8FAFC);   // bg-slate-50
  static const Color slate100 = Color(0xFFF1F5F9);  // bg-slate-100
  static const Color slate200 = Color(0xFFE2E8F0);  // border-slate-200
  static const Color slate300 = Color(0xFFCBD5E1);  // text-slate-300
  static const Color slate400 = Color(0xFF94A3B8);  // text-slate-400
  static const Color slate500 = Color(0xFF64748B);  // text-slate-500
  static const Color slate600 = Color(0xFF475569);  // text-slate-600
  static const Color slate700 = Color(0xFF334155);  // text-slate-700
  static const Color slate800 = Color(0xFF1E293B);  // text-slate-800
  static const Color slate900 = Color(0xFF0F172A);  // text-slate-900 / dark-bg

  // --- Violet & Indigo (品牌主色) ---
  static const Color violet50 = Color(0xFFF5F3FF);
  static const Color violet100 = Color(0xFFEDE9FE);
  static const Color violet300 = Color(0xFFA78BFA); 
  static const Color violet400 = Color(0xFFA78BFA); 
  static const Color violet500 = Color(0xFF8B5CF6); // focus ring
  static const Color violet600 = Color(0xFF7C3AED); // 主紫色
  static const Color violet700 = Color(0xFF6D28D9);
  static const Color violet800 = Color(0xFF5B21B6);
  static const Color violet900 = Color(0xFF4C1D95);
  
  static const Color indigo50 = Color(0xFFEEF2FF);
  static const Color indigo100 = Color(0xFFE0E7FF);
  static const Color indigo300 = Color(0xFFA5B4FC);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5); // 主靛蓝
  
  // --- Orange & Amber (辅助警告色) ---
  static const Color orange50 = Color(0xFFFFF7ED);
  static const Color orange100 = Color(0xFFFFEDD5);
  static const Color orange200 = Color(0xFFFED7AA);
  static const Color orange300 = Color(0xFFFDBA74);
  static const Color orange400 = Color(0xFFFB923C);
  static const Color orange500 = Color(0xFFF97316); 
  static const Color orange600 = Color(0xFFEA580C);

  static const Color amber50 = Color(0xFFFFFBEB);
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber200 = Color(0xFFFDE68A);
  static const Color amber300 = Color(0xFFFCD34D);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber700 = Color(0xFFB45309);
  static const Color amber800 = Color(0xFF92400E);
  static const Color amber900 = Color(0xFF78350F);

  // --- Emerald & Green (成功/健康色) ---
  static const Color emerald50 = Color(0xFFECFDF5);
  static const Color emerald100 = Color(0xFFD1FAE5);
  static const Color emerald200 = Color(0xFFA7F3D0);
  static const Color emerald300 = Color(0xFF6EE7B7);
  static const Color emerald400 = Color(0xFF34D399); 
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald700 = Color(0xFF047857);
  static const Color emerald800 = Color(0xFF065F46);
  static const Color emerald900 = Color(0xFF064E3B);
  
  // Green aliases (Mapped to Emerald)
  static const Color green50 = emerald50;
  static const Color green100 = emerald100;
  static const Color green200 = emerald200;
  static const Color green300 = emerald300;
  static const Color green400 = emerald400;
  static const Color green500 = emerald500;
  static const Color green600 = emerald600;
  static const Color green700 = emerald700;
  static const Color green800 = emerald800;
  static const Color green900 = emerald900;

  // --- Red (危险/错误色) ---
  static const Color red50 = Color(0xFFFEF2F2);
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red300 = Color(0xFFFCA5A5);
  static const Color red400 = Color(0xFFF87171);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);

  // --- Rose & Pink (装饰色) ---
  static const Color pink500 = Color(0xFFEC4899);
  static const Color rose100 = Color(0xFFFFE4E6);
  static const Color rose400 = Color(0xFFFB7185);
  static const Color rose500 = Color(0xFFF43F5E);
  static const Color rose600 = Color(0xFFE11D48);

  // --- Blue (信息/常规) ---
  static const Color blue50 = Color(0xFFEFF6FF); // Added blue50
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB); // info-dark

  // --- Stone & Zinc (备用暗色) ---
  static const Color stone900 = Color(0xFF1C1917);
  
  // --- Legacy Semantic Aliases ---
  static const Color brandWhite = Colors.white;
  static const Color successBg = emerald100;
  static const Color surface50 = slate50;
  static const Color background = slate50;
  static const Color surface = Colors.white; // Added surface
  
  // ==================== 2. 状态交互色 (Interaction) [新增关键部分] ====================
  
  /// 选中态背景 - 极浅金色 (用于地址卡片、SKU选中的背景)
  static const Color bgSelected = Color(0xFFFAF5EF); 
  
  /// 选中态边框 - 金色 (用于地址卡片、SKU选中的边框)
  static const Color borderSelected = brandGold;

  // ==================== 3. 功能色 (Functional) ====================
  
  /// 成功色 - 翡翠绿
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  
  /// 警告色 - 琥珀黄
  static const Color warning = Color(0xFFF59E0B); // 调整为更稳重的琥珀色
  static const Color warningLight = Color(0xFFFEF3C7);
  
  /// 错误色 - 警示红
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  
  /// 信息色 - 科技蓝
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ==================== 4. 中性色 (Neutral / Text) ====================
  
  /// 文本色 - 标题 (几乎纯黑)
  static const Color textTitle = Color(0xFF111827);
  
  /// 文本色 - 主要正文
  static const Color textPrimary = Color(0xFF374151); // 稍微柔和一点的深灰
  
  /// 文本色 - 次要/辅助说明
  static const Color textSecondary = Color(0xFF4B5563); // 提升色深：6B7280 -> 4B5563
  
  /// 文本色 - 三级文本
  static const Color textTertiary = Color(0xFF6B7280); // 提升色深：9CA3AF -> 6B7280
  
  /// 文本色 - 占位符/失效
  static const Color textDisabled = Color(0xFFD1D5DB);
  
  /// 文本色 - 反色 (深色背景下的白字)
  static const Color textInverse = Color(0xFFFFFFFF);
  
  /// 文本色 - 价格专用 (强制橙色)
  static const Color textPrice = brandOrange;
  
  /// 文本色 - 高亮/VIP (强制金色)
  static const Color textHighlight = brandGold;

  // ==================== 5. 背景色 (Background) ====================
  
  /// 背景色 - L0 Canvas 画布底色 (冷灰，提升质感)
  static const Color bgCanvas = Color(0xFFF5F7FA);
  
  /// 背景色 - L1 Surface 容器/卡片 (纯白)
  static const Color bgSurface = Color(0xFFFFFFFF);
  
  /// 背景色 - L2 悬浮层/模态框
  static const Color bgElevated = Color(0xFFFFFFFF);
  
  /// 背景色 - 填色块 (用于搜索框背景、标签背景)
  static const Color bgFill = Color(0xFFF3F4F6);
  
  /// 背景色 - 遮罩 (50% 黑)
  static const Color bgOverlay = Color(0x80000000);

  // ==================== 6. 边框色 (Border) ====================
  
  /// 边框色 - 主要 (浅灰，用于卡片描边)
  static const Color borderPrimary = Color(0xFFE5E7EB);
  
  /// 边框色 - 强 (用于输入框激活)
  static const Color borderFocus = brandBlack;

  // ==================== 7. 分割线 (Divider) ====================
  
  static const Color divider = Color(0xFFEEEEEE); // 极淡

  // ==================== 8. 阴影系统 (Shadows) [优化透明度] ====================
  
  /// 阴影基础色 (用于BoxShadow)
  static const Color shadowBase = Color(0xFF000000);
  
  /// 阴影 - 极轻 (用于卡片默认态) - Opacity 4%
  static Color shadowLight = const Color(0xFF000000).withValues(alpha: 0.04);
  
  /// 阴影 - 浮起 (用于点击反馈) - Opacity 8%
  static Color shadowMedium = const Color(0xFF000000).withValues(alpha: 0.08);
  
  /// 阴影 - 高悬浮 (用于底部弹窗/FAB) - Opacity 12%
  static Color shadowHeavy = const Color(0xFF000000).withValues(alpha: 0.12);

  // ==================== 9. 常用颜色别名 (Aliases) ====================
  
  /// 常用颜色别名 - 方便快速使用
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  
  /// 背景色别名
  static const Color backgroundGray = bgCanvas;
  static const Color backgroundLight = bgFill;
  
  /// 边框色别名
  static const Color borderLight = borderPrimary;
  static const Color borderMedium = Color(0xFFD1D5DB);
  
  /// 危险色别名
  static const Color danger = error;
  static const Color dangerLight = errorLight;

  // ==================== 10. 第三方与渐变 ====================
  
  static const Color wechat = Color(0xFF07C160);
  static const Color alipay = Color(0xFF1677FF);

  /// 品牌渐变 - 更有质感的黑金渐变 (用于VIP卡片背景)
  static const LinearGradient vipGradient = LinearGradient(
    colors: [Color(0xFF374151), Color(0xFF111827)], // 深灰到黑
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// 按钮渐变 - 橙色活力
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF8800), brandOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// 颜色扩展工具
extension ColorExtension on Color {
  /// 兼容旧版 Opacity 写法，底层调用 withValues
  @override
  Color withOpacity(double opacity) {
    return withValues(alpha: opacity);
  }
  
  /// 获取更亮的颜色
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
  
  /// 获取更暗的颜色
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}
