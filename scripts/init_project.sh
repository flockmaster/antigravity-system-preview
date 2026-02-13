#!/bin/bash

# ============================================================================
# 🚀 Flutter 项目模版初始化脚本
# 用途: 一键初始化项目，创建必要文件和依赖
# 功能: 自动重命名项目、替换包名、创建结构
# 使用: chmod +x scripts/init_project.sh && ./scripts/init_project.sh
# ============================================================================

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_step() {
    echo -e "${BLUE}[步骤]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[成功]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[警告]${NC} $1"
}

print_error() {
    echo -e "${RED}[错误]${NC} $1"
}

# 转换下划线命名到大驼峰 (flutter_template -> FlutterTemplate)
to_pascal_case() {
    echo "$1" | awk -F'_' '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1' OFS=''
}

echo ""
echo "=============================================="
echo "   🚀 Flutter 项目模版初始化脚本"
echo "=============================================="
echo ""

# ============================================================================
# Step 0: 获取项目名称
# ============================================================================
PROJECT_NAME=""
DEFAULT_NAME="flutter_template"

# 检查是否传入参数
if [ -n "$1" ]; then
    PROJECT_NAME="$1"
else
    # 交互式输入
    echo -e "${YELLOW}请输入您的项目名称 (snake_case，例如: my_cool_app)${NC}"
    read -p "项目名称 [$DEFAULT_NAME]: " INPUT_NAME
    PROJECT_NAME="${INPUT_NAME:-$DEFAULT_NAME}"
fi

# 验证命名规范 (仅允许小写字母、数字和下划线)
if [[ ! "$PROJECT_NAME" =~ ^[a-z0-9_]+$ ]]; then
    print_error "项目名称不合法！仅允许小写字母、数字和下划线 (snake_case)。"
    exit 1
fi

PROJECT_NAME_PASCAL=$(to_pascal_case "$PROJECT_NAME")

echo ""
echo -e "正在将项目初始化为: ${GREEN}${PROJECT_NAME}${NC} (Class: ${GREEN}${PROJECT_NAME_PASCAL}App${NC})"
echo ""

# ============================================================================
# Step 1: 创建 pubspec.yaml 并替换名称
# ============================================================================
print_step "配置 pubspec.yaml..."

if [ -f "pubspec.yaml" ]; then
    print_warning "pubspec.yaml 已存在，仅执行内容替换"
else
    if [ -f "pubspec.yaml.example" ]; then
        cp pubspec.yaml.example pubspec.yaml
        print_success "已从 pubspec.yaml.example 创建 pubspec.yaml"
    else
        print_error "找不到 pubspec.yaml.example，请检查项目完整性"
        exit 1
    fi
fi

# 替换 pubspec.yaml 中的名称
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/flutter_template/$PROJECT_NAME/g" pubspec.yaml
    sed -i '' "s/name: .*/name: $PROJECT_NAME/" pubspec.yaml
else
    sed -i "s/flutter_template/$PROJECT_NAME/g" pubspec.yaml
    sed -i "s/name: .*/name: $PROJECT_NAME/" pubspec.yaml
fi

# ============================================================================
# Step 2: 全局替换包名
# ============================================================================
print_step "替换全局包名导入..."

# 查找所有 .dart 文件并替换 'package:flutter_template/' 为 'package:project_name/'
find lib test -name "*.dart" -type f | while read -r file; do
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/package:flutter_template\//package:$PROJECT_NAME\//g" "$file"
    else
        sed -i "s/package:flutter_template\//package:$PROJECT_NAME\//g" "$file"
    fi
done

print_success "包名替换完成"

# ============================================================================
# Step 3: 重命名主应用文件和类
# ============================================================================
print_step "配置主应用入口..."

# 1. 重命名 template_app.dart -> project_name_app.dart
if [ -f "lib/app/template_app.dart" ]; then
    mv "lib/app/template_app.dart" "lib/app/${PROJECT_NAME}_app.dart"
    print_success "重命名 lib/app/template_app.dart -> lib/app/${PROJECT_NAME}_app.dart"
fi

