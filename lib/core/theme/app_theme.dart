/// 应用主题系统 - 统一导出
/// 
/// 使用方式：
/// ```dart
/// import 'package:your_app/core/theme/app_theme.dart';
/// 
/// // 使用颜色
/// Container(color: AppColors.brandOrange);
/// 
/// // 使用尺寸
/// Container(
///   padding: AppDimensions.paddingL,
///   decoration: BoxDecoration(
///     borderRadius: AppDimensions.borderRadiusM,
///   ),
/// );
/// 
/// // 使用字体
/// Text('标题', style: AppTypography.headingL);
/// Text('¥999', style: AppTypography.priceMain);
/// ```

library app_theme;

export 'app_colors.dart';
export 'app_dimensions.dart';
export 'app_typography.dart';
export 'app_styles.dart';
