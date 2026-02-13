#!/bin/bash
# ============================================================================
# Flutter UI 规范违规扫描脚本
# ============================================================================
# 
# 用途: 扫描指定目录下的 Dart 文件，检测视觉规范违规项
# 用法: ./scan_violations.sh [目标目录]
# 示例: ./scan_violations.sh lib/
#
# 检测项:
# - 硬编码颜色: Color(0xFF...), Color.fromRGBO, Colors.xxx
# - 硬编码圆角: BorderRadius.circular(数字)
# - 硬编码间距: EdgeInsets.all(数字), SizedBox(height/width: 数字)
# ============================================================================

set -e

# 颜色定义
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 目标目录
TARGET_DIR="${1:-lib/}"

# 计数器
color_violations=0
radius_violations=0
spacing_violations=0

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🔍 Flutter UI 规范扫描器${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "扫描目录: ${TARGET_DIR}"
echo ""

# ============================================================================
# 1. 扫描硬编码颜色
# ============================================================================
echo -e "${YELLOW}[1/3] 扫描硬编码颜色...${NC}"

# 检测 Color(0xFF...)
color_hex=$(grep -rn --include="*.dart" "Color(0x[0-9A-Fa-f]" "$TARGET_DIR" 2>/dev/null || true)
if [ -n "$color_hex" ]; then
    echo -e "${RED}🔴 发现 Color(0xFF...) 违规:${NC}"
    echo "$color_hex" | while read -r line; do
        echo -e "  ${line}"
        ((color_violations++)) || true
    done
    echo ""
fi

# 检测 Color.fromRGBO/fromARGB
color_from=$(grep -rn --include="*.dart" -E "Color\.from(RGBO|ARGB)\(" "$TARGET_DIR" 2>/dev/null || true)
if [ -n "$color_from" ]; then
    echo -e "${RED}🔴 发现 Color.fromRGBO/ARGB 违规:${NC}"
    echo "$color_from" | while read -r line; do
        echo -e "  ${line}"
        ((color_violations++)) || true
    done
    echo ""
fi

# 检测 Colors.xxx (Flutter 内置颜色)
colors_builtin=$(grep -rn --include="*.dart" -E "Colors\.[a-z]+" "$TARGET_DIR" 2>/dev/null | grep -v "AppColors" || true)
if [ -n "$colors_builtin" ]; then
    echo -e "${RED}🔴 发现 Flutter 内置颜色 (Colors.xxx) 违规:${NC}"
    echo "$colors_builtin" | while read -r line; do
        echo -e "  ${line}"
        ((color_violations++)) || true
    done
    echo ""
fi

# ============================================================================
# 2. 扫描硬编码圆角
# ============================================================================
echo -e "${YELLOW}[2/3] 扫描硬编码圆角...${NC}"

# 检测 BorderRadius.circular(数字) 或 Radius.circular(数字)
radius_violations_raw=$(grep -rn --include="*.dart" -E "(BorderRadius|Radius)\.circular\(\s*[0-9]+" "$TARGET_DIR" 2>/dev/null || true)
if [ -n "$radius_violations_raw" ]; then
    echo -e "${RED}🔴 发现硬编码圆角违规:${NC}"
    echo "$radius_violations_raw" | while read -r line; do
        echo -e "  ${line}"
        ((radius_violations++)) || true
    done
    echo ""
fi

# ============================================================================
# 3. 扫描硬编码间距
# ============================================================================
echo -e "${YELLOW}[3/3] 扫描硬编码间距...${NC}"

# 检测 EdgeInsets.all(数字) - 排除 0
spacing_edgeinsets=$(grep -rn --include="*.dart" -E "EdgeInsets\.all\(\s*[1-9][0-9]*" "$TARGET_DIR" 2>/dev/null || true)
if [ -n "$spacing_edgeinsets" ]; then
    echo -e "${RED}🔴 发现 EdgeInsets.all(数字) 违规:${NC}"
    echo "$spacing_edgeinsets" | while read -r line; do
        echo -e "  ${line}"
        ((spacing_violations++)) || true
    done
    echo ""
fi

# 检测 SizedBox(height/width: 数字) - 排除 0
spacing_sizedbox=$(grep -rn --include="*.dart" -E "SizedBox\((height|width):\s*[1-9][0-9]*" "$TARGET_DIR" 2>/dev/null || true)
if [ -n "$spacing_sizedbox" ]; then
    echo -e "${RED}🔴 发现 SizedBox 硬编码间距违规:${NC}"
    echo "$spacing_sizedbox" | while read -r line; do
        echo -e "  ${line}"
        ((spacing_violations++)) || true
    done
    echo ""
fi

# ============================================================================
# 输出汇总
# ============================================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📊 扫描结果汇总${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# 统计实际违规数量
total_color=$(echo "$color_hex$color_from$colors_builtin" | grep -c "." 2>/dev/null || echo "0")
total_radius=$(echo "$radius_violations_raw" | grep -c "." 2>/dev/null || echo "0")
total_spacing=$(echo "$spacing_edgeinsets$spacing_sizedbox" | grep -c "." 2>/dev/null || echo "0")
total=$((total_color + total_radius + total_spacing))

if [ "$total" -eq 0 ]; then
    echo -e "${GREEN}✅ 扫描完成，未发现违规项！代码符合视觉规范。${NC}"
else
    echo -e "${RED}🔴 发现 ${total} 个违规项:${NC}"
    echo -e "  - 颜色违规: ${total_color} 个"
    echo -e "  - 圆角违规: ${total_radius} 个"
    echo -e "  - 间距违规: ${total_spacing} 个"
    echo ""
    echo -e "${YELLOW}💡 修复建议:${NC}"
    echo -e "  - 颜色: 使用 AppColors.xxx 替代硬编码"
    echo -e "  - 圆角: 使用 AppDimensions.radiusXS/S/M/L/Full 替代"
    echo -e "  - 间距: 使用 AppDimensions.spaceXS/S/M/ML/L/XL/XXL 替代"
fi

echo ""
exit 0
