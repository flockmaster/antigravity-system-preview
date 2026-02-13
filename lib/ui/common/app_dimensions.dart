/// AppDimensions - 系统化间距与圆角规范
/// 严格对应 React 原型中的间距与圆角定义
class AppDimensions {
  // --- 间距 (Spacing) ---
  static const double spaceXXS = 4.0;
  static const double spaceXS = 8.0;
  static const double spaceS = 12.0;    // 对应 gap-3
  static const double spaceM = 16.0;    // 对应 p-4 / gap-4
  static const double spaceL = 24.0;    // 对应 p-6 / gap-6
  static const double spaceXL = 32.0;   // 对应 p-8
  static const double spaceXXL = 40.0;  // 对应 p-10

  // --- 圆角 (Radius) ---
  static const double radiusS = 8.0;    // rounded-lg
  static const double radiusM = 12.0;   // rounded-xl
  static const double radiusL = 16.0;   // rounded-2xl
  static const double radiusXL = 24.0;  // rounded-3xl / PremiumCard
  static const double radiusXXL = 32.0; // rounded-[32px] / Hero Cards
  static const double radiusFull = 999.0;

  // --- 布局分界线 ---
  static const double maxContentWidth = 600.0;
  static const double headerHeight = 80.0;
  static const double bottomBarHeight = 85.0;
}
