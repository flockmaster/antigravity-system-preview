---
name: exception-guardian
description: 错误模式匹配引擎，自动关联历史解决方案，强制执行 Step 0 异常处理流程
---

# 异常守护者 (Exception Guardian)

> **触发场景**: AI 遇到任何编译错误、运行时异常或用户报告的 Bug 时**自动触发**

## 核心能力

1. **模式匹配** - 根据错误类型自动匹配已知错误模式库
2. **解决方案推荐** - 根据历史记录推荐最可能的解决方案
3. **Step 0 强制** - 确保异常处理流程优先于代码修复

---

## ⚠️ Step 0 强制执行令

**绝对优先级**: 遇到任何错误时，必须先执行以下步骤，禁止直接修复代码。

```
✅ Step 0.1: 立即停止所有代码修改动作
✅ Step 0.2: 读取 docs/exception_history.md
✅ Step 0.3: 识别错误模式（匹配下方错误模式库）
✅ Step 0.4: 更新 exception_history.md（新增或计数+1）
✅ Step 0.5: 检查是否达到 3 次，若是则晋升到 prevention_rules.md
✅ Step 0.6: 完成上述步骤后，才允许开始修复代码
```

---

## 错误模式库

### 🔴 编译错误 (Compile-Time Errors)

#### E001: 类型不匹配
```
Error: The argument type 'X' can't be assigned to the parameter type 'Y'
```
**常见原因**: 
- `String` 与 `int` 混用
- 可空类型未处理 (`String?` vs `String`)

**解决方案**:
1. 检查变量类型定义
2. 添加类型转换 `.toString()` / `int.parse()`
3. 处理可空类型 `??` / `!`

---

#### E002: 未定义的标识符
```
Error: Undefined name 'xxx'
```
**常见原因**:
- 缺少 import
- 拼写错误
- 变量未声明

**解决方案**:
1. 添加正确的 import
2. 检查变量/类名拼写
3. 确认变量已声明

---

#### E003: 无效的 override
```
Error: 'xxx' isn't a valid override of 'yyy'
```
**常见原因**:
- 方法签名不匹配
- 返回类型不兼容

**解决方案**:
1. 检查父类方法签名
2. 确保返回类型一致
3. 确保参数类型兼容

---

### 🟠 运行时错误 (Runtime Errors)

#### R001: Null 空指针
```
Null check operator used on a null value
```
**常见原因**:
- 使用 `!` 操作符访问 null 值
- 未初始化的变量

**解决方案**:
1. 添加空值检查 `if (value != null)`
2. 使用 `?.` 安全访问
3. 提供默认值 `?? defaultValue`

---

#### R002: RenderBox 布局错误
```
RenderBox was not laid out
```
**常见原因**:
- ListView 直接放在 Column 中
- Expanded 在无限高度容器中

**解决方案**:
1. 给 ListView 添加 `shrinkWrap: true`
2. 用 Expanded 包裹 ListView
3. 给容器指定固定高度

---

#### R003: setState after dispose
```
setState() called after dispose()
```
**常见原因**:
- 异步操作完成后 Widget 已销毁

**解决方案**:
1. 添加 `if (mounted)` 检查
2. 在 `dispose()` 中取消异步操作
3. 使用 `CancelableOperation`

---

### 🟡 Flutter 特有错误

#### F001: 找不到 Widget
```
Error: Could not find the correct Provider
```
**常见原因**:
- Provider/Locator 未正确初始化
- 依赖注入顺序错误

**解决方案**:
1. 确认 `setupLocator()` 已调用
2. 检查依赖注册顺序
3. 使用 `locator.isRegistered<T>()`

---

#### F002: 图片加载失败
```
Unable to load asset: xxx
```
**常见原因**:
- 资源路径错误
- pubspec.yaml 未声明 assets

**解决方案**:
1. 检查文件路径大小写
2. 确认 pubspec.yaml 中 assets 配置
3. 运行 `flutter clean && flutter pub get`

---

## 自动晋升机制

当某个错误模式在 `exception_history.md` 中出现 **3 次**，自动触发:

1. **提炼规则**: 将错误模式提炼为可操作的开发规则
2. **晋升写入**: 将规则添加到 `docs/prevention_rules.md`
3. **汇报用户**: 
   ```
   🚨 高频错误警告：
   - 错误类型：[具体错误]
   - 发生次数：3次
   - 已自动晋升到避坑指南
   ```

---

## 资源文件

- [完整错误模式库](resources/error_patterns.yaml) - 包含更多错误模式和解决方案

---

## 与工作流集成

此 Skill 在以下场景自动触发:

- `/analyze-error` - 完整执行 Step 0 流程
- 任何编译/运行错误 - 自动匹配模式并推荐解决方案
- 代码修复前 - 强制读取 `prevention_rules.md`
