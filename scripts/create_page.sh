#!/bin/bash

# ============================================================================
# 🚀 页面脚手架生成脚本
# 用途: 一键生成 View + ViewModel + 目录结构
# 使用: ./scripts/create_page.sh <page_name> [category]
# 示例: ./scripts/create_page.sh user_profile user
#       ./scripts/create_page.sh product_detail store
# ============================================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# 引入配置 (如果存在)
if [ -f "$SCRIPT_DIR/config.sh" ]; then
    source "$SCRIPT_DIR/config.sh"
fi

# 获取项目名称 (从 pubspec.yaml 读取)
PROJECT_NAME=$(grep "^name:" "$PROJECT_ROOT/pubspec.yaml" 2>/dev/null | awk '{print $2}' || echo "flutter_template")

# 转换命名格式函数
to_pascal_case() {
    echo "$1" | awk -F'_' '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1' OFS=''
}

# ============================================================================
# 参数验证
# ============================================================================
if [ -z "$1" ]; then
    echo -e "${RED}[错误]${NC} 请提供页面名称"
    echo ""
    echo "用法: $0 <page_name> [category]"
    echo "示例: $0 user_profile user"
    echo "      $0 product_detail"
    exit 1
fi

PAGE_NAME="$1"
CATEGORY="${2:-}"  # 可选的分类目录

# 验证命名规范
if [[ ! "$PAGE_NAME" =~ ^[a-z0-9_]+$ ]]; then
    echo -e "${RED}[错误]${NC} 页面名称必须使用 snake_case (小写字母、数字、下划线)"
    exit 1
fi

PAGE_NAME_PASCAL=$(to_pascal_case "$PAGE_NAME")

echo ""
echo "=============================================="
echo "   🚀 页面脚手架生成器"
echo "=============================================="
echo ""
echo -e "页面名称:    ${GREEN}${PAGE_NAME}${NC}"
echo -e "类名:        ${GREEN}${PAGE_NAME_PASCAL}View${NC} / ${GREEN}${PAGE_NAME_PASCAL}ViewModel${NC}"
if [ -n "$CATEGORY" ]; then
    echo -e "分类目录:    ${GREEN}${CATEGORY}${NC}"
fi
echo ""

# ============================================================================
# 创建目录结构
# ============================================================================
if [ -n "$CATEGORY" ]; then
    TARGET_DIR="$PROJECT_ROOT/lib/ui/views/$CATEGORY/$PAGE_NAME"
else
    TARGET_DIR="$PROJECT_ROOT/lib/ui/views/$PAGE_NAME"
fi

echo -e "${BLUE}[步骤]${NC} 创建目录结构..."

mkdir -p "$TARGET_DIR/widgets"
echo -e "${GREEN}[成功]${NC} 创建目录: $TARGET_DIR"

# ============================================================================
# 生成 ViewModel 文件
# ============================================================================
VIEWMODEL_FILE="$TARGET_DIR/${PAGE_NAME}_viewmodel.dart"

echo -e "${BLUE}[步骤]${NC} 生成 ViewModel..."

cat > "$VIEWMODEL_FILE" << EOF
import 'package:$PROJECT_NAME/core/base/baic_base_view_model.dart';
// import 'package:$PROJECT_NAME/app/app.locator.dart';
// import 'package:$PROJECT_NAME/app/app.router.dart';

/// ${PAGE_NAME_PASCAL}ViewModel - [请填写功能描述]
///
/// 职责:
/// - [描述此 ViewModel 负责的业务逻辑]
/// - [描述数据加载逻辑]
/// - [描述用户交互处理]
class ${PAGE_NAME_PASCAL}ViewModel extends BaicBaseViewModel {
  // ============================================================================
  // 状态变量
  // ============================================================================

  /// 页面加载状态
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ============================================================================
  // 初始化方法
  // ============================================================================

  /// 初始化方法 - 在 View 构建时调用
  /// 
  /// 触发场景: View 的 onViewModelReady 回调
  /// 核心逻辑: 加载初始数据
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: 实现数据加载逻辑
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      // TODO: 错误处理
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================================
  // 业务方法
  // ============================================================================

