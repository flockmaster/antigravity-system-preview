/// ============================================================================
/// 📄 View 模板文件
/// ============================================================================
///
/// 用途: 创建新 View 时的标准参考模板
/// 规则: 必须使用 ViewModelBuilder.reactive() 构建 (铁律 #1)
///
/// 使用方法:
/// 1. 复制此文件到目标目录
/// 2. 重命名文件和类名
/// 3. 确保对应的 ViewModel 已创建
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

// 核心导入 - 必须包含 (铁律 #1)
import '../lib/core/theme/app_colors.dart';
import '../lib/core/theme/app_dimensions.dart';
import '../lib/core/theme/app_typography.dart';
import '../lib/core/components/baic_ui_kit.dart';

// ViewModel 导入
import 'viewmodel_template.dart';

/// [ExampleView] - 示例页面视图
///
/// 职责: 仅负责 UI 渲染，不包含任何业务逻辑 (铁律 #1)
/// 所有数据和交互逻辑都在 [ExampleViewModel] 中处理
class ExampleView extends StatelessWidget {
  const ExampleView({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用 ViewModelBuilder.reactive() 构建，遵守铁律 #1
    return ViewModelBuilder<ExampleViewModel>.reactive(
      // ViewModel 工厂方法
      viewModelBuilder: () => ExampleViewModel(),

      // ViewModel 准备就绪后的回调
      onViewModelReady: (viewModel) => viewModel.initialise(),

      // UI 构建器
      builder: (context, viewModel, child) {
        return Scaffold(
          // 使用设计系统背景色，遵守铁律 #2
          backgroundColor: AppColors.bgCanvas,

          // AppBar (可选)
          appBar: _buildAppBar(viewModel),

          // 主体内容
          body: _buildBody(viewModel),
        );
      },
    );
  }

  /// 构建 AppBar
  PreferredSizeWidget _buildAppBar(ExampleViewModel viewModel) {
    return AppBar(
      backgroundColor: AppColors.bgSurface,
      elevation: 0,
      title: Text(
        viewModel.title,
        style: AppTypography.titleMedium.copyWith(color: AppColors.textTitle),
      ),
      centerTitle: true,
      leading: BaicBounceButton(
        onPressed: viewModel.handleBack,
        child: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
      ),
    );
  }

  /// 构建主体内容
  Widget _buildBody(ExampleViewModel viewModel) {
    // 加载状态 - 使用骨架屏，遵守铁律 (设计规范 8.1)
    if (viewModel.isBusy) {
      return _buildLoadingState();
    }

    // 错误状态
    if (viewModel.hasError) {
      return _buildErrorState(viewModel);
    }

    // 列表内容
    return _buildContent(viewModel);
  }

  /// 构建加载状态 (骨架屏)
  Widget _buildLoadingState() {
    return Padding(
      // 使用设计系统间距，遵守铁律 #2
      padding: EdgeInsets.all(AppDimensions.spaceM),
      child: Column(
        children: List.generate(
          5,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: AppDimensions.spaceS),
            child: BaicSkeleton(
              width: double.infinity,
              height: 80,
              radius: AppDimensions.radiusM,
            ),
          ),
        ),
      ),
    );
  }

  /// 构建错误状态
  Widget _buildErrorState(ExampleViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          SizedBox(height: AppDimensions.spaceM),
          Text(
            '加载失败',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textTitle,
            ),
          ),
          SizedBox(height: AppDimensions.spaceS),
          Text(
            viewModel.modelError?.toString() ?? '未知错误',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppDimensions.spaceL),
          // 使用 BaicBounceButton，遵守铁律 #2
          BaicBounceButton(
            onPressed: viewModel.refreshData,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.spaceL,
                vertical: AppDimensions.spaceS,
              ),
              decoration: BoxDecoration(
                color: AppColors.brandOrange,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: Text(
                '重试',
                style:
                    AppTypography.labelMedium.copyWith(color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建正常内容
  Widget _buildContent(ExampleViewModel viewModel) {
    return ListView.builder(
      padding: EdgeInsets.all(AppDimensions.spaceM),
      itemCount: viewModel.items.length,
      itemBuilder: (context, index) {
        final item = viewModel.items[index];
        final isSelected = viewModel.selectedIndex == index;

        // 使用 BaicBounceButton 包裹可点击区域，遵守铁律 #2
        return BaicBounceButton(
          onPressed: () => viewModel.selectItem(index),
          child: Container(
            margin: EdgeInsets.only(bottom: AppDimensions.spaceS),
            padding: EdgeInsets.all(AppDimensions.spaceM),
            decoration: BoxDecoration(
              // 使用设计系统颜色，遵守铁律 #2
              color: isSelected ? AppColors.bgSelected : AppColors.bgSurface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              border: Border.all(
                color:
                    isSelected ? AppColors.borderSelected : AppColors.borderPrimary,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                // 图标或头像
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.bgFill,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Icon(
                    Icons.article_outlined,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(width: AppDimensions.spaceM),
                // 文本内容
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item,
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.textTitle,
                        ),
                      ),
                      SizedBox(height: AppDimensions.spaceXS),
                      Text(
                        '这是一段描述文本',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // 箭头
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
