#!/bin/bash
# ============================================================================
# Flutter 测试骨架生成脚本
# ============================================================================
# 
# 用途: 根据 ViewModel 文件自动生成对应的测试骨架
# 用法: ./generate_tests.sh <viewmodel_file_path>
# 示例: ./generate_tests.sh lib/ui/views/home/home_viewmodel.dart
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
    echo -e "${RED}❌ 错误: 请提供 ViewModel 文件路径${NC}"
    echo "用法: ./generate_tests.sh <viewmodel_file_path>"
    exit 1
fi

VM_FILE="$1"

# 检查文件是否存在
if [ ! -f "$VM_FILE" ]; then
    echo -e "${RED}❌ 错误: 文件不存在: ${VM_FILE}${NC}"
    exit 1
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🧪 Flutter 测试骨架生成器${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "源文件: ${VM_FILE}"

# 提取文件名和类名
FILENAME=$(basename "$VM_FILE" .dart)
DIRNAME=$(dirname "$VM_FILE")

# 计算测试文件路径 (lib/ -> test/)
TEST_DIR="${DIRNAME/lib\//test/}"
TEST_FILE="${TEST_DIR}/${FILENAME}_test.dart"

# 从文件名推断类名 (如 home_viewmodel -> HomeViewModel)
CLASS_NAME=$(echo "$FILENAME" | sed -r 's/(^|_)([a-z])/\U\2/g')

echo -e "测试文件: ${TEST_FILE}"
echo -e "类名: ${CLASS_NAME}"
echo ""

# 创建测试目录
mkdir -p "$TEST_DIR"

# 提取 ViewModel 中的方法
echo -e "${BLUE}[1/2] 分析 ViewModel 方法...${NC}"

# 获取所有 public 方法 (简单匹配)
methods=$(grep -E "^\s*(Future<void>|void|bool|String|int|List|Map)\s+\w+\(" "$VM_FILE" | grep -v "^//" || true)

# 生成测试文件
echo -e "${BLUE}[2/2] 生成测试骨架...${NC}"

cat > "$TEST_FILE" << EOF
import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';

// 导入 ViewModel
// TODO: 请根据实际项目包名调整导入路径
// import 'package:your_app/${VM_FILE#lib/}';

void main() {
  group('${CLASS_NAME} Tests', () {
    late dynamic viewModel; // TODO: 替换为实际类型 ${CLASS_NAME}
    
    setUp(() {
      // viewModel = ${CLASS_NAME}();
    });
    
    tearDown(() {
      // viewModel.dispose();
    });
    
    // ============================================================================
    // 初始化测试
    // ============================================================================
    group('初始化', () {
      test('初始化后应设置正确的默认状态', () async {
        // Arrange - 准备测试数据
        
        // Act - 执行被测方法
        // await viewModel.initialise();
        
        // Assert - 验证结果
        // expect(viewModel.isBusy, false);
        // expect(viewModel.hasError, false);
      });
    });
    
    // ============================================================================
    // 业务逻辑测试
    // ============================================================================
EOF

# 为每个找到的方法生成测试组
if [ -n "$methods" ]; then
    echo "$methods" | while IFS= read -r method; do
        # 提取方法名
        method_name=$(echo "$method" | sed -E 's/.*(void|Future<void>|bool|String|int)\s+([a-zA-Z_]+)\(.*/\2/')
        
        if [ -n "$method_name" ] && [ "$method_name" != "dispose" ]; then
            cat >> "$TEST_FILE" << EOF
    
    group('$method_name', () {
      test('正常场景 - TODO: 描述预期行为', () {
        // Arrange
        
        // Act
        // viewModel.$method_name();
        
        // Assert
        // expect(result, expected);
      });
      
      test('边界场景 - TODO: 测试边界条件', () {
        // Arrange
        
        // Act
        
        // Assert
      });
    });
EOF
        fi
    done
fi

# 添加文件结尾
cat >> "$TEST_FILE" << EOF
  });
}
EOF

# 完成提示
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ 测试骨架生成完成!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "生成的文件:"
echo -e "  📄 ${TEST_FILE}"
echo ""
echo -e "${YELLOW}📋 下一步:${NC}"
echo "  1. 调整 import 路径"
echo "  2. 取消注释并完善测试用例"
echo "  3. 运行: flutter test ${TEST_FILE}"
echo ""