# 2. 替换 template_app.dart 内容中的 TemplateApp 类名
APP_FILE="lib/app/${PROJECT_NAME}_app.dart"
if [ -f "$APP_FILE" ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/class TemplateApp/class ${PROJECT_NAME_PASCAL}App/g" "$APP_FILE"
        sed -i '' "s/const TemplateApp/const ${PROJECT_NAME_PASCAL}App/g" "$APP_FILE"
    else
        sed -i "s/class TemplateApp/class ${PROJECT_NAME_PASCAL}App/g" "$APP_FILE"
        sed -i "s/const TemplateApp/const ${PROJECT_NAME_PASCAL}App/g" "$APP_FILE"
    fi
fi

# 3. 更新 main.dart 中的引用
MAIN_FILE="lib/main.dart"
if [ -f "$MAIN_FILE" ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/import 'app\/template_app.dart';/import 'app\/${PROJECT_NAME}_app.dart';/g" "$MAIN_FILE"
        sed -i '' "s/TemplateApp/${PROJECT_NAME_PASCAL}App/g" "$MAIN_FILE"
    else
        sed -i "s/import 'app\/template_app.dart';/import 'app\/${PROJECT_NAME}_app.dart';/g" "$MAIN_FILE"
        sed -i "s/TemplateApp/${PROJECT_NAME_PASCAL}App/g" "$MAIN_FILE"
    fi
fi

# ============================================================================
# Step 4: 创建必要的目录
# ============================================================================
print_step "创建必要的目录..."

directories=(
    "prototypes"
    "assets/mock"
    "test/core/utils"
    "test/viewmodels"
    "test/test_helpers"
)

for dir in "${directories[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        print_success "已创建目录: $dir"
    else
        print_warning "目录已存在: $dir"
    fi
done

# ============================================================================
# Step 5: 创建异常历史记录文件
# ============================================================================
print_step "检查 docs/exception_history.md..."

if [ ! -f "docs/exception_history.md" ]; then
    cat > docs/exception_history.md << 'EOF'
# 异常历史记录

> 此文件由 `/analyze-error` 工作流自动维护，记录项目开发过程中遇到的所有异常。
> 当某个异常发生 **3 次** 后，将自动晋升到 `prevention_rules.md`。

---

## 记录格式

| 错误类型 | 错误摘要 | 首次发现 | 最后发生 | 计数 | 状态 |
|---------|---------|---------|---------|------|------|
| _示例_ | _Type 'X' is not a subtype of type 'Y'_ | _2026-01-30_ | _2026-01-30_ | _1_ | _活跃_ |

---

## 活跃异常

| 错误类型 | 错误摘要 | 首次发现 | 最后发生 | 计数 | 状态 |
|---------|---------|---------|---------|------|------|
| _待记录_ | - | - | - | 0 | - |

---

## 已解决异常

_暂无_

---

## 已晋升规则

_当计数达到 3 时，相关规则将被移动到 `prevention_rules.md`_
EOF
    print_success "已创建 docs/exception_history.md"
else
    print_warning "docs/exception_history.md 已存在，跳过创建"
fi

# ============================================================================
# Step 6: 创建避坑指南文件
# ============================================================================
print_step "检查 docs/prevention_rules.md..."

if [ ! -f "docs/prevention_rules.md" ]; then
    cat > docs/prevention_rules.md << 'EOF'
# 避坑指南 (Prevention Rules)

> 此文件记录从 `exception_history.md` 晋升的高频错误。
> **所有开发（包括 AI）在编写代码前必须阅读此文件。**

---

## 晋升规则列表

### 🔴 规则 #1: [待填充]
- **触发条件**: 当 `exception_history.md` 中某错误计数达到 3 时自动晋升
- **规则描述**: _描述如何避免此错误_
- **正确做法**: _提供正确的代码示例_
- **错误做法**: _提供错误的代码示例_

---

## 规则模板

当需要添加新规则时，使用以下格式：

```markdown
### 🔴 规则 #N: [简短标题]
- **原始错误**: [从 exception_history.md 复制的错误描述]
- **发生次数**: 3 (晋升阈值)
- **晋升日期**: YYYY-MM-DD
- **规则描述**: [如何避免此错误]
- **正确做法**:
  ```dart
  // 正确代码示例
  ```
- **错误做法**:
  ```dart
  // 错误代码示例
  ```
```

---

## 统计

| 指标 | 数值 |
|-----|------|
| 当前规则数 | 0 |
| 最后更新 | - |
EOF
    print_success "已创建 docs/prevention_rules.md"
else
    print_warning "docs/prevention_rules.md 已存在，跳过创建"
fi

# ============================================================================
# Step 7: 初始化 Git (如果尚未初始化)
# ============================================================================
print_step "检查 Git 仓库..."

if [ ! -d ".git" ]; then
    git init
    print_success "已初始化 Git 仓库"
else
    print_warning "Git 仓库已存在，跳过初始化"
fi

# ============================================================================
# Step 8: 安装 Flutter 依赖
# ============================================================================
print_step "安装 Flutter 依赖..."

if command -v flutter &> /dev/null; then
    flutter pub get
    print_success "Flutter 依赖安装完成"
else
    print_error "未找到 flutter 命令，请确保 Flutter SDK 已正确安装"
    exit 1
fi

# ============================================================================
# Step 9: 代码生成 (可选)
# ============================================================================
print_step "执行代码生成 (build_runner)..."

echo -e "${YELLOW}注意: 代码生成可能需要一些时间...${NC}"

if flutter pub run build_runner build --delete-conflicting-outputs; then
    print_success "代码生成完成"
else
    print_warning "代码生成失败或无需生成，您可以稍后手动执行:"
    echo "  flutter pub run build_runner build --delete-conflicting-outputs"
fi

# ============================================================================
# 完成
# ============================================================================
echo ""
echo "=============================================="
echo -e "   ${GREEN}🎉 项目 ${PROJECT_NAME} 初始化完成！${NC}"
echo "=============================================="
echo ""
echo "下一步操作建议:"
echo "  1. 运行 flutter analyze 检查代码"
echo "  2. 阅读 .rules 文件了解项目铁律"
echo "  3. 阅读 docs/PROJECT_SPECIFICATIONS.md 了解开发规范"
echo ""
