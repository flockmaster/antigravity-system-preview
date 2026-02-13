#!/bin/bash

# ============================================================================
# 🔍 代码保真度检查脚本
# 用途: 自动检测代码中违反 UI 视觉规范的硬编码
# 检测项: 硬编码颜色、圆角、间距
# 使用: ./scripts/check_fidelity.sh [目录路径]
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

# 检查目录 (默认为 lib/)
SEARCH_DIR="${1:-$PROJECT_ROOT/lib}"

# 排除目录 (这些目录包含定义文件，不应被检查)
EXCLUDE_PATTERN="--exclude-dir=theme --exclude-dir=base"

# 计数器
TOTAL_VIOLATIONS=0
COLOR_VIOLATIONS=0
RADIUS_VIOLATIONS=0
SPACING_VIOLATIONS=0

echo ""
echo "=============================================="
echo "   🔍 代码保真度检查器 (Fidelity Checker)"
echo "=============================================="
echo ""
echo -e "${BLUE}[检查目录]${NC} $SEARCH_DIR"
echo ""

# ============================================================================
# 检查 1: 硬编码颜色 (0xFF...)
# ============================================================================
echo -e "${YELLOW}[检查]${NC} 硬编码颜色 (Color(0xFF...), Color.fromRGBO)..."

COLOR_RESULTS=$(grep -rn $EXCLUDE_PATTERN --include="*.dart" -E "Color\((0x|0X)[0-9A-Fa-f]+" "$SEARCH_DIR" 2>/dev/null || true)
RGBO_RESULTS=$(grep -rn $EXCLUDE_PATTERN --include="*.dart" "Color\.fromRGBO" "$SEARCH_DIR" 2>/dev/null || true)

if [ -n "$COLOR_RESULTS" ] || [ -n "$RGBO_RESULTS" ]; then
    echo -e "${RED}[违规]${NC} 发现硬编码颜色:"
    if [ -n "$COLOR_RESULTS" ]; then
        echo "$COLOR_RESULTS" | while read -r line; do
            echo -e "  ${RED}→${NC} $line"
            ((COLOR_VIOLATIONS++)) || true
        done
        COLOR_VIOLATIONS=$(echo "$COLOR_RESULTS" | wc -l | tr -d ' ')
    fi
    if [ -n "$RGBO_RESULTS" ]; then
        echo "$RGBO_RESULTS" | while read -r line; do
            echo -e "  ${RED}→${NC} $line"
        done
        RGBO_COUNT=$(echo "$RGBO_RESULTS" | wc -l | tr -d ' ')
        COLOR_VIOLATIONS=$((COLOR_VIOLATIONS + RGBO_COUNT))
    fi
    echo ""
else
    echo -e "${GREEN}[通过]${NC} 未发现硬编码颜色"
    echo ""
fi

# ============================================================================
# 检查 2: 硬编码圆角 (BorderRadius.circular(数字))
# ============================================================================
echo -e "${YELLOW}[检查]${NC} 硬编码圆角 (BorderRadius.circular(数字))..."

# 匹配 circular( 后面跟着纯数字的情况，排除 AppDimensions
RADIUS_RESULTS=$(grep -rn $EXCLUDE_PATTERN --include="*.dart" -E "circular\([0-9]+\.?[0-9]*\)" "$SEARCH_DIR" 2>/dev/null | grep -v "AppDimensions" || true)

if [ -n "$RADIUS_RESULTS" ]; then
    echo -e "${RED}[违规]${NC} 发现硬编码圆角:"
    echo "$RADIUS_RESULTS" | while read -r line; do
        echo -e "  ${RED}→${NC} $line"
    done
    RADIUS_VIOLATIONS=$(echo "$RADIUS_RESULTS" | wc -l | tr -d ' ')
    echo ""
else
    echo -e "${GREEN}[通过]${NC} 未发现硬编码圆角"
    echo ""
fi

# ============================================================================
# 检查 3: 硬编码间距 (EdgeInsets 和 SizedBox 中的裸数字)
# ============================================================================
echo -e "${YELLOW}[检查]${NC} 硬编码间距 (EdgeInsets/SizedBox 中的数字)..."

# 匹配 EdgeInsets.all(数字) 或 EdgeInsets.symmetric(数字)
SPACING_RESULTS=$(grep -rn $EXCLUDE_PATTERN --include="*.dart" -E "EdgeInsets\.(all|symmetric|only|fromLTRB)\([^A-Za-z]*[0-9]+\.?[0-9]*" "$SEARCH_DIR" 2>/dev/null | grep -v "AppDimensions" || true)

# 匹配 SizedBox(width/height: 数字)
SIZEDBOX_RESULTS=$(grep -rn $EXCLUDE_PATTERN --include="*.dart" -E "SizedBox\((width|height):\s*[0-9]+\.?[0-9]*" "$SEARCH_DIR" 2>/dev/null | grep -v "AppDimensions" || true)

if [ -n "$SPACING_RESULTS" ] || [ -n "$SIZEDBOX_RESULTS" ]; then
    echo -e "${RED}[违规]${NC} 发现硬编码间距:"
    if [ -n "$SPACING_RESULTS" ]; then
        echo "$SPACING_RESULTS" | while read -r line; do
            echo -e "  ${RED}→${NC} $line"
        done
        SPACING_VIOLATIONS=$(echo "$SPACING_RESULTS" | wc -l | tr -d ' ')
    fi
    if [ -n "$SIZEDBOX_RESULTS" ]; then
        echo "$SIZEDBOX_RESULTS" | while read -r line; do
            echo -e "  ${RED}→${NC} $line"
        done
        SIZEDBOX_COUNT=$(echo "$SIZEDBOX_RESULTS" | wc -l | tr -d ' ')
        SPACING_VIOLATIONS=$((SPACING_VIOLATIONS + SIZEDBOX_COUNT))
    fi
    echo ""
else
    echo -e "${GREEN}[通过]${NC} 未发现硬编码间距"
    echo ""
fi

# ============================================================================
# 汇总报告
# ============================================================================
TOTAL_VIOLATIONS=$((COLOR_VIOLATIONS + RADIUS_VIOLATIONS + SPACING_VIOLATIONS))

echo "=============================================="
echo "   📊 检查报告"
echo "=============================================="
echo ""
echo -e "颜色违规:  ${COLOR_VIOLATIONS:-0} 处"
echo -e "圆角违规:  ${RADIUS_VIOLATIONS:-0} 处"
echo -e "间距违规:  ${SPACING_VIOLATIONS:-0} 处"
echo "----------------------------------------------"
echo -e "总计:      ${TOTAL_VIOLATIONS:-0} 处违规"
echo ""

if [ "${TOTAL_VIOLATIONS:-0}" -eq 0 ]; then
    echo -e "${GREEN}✅ 代码保真度检查通过！${NC}"
    exit 0
else
    echo -e "${RED}❌ 发现 ${TOTAL_VIOLATIONS} 处违规，请修复后再提交。${NC}"
    echo ""
    echo "修复指南:"
    echo "  - 颜色: 使用 AppColors.xxx 替代 Color(0xFF...)"
    echo "  - 圆角: 使用 AppDimensions.radiusXXX 替代裸数字"
    echo "  - 间距: 使用 AppDimensions.spaceXXX 替代裸数字"
    exit 1
fi
