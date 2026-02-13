#!/bin/bash
# ============================================================================
# Flutter 架构合规性校验脚本
# ============================================================================
# 
# 用途: 扫描代码库，检测架构规范违规项
# 用法: ./validate_architecture.sh [目标目录]
# 示例: ./validate_architecture.sh lib/
#
# 检测项:
# - ViewModel 是否继承 BaicBaseViewModel
# - View 是否使用 ViewModelBuilder.reactive()
# - 是否存在违规的导航调用
# - ViewModel 中是否出现 BuildContext
# ============================================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 目标目录
TARGET_DIR="${1:-lib/}"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🔍 Flutter 架构合规性校验器${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "扫描目录: ${TARGET_DIR}"
echo ""

# 计数器
vm_violations=0
view_violations=0
nav_violations=0
context_violations=0

# ============================================================================
# 1. 检查 ViewModel 继承
# ============================================================================
echo -e "${YELLOW}[1/4] 检查 ViewModel 继承...${NC}"

# 查找所有 ViewModel 文件
vm_files=$(find "$TARGET_DIR" -name "*_viewmodel.dart" -o -name "*_view_model.dart" 2>/dev/null)

if [ -n "$vm_files" ]; then
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            # 检查是否继承 BaicBaseViewModel
            if grep -q "extends BaicBaseViewModel" "$file"; then
                echo -e "  ${GREEN}✅${NC} ${file}"
            else
                echo -e "  ${RED}❌${NC} ${file} - 未继承 BaicBaseViewModel"
                ((vm_violations++)) || true
            fi
        fi
    done <<< "$vm_files"
else
    echo -e "  ${YELLOW}⚠️ 未找到 ViewModel 文件${NC}"
fi
echo ""

# ============================================================================
# 2. 检查 View 构建方式
# ============================================================================
echo -e "${YELLOW}[2/4] 检查 View 构建方式...${NC}"

# 查找所有 View 文件
view_files=$(find "$TARGET_DIR" -name "*_view.dart" 2>/dev/null | grep -v "_viewmodel.dart")

if [ -n "$view_files" ]; then
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            # 检查是否使用 ViewModelBuilder.reactive 或 StackedView
            if grep -qE "(ViewModelBuilder.*\.reactive|StackedView)" "$file"; then
                echo -e "  ${GREEN}✅${NC} ${file}"
            else
                # 检查是否是 Stateless/Stateful
                if grep -qE "extends Stateful" "$file"; then
                    echo -e "  ${RED}❌${NC} ${file} - 使用 StatefulWidget 而非 ViewModelBuilder"
                    ((view_violations++)) || true
                fi
            fi
        fi
    done <<< "$view_files"
else
    echo -e "  ${YELLOW}⚠️ 未找到 View 文件${NC}"
fi
echo ""

# ============================================================================
# 3. 检查导航违规
# ============================================================================
echo -e "${YELLOW}[3/4] 检查导航违规...${NC}"

# 检测 Navigator.of(context).push/pop
nav_violations_raw=$(grep -rn --include="*.dart" -E "Navigator\.(of|push|pop|pushNamed)" "$TARGET_DIR" 2>/dev/null || true)
if [ -n "$nav_violations_raw" ]; then
    echo -e "${RED}🔴 发现 Navigator 直接调用违规:${NC}"
    echo "$nav_violations_raw" | head -10 | while read -r line; do
        echo -e "  ${line}"
        ((nav_violations++)) || true
    done
fi

# 检测 context.go / context.push (go_router)
context_nav=$(grep -rn --include="*.dart" -E "context\.(go|push|pop)\(" "$TARGET_DIR" 2>/dev/null || true)
if [ -n "$context_nav" ]; then
    echo -e "${RED}🔴 发现 context.go/push/pop 违规:${NC}"
    echo "$context_nav" | head -10 | while read -r line; do
        echo -e "  ${line}"
        ((nav_violations++)) || true
    done
fi
echo ""

# ============================================================================
# 4. 检查 ViewModel 中的 BuildContext
# ============================================================================
echo -e "${YELLOW}[4/4] 检查 ViewModel 中的 UI 依赖...${NC}"

if [ -n "$vm_files" ]; then
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            # 检查是否包含 BuildContext
            if grep -q "BuildContext" "$file"; then
                echo -e "  ${RED}❌${NC} ${file} - 包含 BuildContext"
                ((context_violations++)) || true
            fi
            # 检查是否包含 showDialog
            if grep -q "showDialog" "$file"; then
                echo -e "  ${RED}❌${NC} ${file} - 包含 showDialog"
                ((context_violations++)) || true
            fi
        fi
    done <<< "$vm_files"
fi
echo ""

# ============================================================================
# 输出汇总
# ============================================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📊 架构校验结果汇总${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

total=$((vm_violations + view_violations + nav_violations + context_violations))

if [ "$total" -eq 0 ]; then
    echo -e "${GREEN}✅ 架构校验通过！代码符合 MVVM 规范。${NC}"
else
    echo -e "${RED}🔴 发现 ${total} 个架构违规项:${NC}"
    echo -e "  - ViewModel 继承违规: ${vm_violations} 个"
    echo -e "  - View 构建方式违规: ${view_violations} 个"
    echo -e "  - 导航调用违规: ${nav_violations} 个"
    echo -e "  - UI 依赖违规: ${context_violations} 个"
    echo ""
    echo -e "${YELLOW}💡 修复建议:${NC}"
    echo -e "  - ViewModel 必须继承 BaicBaseViewModel"
    echo -e "  - View 必须使用 ViewModelBuilder.reactive()"
    echo -e "  - 导航使用 MapsTo() 和 goBack()"
    echo -e "  - ViewModel 中禁止使用 BuildContext"
fi

echo ""
exit 0
