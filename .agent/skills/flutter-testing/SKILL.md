---
name: flutter-testing
description: 根据 ViewModel 方法签名自动生成单元测试骨架，提供测试最佳实践指导
---

# Flutter 测试自动化 (Testing Automation)

> **触发场景**: 完成 Feature 开发后，或用户请求生成测试时

## 核心能力

1. **测试骨架生成** - 分析 ViewModel 方法，自动生成对应的测试用例骨架
2. **Mock 模板** - 提供 Service Mock 的标准模板
3. **测试策略指导** - 指导测试覆盖范围和优先级

---

## 测试结构规范

### 目录结构

```
test/
├── ui/
│   └── views/
│       └── [feature]/
│           ├── [feature]_viewmodel_test.dart  # ViewModel 单元测试
│           └── [feature]_view_test.dart       # Widget 测试
├── core/
│   └── services/
│       └── [service]_test.dart                # Service 单元测试
└── helpers/
    └── test_helpers.dart                       # 测试辅助工具
```

---

## ViewModel 测试生成规则

### 方法签名 → 测试用例

| ViewModel 方法 | 生成的测试 |
|---------------|-----------|
| `Future<void> initialise()` | 初始化状态验证测试 |
| `void selectItem(int index)` | 参数边界测试 + 状态变更测试 |
| `Future<void> loadData()` | 成功/失败场景测试 |
| `bool get isLoading` | Getter 值验证测试 |

### 测试模板

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// 导入 ViewModel 和依赖
import 'package:app/ui/views/xxx/xxx_viewmodel.dart';

void main() {
  group('XxxViewModel Tests', () {
    late XxxViewModel viewModel;
    
    setUp(() {
      viewModel = XxxViewModel();
    });
    
    tearDown(() {
      viewModel.dispose();
    });
    
    // ==========================================
    // 初始化测试
    // ==========================================
    group('initialise', () {
      test('初始化后应设置默认状态', () async {
        // Arrange - 准备
        
        // Act - 执行
        await viewModel.initialise();
        
        // Assert - 验证
        expect(viewModel.isBusy, false);
        expect(viewModel.hasError, false);
      });
    });
    
    // ==========================================
    // 业务逻辑测试
    // ==========================================
    group('selectItem', () {
      test('选择有效索引应更新 selectedIndex', () {
        // Arrange
        viewModel.selectItem(0);
        
        // Assert
        expect(viewModel.selectedIndex, 0);
      });
      
      test('选择无效索引应保持原状态', () {
        // Arrange
        final original = viewModel.selectedIndex;
        
        // Act
        viewModel.selectItem(-1);
        
        // Assert
        expect(viewModel.selectedIndex, original);
      });
    });
  });
}
```

---

## Widget 测试生成规则

### 测试模板

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/ui/views/xxx/xxx_view.dart';

void main() {
  group('XxxView Widget Tests', () {
    // ==========================================
    // 渲染测试
    // ==========================================
    testWidgets('页面应正确渲染', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: XxxView()),
      );
      
      // 验证关键元素存在
      expect(find.byType(Scaffold), findsOneWidget);
    });
    
    // ==========================================
    // 加载状态测试
    // ==========================================
    testWidgets('加载中应显示骨架屏', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: XxxView()),
      );
      
      // 验证骨架屏存在
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // 等待加载完成
      await tester.pumpAndSettle();
      
      // 验证内容显示
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
    
    // ==========================================
    // 交互测试
    // ==========================================
    testWidgets('点击返回按钮应触发导航', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: XxxView()),
      );
      await tester.pumpAndSettle();
      
      // 点击返回按钮
      await tester.tap(find.byIcon(Icons.arrow_back_ios));
      await tester.pumpAndSettle();
      
      // 验证导航调用
    });
  });
}
```

---

## Mock 模板

### Service Mock

```dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:app/core/services/xxx_service.dart';

@GenerateMocks([XxxService])
void main() {}

// 使用生成的 MockXxxService
// 运行: flutter pub run build_runner build
```

---

## 脚本调用

### 生成测试骨架
```bash
./.agent/skills/flutter-testing/scripts/generate_tests.sh lib/ui/views/xxx/xxx_viewmodel.dart

# 输出: test/ui/views/xxx/xxx_viewmodel_test.dart
```

---

## 测试覆盖优先级

| 优先级 | 测试类型 | 覆盖目标 |
|-------|---------|---------|
| P0 | ViewModel 核心逻辑 | 所有 public 方法 |
| P1 | 状态变更 | 所有 setter 和 rebuildUi 调用 |
| P2 | 边界条件 | 空数据、无效参数 |
| P3 | Widget 渲染 | 关键页面元素 |
| P4 | Widget 交互 | 按钮点击、表单提交 |

---

## 运行测试

```bash
# 运行所有测试
flutter test

# 运行特定测试
flutter test test/ui/views/xxx/

# 生成覆盖率
flutter test --coverage

# 查看覆盖率报告
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```
