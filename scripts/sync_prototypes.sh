#!/bin/bash

# 原型同步脚本 - 自动从 GitHub 拉取最新的产品原型
# 配置文件: scripts/config.sh

set -e

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# 获取项目根目录
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# 引入配置
if [ -f "$SCRIPT_DIR/config.sh" ]; then
    source "$SCRIPT_DIR/config.sh"
else
    echo "❌ 错误: 找不到配置文件 scripts/config.sh"
    exit 1
fi

REPO_URL=$PROTOTYPE_REPO_URL
TARGET_DIR="$PROJECT_ROOT/$PROTOTYPE_TARGET_DIR"
TEMP_DIR="$PROJECT_ROOT/prototypes_temp"

echo "🚀 开始同步最新的产品原型..."
echo "🔗 仓库地址: $REPO_URL"

# 1. 清理临时目录
if [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
fi

# 2. 克隆最新代码到临时目录
echo "📥 正在从 GitHub 克隆代码..."
git clone --depth 1 $REPO_URL $TEMP_DIR

# 3. 确保目标目录存在
mkdir -p $TARGET_DIR

# 4. 同步文件 (排除 .git 目录)
echo "📂 正在同步到 $PROTOTYPE_TARGET_DIR 目录..."
# 使用 rsync 或 cp 覆盖。这里为了兼容性使用 cp
cp -rf $TEMP_DIR/* $TARGET_DIR/
# 处理隐藏文件 (但不包括 .git)
cp -p $TEMP_DIR/.[!.]* $TARGET_DIR/ 2>/dev/null || true

# 5. 清理临时目录
rm -rf $TEMP_DIR

echo "✅ 原型同步完成！"
echo "📍 目录位置: $TARGET_DIR"
echo "⏰ 同步时间: $(date '+%Y-%m-%d %H:%M:%S')"