  // TODO: 添加业务方法

  // ============================================================================
  // 导航方法
  // ============================================================================

  /// 返回上一页
  void goBack() {
    navigationService.back();
  }
}
EOF

echo -e "${GREEN}[成功]${NC} 创建 ViewModel: $VIEWMODEL_FILE"

# ============================================================================
# 生成 View 文件
# ============================================================================
VIEW_FILE="$TARGET_DIR/${PAGE_NAME}_view.dart"

echo -e "${BLUE}[步骤]${NC} 生成 View..."

cat > "$VIEW_FILE" << EOF
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:$PROJECT_NAME/core/theme/app_colors.dart';
import 'package:$PROJECT_NAME/core/theme/app_dimensions.dart';
// import 'package:$PROJECT_NAME/core/components/baic_ui_kit.dart';
import '${PAGE_NAME}_viewmodel.dart';

/// ${PAGE_NAME_PASCAL}View - [请填写功能描述]
///
/// 页面说明:
/// - [描述此页面的主要功能]
/// - [描述页面布局结构]
class ${PAGE_NAME_PASCAL}View extends StatelessWidget {
  const ${PAGE_NAME_PASCAL}View({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<${PAGE_NAME_PASCAL}ViewModel>.reactive(
      viewModelBuilder: () => ${PAGE_NAME_PASCAL}ViewModel(),
      onViewModelReady: (viewModel) => viewModel.init(),
      builder: (context, viewModel, child) {
        // 加载状态 - 显示骨架屏
        if (viewModel.isLoading) {
          return _buildSkeletonView();
        }

        return Scaffold(
          backgroundColor: AppColors.bgPrimary,
          appBar: AppBar(
            title: const Text('$PAGE_NAME_PASCAL'),
            backgroundColor: AppColors.bgPrimary,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppDimensions.spaceM),
              child: _buildContent(viewModel),
            ),
          ),
        );
      },
    );
  }

  /// 构建主内容区域
  Widget _buildContent(${PAGE_NAME_PASCAL}ViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TODO: 实现页面内容
        Text(
          '$PAGE_NAME_PASCAL 页面',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppDimensions.spaceM),
        Text(
          '请根据原型实现具体内容',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// 骨架屏视图 - 数据加载时显示
  Widget _buildSkeletonView() {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('加载中...'),
        backgroundColor: AppColors.bgPrimary,
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
EOF

echo -e "${GREEN}[成功]${NC} 创建 View: $VIEW_FILE"

# ============================================================================
# 生成 widgets/.gitkeep
# ============================================================================
touch "$TARGET_DIR/widgets/.gitkeep"

# ============================================================================
# 提示注册路由
# ============================================================================
echo ""
echo "=============================================="
echo -e "   ${GREEN}🎉 页面脚手架生成完成！${NC}"
echo "=============================================="
echo ""
echo "📁 生成的文件:"
echo "   - $VIEW_FILE"
echo "   - $VIEWMODEL_FILE"
echo "   - $TARGET_DIR/widgets/ (组件目录)"
echo ""
echo -e "${YELLOW}⚠️  下一步操作:${NC}"
echo ""
echo "1. 在 lib/app/app.dart 中注册路由:"
echo ""
echo -e "   ${BLUE}MaterialRoute(page: ${PAGE_NAME_PASCAL}View),${NC}"
echo ""
echo "2. 添加 import 语句:"
if [ -n "$CATEGORY" ]; then
    echo -e "   ${BLUE}import '../ui/views/$CATEGORY/$PAGE_NAME/${PAGE_NAME}_view.dart';${NC}"
else
    echo -e "   ${BLUE}import '../ui/views/$PAGE_NAME/${PAGE_NAME}_view.dart';${NC}"
fi
echo ""
echo "3. 运行代码生成:"
echo -e "   ${BLUE}flutter pub run build_runner build --delete-conflicting-outputs${NC}"
echo ""
