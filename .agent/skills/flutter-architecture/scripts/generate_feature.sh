#!/bin/bash
# ============================================================================
# Flutter Feature 骨架生成脚本
# ============================================================================
# 
# 用途: 一键生成符合架构规范的 Feature 模块骨架代码
# 用法: ./generate_feature.sh <feature_name> [category]
# 示例: ./generate_feature.sh user_profile user
#
# 生成结构:
# lib/ui/views/[category]/[feature_name]/
# ├── [feature_name]_view.dart
# ├── [feature_name]_viewmodel.dart
# └── widgets/
# ============================================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 参数检查
if [ -z "$1" ]; then
    echo -e "${RED}❌ 错误: 请提供功能名称${NC}"
    echo "用法: ./generate_feature.sh <feature_name> [category]"
    echo "示例: ./generate_feature.sh user_profile user"
    exit 1
fi

FEATURE_NAME="$1"
CATEGORY="${2:-general}"

# 转换为 PascalCase (如 user_profile -> UserProfile)
PASCAL_NAME=$(echo "$FEATURE_NAME" | sed -r 's/(^|_)([a-z])/\U\2/g')

# 目标路径
TARGET_DIR="lib/ui/views/${CATEGORY}/${FEATURE_NAME}"
WIDGETS_DIR="${TARGET_DIR}/widgets"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🚀 Flutter Feature 骨架生成器${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "功能名称: ${FEATURE_NAME}"
echo -e "类名前缀: ${PASCAL_NAME}"
echo -e "目标目录: ${TARGET_DIR}"
echo ""

# 检查目录是否已存在
if [ -d "$TARGET_DIR" ]; then
    echo -e "${YELLOW}⚠️ 目录已存在: ${TARGET_DIR}${NC}"
    read -p "是否覆盖? (y/N): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "操作已取消"
        exit 0
    fi
fi

# 创建目录结构
echo -e "${BLUE}[1/3] 创建目录结构...${NC}"
mkdir -p "$WIDGETS_DIR"
touch "${WIDGETS_DIR}/.gitkeep"

# 生成 ViewModel
echo -e "${BLUE}[2/3] 生成 ViewModel...${NC}"
cat > "${TARGET_DIR}/${FEATURE_NAME}_viewmodel.dart" << EOF
import '../../../../core/base/baic_base_view_model.dart';
import '../../../../app/app.locator.dart';
// import '../../../../app/app.router.dart'; // 待路由生成后启用

/// [${PASCAL_NAME}ViewModel] - ${PASCAL_NAME} 页面的业务逻辑层
/// 
/// 职责: [TODO: 说明此 ViewModel 负责的业务逻辑]
class ${PASCAL_NAME}ViewModel extends BaicBaseViewModel {
  
  // ============================================================================
  // 服务注入区
  // ============================================================================
  
  // final MyService _myService = locator<MyService>();
  
  // ============================================================================
  // 状态变量区
  // ============================================================================
  
  /// 页面标题
  String _title = '${PASCAL_NAME}';
  String get title => _title;
  
  /// 是否已初始化
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  
  // ============================================================================
  // 生命周期方法
  // ============================================================================
  
  /// 初始化方法 - 在 ViewModelBuilder.onViewModelReady 中调用
  Future<void> initialise() async {
    await runBusyFuture(_loadData());
    _isInitialized = true;
  }
  
  @override
  void dispose() {
    // 释放资源
    super.dispose();
  }
  
  // ============================================================================
  // 业务逻辑方法 (Public)
  // ============================================================================
  
  /// 刷新数据
  Future<void> refreshData() async {
    await runBusyFuture(_loadData(), busyObject: 'refresh');
  }
  
  /// 返回上一页
  void handleBack() {
    goBack();
  }
  
  // ============================================================================
  // 私有方法 (Private)
  // ============================================================================
  
  /// 加载数据
  Future<void> _loadData() async {
    // TODO: 实现数据加载逻辑
    await Future.delayed(const Duration(milliseconds: 500));
    rebuildUi();
  }
}
EOF

# 生成 View
echo -e "${BLUE}[3/3] 生成 View...${NC}"
cat > "${TARGET_DIR}/${FEATURE_NAME}_view.dart" << EOF
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/components/baic_ui_kit.dart';
import '${FEATURE_NAME}_viewmodel.dart';

/// [${PASCAL_NAME}View] - ${PASCAL_NAME} 页面
/// 
/// 功能描述: [TODO: 说明此页面的功能]
class ${PASCAL_NAME}View extends StatelessWidget {
  const ${PASCAL_NAME}View({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<${PASCAL_NAME}ViewModel>.reactive(
      viewModelBuilder: () => ${PASCAL_NAME}ViewModel(),
      onViewModelReady: (viewModel) => viewModel.initialise(),
      builder: (context, viewModel, child) {
        // 加载中显示骨架屏
        if (viewModel.isBusy) {
          return _buildSkeleton();
        }
        
        return Scaffold(
          backgroundColor: AppColors.bgCanvas,
          appBar: AppBar(
            title: Text(viewModel.title),
            backgroundColor: AppColors.bgSurface,
            leading: BaicBounceButton(
              onTap: viewModel.handleBack,
              child: const Icon(Icons.arrow_back_ios),
            ),
          ),
          body: SafeArea(
            child: _buildContent(viewModel),
          ),
        );
      },
    );
  }
  
  /// 构建骨架屏
  Widget _buildSkeleton() {
    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      body: Center(
        child: CircularProgressIndicator(
          color: AppColors.brandOrange,
        ),
      ),
    );
  }
  
  /// 构建主体内容
  Widget _buildContent(${PASCAL_NAME}ViewModel viewModel) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppDimensions.spaceM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TODO: 添加页面内容
          Text(
            '${PASCAL_NAME} 页面内容',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
EOF

# 完成提示
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Feature 骨架生成完成!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "生成的文件:"
echo -e "  📄 ${TARGET_DIR}/${FEATURE_NAME}_view.dart"
echo -e "  📄 ${TARGET_DIR}/${FEATURE_NAME}_viewmodel.dart"
echo -e "  📁 ${TARGET_DIR}/widgets/"
echo ""
echo -e "${YELLOW}📋 下一步:${NC}"
echo "  1. 在 lib/app/app.dart 中注册路由"
echo "  2. 运行 flutter pub run build_runner build --delete-conflicting-outputs"
echo "  3. 根据业务需求完善 ViewModel 和 View"
echo ""
