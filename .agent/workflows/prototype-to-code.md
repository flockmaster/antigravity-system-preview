---
description: 严格按照 AI Studio 原型开发 Flutter 页面的标准工作流 (商业级交付标准)
---

# 从原型到代码的标准工作流 (V5.0 - 商业级交付版)

// turbo-all

**核心原则**: 本工作流要求按照**商业可交付水平**进行开发，确保代码质量、可维护性和视觉还原度达到生产环境标准。每个页面的开发必须严格遵循 **8 阶段 SOP** (6 阶段开发 + 测试 + 合规检查)。

---

## 📋 开发前置要求

1. **原型路径**: 从 `.rules` 指定的根路径 `prototypes/` 递归寻找与任务相关的 React/JS/HTML 文件。
2. **铁律遵守**: 严格执行 `.rules` 中的所有铁律，特别是铁律 2 (UI 视觉规范) 和铁律 10 (中文备注)。
3. **异常处理**: 遇到任何错误必须先执行 Step 0 流程 (记录 → 识别模式 → 修复)。

---

## 🎯 八阶段商业级开发 SOP

### 阶段 1: 原型深度解析 (Deep Prototype Analysis)

> 💡 **Skill 支持**: 使用 `prototype-analyzer` Skill 自动提取组件结构和样式映射。
> 参考: `.agent/skills/prototype-analyzer/SKILL.md`

**目标**: 100% 理解原型的视觉、交互和数据结构。

**执行步骤**:
1. **读取源码**: 定位并完整阅读目标页面的 React 组件文件 (如 `StoreView.tsx`)。
2. **提取布局结构**:
   - 识别 Flex 布局、Grid 布局、Scroll 区域、Header/Footer。
   - 记录层级关系 (父子组件嵌套)。
3. **提取业务逻辑**:
   - 识别所有 `useState`, `useEffect`, 事件处理函数。
   - **原则**: 直接"抄"原型中的计算逻辑和变量名，不擅自改动。
4. **提取视觉细节**:
   - 颜色 (如 `text-[#000]`, `bg-orange-500`)
   - 圆角 (如 `rounded-full`, `rounded-2xl`)
   - 阴影 (如 `shadow-lg`)
   - 间距 (如 `p-4`, `gap-6`)
5. **提取内容保真**:
   - 所有文案 (Copy)
   - 图像地址 (Image URLs)
   - 模拟数据 (Mock Data) - **不编造，直接使用原型数据**
6. **映射到设计系统**:
   - 将原型中的颜色映射到 `AppColors.xxx`
   - 将原型中的圆角映射到 `AppDimensions.radiusXXX`
   - 将原型中的间距映射到 `AppDimensions.spaceXXX`

**交付物**: 
- 原型分析文档 (可选，记录在 `task.md` 或脑海中)
- 明确的组件拆解清单

---

### 📖 Tailwind → Flutter 速查表

快速将原型中的 Tailwind CSS 类转换为 Flutter 代码：

#### 颜色映射
| Tailwind | Flutter |
|----------|---------|
| `text-orange-500`, `bg-orange-500` | `AppColors.brandOrange` |
| `text-gray-900`, `text-[#000]` | `AppColors.textPrimary` |
| `text-gray-500` | `AppColors.textSecondary` |
| `bg-white` | `AppColors.bgPrimary` |
| `bg-gray-100` | `AppColors.bgSecondary` |

#### 圆角映射
| Tailwind | Flutter |
|----------|---------|
| `rounded` | `BorderRadius.circular(AppDimensions.radiusXS)` (4px) |
| `rounded-lg` | `BorderRadius.circular(AppDimensions.radiusS)` (8px) |
| `rounded-xl` | `BorderRadius.circular(AppDimensions.radiusM)` (12px) |
| `rounded-2xl` | `BorderRadius.circular(AppDimensions.radiusL)` (16px) |
| `rounded-full` | `BorderRadius.circular(AppDimensions.radiusFull)` (999px) |

#### 间距映射
| Tailwind | Flutter |
|----------|---------|
| `p-1`, `m-1` | `AppDimensions.spaceXS` (4px) |
| `p-2`, `m-2`, `gap-2` | `AppDimensions.spaceS` (8px) |
| `p-4`, `m-4`, `gap-4` | `AppDimensions.spaceM` (16px) |
| `p-6`, `m-6`, `gap-6` | `AppDimensions.spaceL` (24px) |
| `p-8`, `m-8` | `AppDimensions.spaceXL` (32px) |

#### 文字大小映射
| Tailwind | Flutter |
|----------|---------|
| `text-xs` | `AppTypography.bodySmall` (12px) |
| `text-sm` | `AppTypography.bodyMedium` (14px) |
| `text-base` | `AppTypography.bodyLarge` (16px) |
| `text-lg` | `AppTypography.titleSmall` (18px) |
| `text-xl` | `AppTypography.titleMedium` (20px) |
| `text-2xl` | `AppTypography.titleLarge` (24px) |

---

### 阶段 2: 数据建模与服务层 (Data Modeling & Service Layer)

**目标**: 定义健壮的数据模型和服务接口。

**执行步骤**:
1. **定义 Model 类**:
   - 使用 `json_serializable` 注解
   - **必须**: 为每个字段添加详尽的中文备注 (铁律 10)
   - 示例:
     ```dart
     /// 商品模型 - 描述商城中的单个商品对象
     @JsonSerializable()
     class StoreProduct {
       /// 商品唯一标识
       final String id;
       /// 商品标题 (如: BJ40 专用 TPE 脚垫)
       final String title;
       // ...
     }
     ```
2. **定义 Service 接口**:
   - 创建抽象接口 (如 `IStoreService`)
   - 实现具体类 (如 `StoreService`)
   - 在 `app.dart` 中注册为 `LazySingleton`
3. **配置 Mock 数据**:
   - 在 `assets/mock/` 目录下创建对应的 JSON 文件
   - 在 `MockInterceptor` 中配置路径拦截
   - 确保 Mock 数据与原型数据一致
4. **运行代码生成**:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

**交付物**:
- `lib/core/models/xxx_model.dart`
- `lib/core/services/xxx_service.dart`
- `assets/mock/xxx/data.json`

---

### 阶段 3: 业务逻辑实现 (ViewModel Strategy)

**目标**: 实现符合 MVVM 架构的业务逻辑层。

**执行步骤**:
1. **创建 ViewModel**:
   - 继承 `BaicBaseViewModel`
   - **必须**: 为每个方法添加中文备注说明触发场景和核心逻辑
2. **实现状态管理**:
   - 定义所有必要的状态变量 (如 `_isScrolled`, `_activeCategory`)
   - 使用 `notifyListeners()` 通知 UI 更新
3. **实现交互逻辑**:
   - 将原型中的事件处理函数转换为 ViewModel 方法
   - 使用 `setBusy(true/false)` 管理加载状态
4. **实现导航逻辑**:
   - 使用 `MapsTo()` 方法进行页面跳转
   - 禁止在 ViewModel 中使用 `BuildContext` 或 `Navigator`
5. **依赖注入**:
   - 通过 `locator<T>()` 获取 Service 实例

**交付物**:
- `lib/ui/views/xxx/xxx_view_model.dart`

---

### 阶段 4: 原子化组件开发 (Atomic UI Components)

> 💡 **Skill 支持**: 使用 `flutter-ui-compliance` Skill 实时校验视觉规范。
> 参考: `.agent/skills/flutter-ui-compliance/SKILL.md`

**目标**: 开发可复用、高质量的 UI 原子组件。

**执行步骤**:
1. **组件拆解**:
   - 将页面拆解为独立的原子组件 (如 `SearchBar`, `ProductCard`, `Banner`)
   - 每个组件应职责单一、高度可复用
2. **视觉规范强制执行**:
   - **绝对禁止**: 硬编码颜色 `Color(0xFF...)`
   - **绝对禁止**: 硬编码圆角 `BorderRadius.circular(24)`
   - **绝对禁止**: 硬编码间距 `EdgeInsets.all(16)`
   - **唯一合法**: 使用 `AppColors.xxx`, `AppDimensions.radiusXXX`, `AppDimensions.spaceXXX`
3. **交互规范**:
   - 所有可点击元素必须包裹在 `BaicBounceButton` 中
4. **组件复用优先**:
   - 检索 `lib/shared/widgets` 是否已有类似组件
   - 避免重复造轮子
5. **中文备注**:
   - 每个组件必须有类级别的中文注释
   - 每个参数必须有中文说明

**交付物**:
- `lib/ui/views/xxx/widgets/xxx_widget.dart` (多个原子组件)

---

### 阶段 5: 视图组装与视觉调优 (View Assembly & Visual Tuning)

**目标**: 组装完整页面并实现像素级还原。

**执行步骤**:
1. **创建主 View**:
   - 使用 `StackedView<T>` 或 `ViewModelBuilder<T>.reactive()`
   - 实现 `builder()` 方法
2. **组装原子组件**:
   - 按照原型的层级关系组装各个原子组件
   - 使用 `CustomScrollView` + `Sliver` 实现复杂滚动效果
3. **实现骨架屏**:
   - 定义 `_SkeletonView` 私有组件
   - 在 `viewModel.isBusy` 时显示骨架屏
4. **视觉调优**:
   - 对比原型进行像素级调整
   - 确保颜色、圆角、间距、字体完全一致
5. **手势与动画**:
   - 实现下拉刷新 (`easy_refresh`)
   - 实现滚动监听 (如沉浸式 Header)
   - 添加必要的过渡动画

**交付物**:
- `lib/ui/views/xxx/xxx_view.dart`

---

### 阶段 6: 路由注册与集成测试 (Route Registration & Integration)

**目标**: 将新页面集成到主框架并验证功能。

**执行步骤**:
1. **注册路由**:
   - 在 `lib/app/app.dart` 中添加 `MaterialRoute(page: XxxView)`
   - 添加必要的 import 语句
2. **运行代码生成**:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
3. **集成到导航**:
   - 如果是 TabBar 页面，更新 `MainView` 的 `IndexedStack` 和 `BottomNavigationBar`
   - 如果是子页面，确保父页面能正确跳转
4. **功能验证**:
   - 运行 App 到模拟器/真机
   - 验证页面能正常显示
   - 验证所有交互功能正常
   - 验证 Mock 数据能正确加载

**交付物**:
- 更新后的 `lib/app/app.dart`
- 更新后的 `lib/ui/views/main/main_view.dart` (如适用)

---

## 🧪 阶段 7: 单元测试与 Widget 测试 (Unit & Widget Testing)

> 💡 **Skill 支持**: 使用 `flutter-testing` Skill 自动生成测试骨架。
> 参考: `.agent/skills/flutter-testing/SKILL.md`
> 脚本: `./.agent/skills/flutter-testing/scripts/generate_tests.sh`

**目标**: 通过自动化测试确保代码质量和功能稳定性。

**执行步骤**:

### 7.1 ViewModel 单元测试
1. **创建测试文件**:
   - 在 `test/ui/views/xxx/` 目录下创建 `xxx_view_model_test.dart`
2. **测试覆盖范围**:
   - 初始化状态测试 (验证默认值)
   - 业务逻辑测试 (如分类切换、数据加载)
   - 状态变更测试 (验证 `notifyListeners` 被正确调用)
   - 异步操作测试 (使用 `await` 和 `pumpAndSettle`)
3. **Mock 依赖**:
   - 使用 `mockito` 或 `mocktail` Mock Service 层
   - 确保测试隔离，不依赖真实网络请求
4. **示例**:
   ```dart
   test('切换分类应更新 activeCategoryId', () {
     final viewModel = StoreViewModel();
     viewModel.setActiveCategory('parts');
     expect(viewModel.activeCategoryId, 'parts');
   });
   ```

### 7.2 Widget 测试
1. **创建测试文件**:
   - 在 `test/ui/views/xxx/` 目录下创建 `xxx_view_test.dart`
2. **测试覆盖范围**:
   - 页面渲染测试 (验证关键组件存在)
   - 骨架屏测试 (验证 `isBusy` 时显示骨架屏)
   - 交互测试 (如点击按钮、滚动列表)
   - 状态变化测试 (如切换 Tab 后内容更新)
3. **使用 `flutter_test` 工具**:
   - `find.text()` - 查找文本
   - `find.byType()` - 查找组件类型
   - `find.byKey()` - 查找带 Key 的组件
   - `tester.tap()` - 模拟点击
   - `tester.pumpAndSettle()` - 等待动画完成
4. **示例**:
   ```dart
   testWidgets('商城页面应显示搜索栏', (tester) async {
     await tester.pumpWidget(
       MaterialApp(home: StoreView()),
     );
     expect(find.byType(StoreSearchBar), findsOneWidget);
   });
   ```

### 7.3 Service 单元测试 (可选)
1. **测试 Service 方法**:
   - 验证数据解析逻辑
   - 验证错误处理逻辑
2. **Mock HTTP 请求**:
   - 使用 `http_mock_adapter` 或 `nock` 模拟网络响应

### 7.4 运行测试
```bash
# 运行所有测试
flutter test

# 运行特定测试文件
flutter test test/ui/views/store/store_view_model_test.dart

# 生成覆盖率报告
flutter test --coverage
```

**交付物**:
- `test/ui/views/xxx/xxx_view_model_test.dart`
- `test/ui/views/xxx/xxx_view_test.dart`
- 测试覆盖率报告 (可选)

---

## ✅ 阶段 8: 商业级合规检查 (Compliance Audit)

> 💡 **Skill 支持**: 使用 `flutter-ui-compliance` Skill 自动扫描违规项。
> 脚本: `./.agent/skills/flutter-ui-compliance/scripts/scan_violations.sh lib/`

**目标**: 确保代码达到商业可交付标准。

**检查清单**:

### 8.1 代码规范检查 (使用扫描脚本自动检测)
- [ ] 所有颜色使用 `AppColors.xxx` (搜索代码中的 `0xFF` 和 `Color.fromRGBO`)
- [ ] 所有圆角使用 `AppDimensions.radiusXXX` (搜索 `circular(` 后的裸数字)
- [ ] 所有间距使用 `AppDimensions.spaceXXX` (搜索 `EdgeInsets` 和 `SizedBox` 中的裸数字)
- [ ] 所有按钮使用 `BaicBounceButton` 包裹
- [ ] 数字/价格使用机械字体 (`AppStyles.mechanicalData` 或 `AppTypography.priceMain`)

### 7.2 架构规范检查
- [ ] ViewModel 继承自 `BaicBaseViewModel`
- [ ] View 使用 `ViewModelBuilder<T>.reactive()` 或 `StackedView<T>`
- [ ] ViewModel 中无 `BuildContext`, `Navigator` 等 UI 相关代码
- [ ] 导航使用 `MapsTo()` 方法
- [ ] Service 已在 `app.dart` 中注册

### 7.3 文档规范检查 (铁律 10)
- [ ] 所有 Model 字段有中文备注
- [ ] 所有 ViewModel 方法有中文备注
- [ ] 所有 Service 接口有中文备注
- [ ] 所有 Widget 组件有中文备注

### 7.4 异常处理检查 (铁律 5)
- [ ] 所有遇到的错误已记录在 `exception_history.md`
- [ ] 错误模式已识别并归类
- [ ] 重复错误 (≥3次) 已晋升到 `prevention_rules.md`

### 7.5 原型保真度检查
- [ ] 所有文案与原型一致 (未擅自修改)
- [ ] 所有图片 URL 与原型一致
- [ ] 所有 Mock 数据与原型一致
- [ ] 视觉效果与原型像素级一致 (颜色、圆角、间距、字体)

### 7.6 性能与体验检查
- [ ] 骨架屏已实现并在加载时显示
- [ ] 列表使用 `ListView.builder` 或 `GridView.builder` (避免一次性渲染)
- [ ] 图片使用缓存 (`cached_network_image`)
- [ ] 无明显卡顿或性能问题

### 8.7 测试覆盖检查
- [ ] ViewModel 单元测试已编写并通过
- [ ] Widget 测试已编写并通过
- [ ] 测试覆盖率 ≥ 70% (可选但推荐)
- [ ] 所有测试运行无错误 (`flutter test` 通过)

---

## 📦 最终交付物清单

每个页面开发完成后，必须交付以下内容:

1. **代码文件**:
   - `lib/core/models/xxx_model.dart` (如需要)
   - `lib/core/services/xxx_service.dart` (如需要)
   - `lib/ui/views/xxx/xxx_view_model.dart`
   - `lib/ui/views/xxx/xxx_view.dart`
   - `lib/ui/views/xxx/widgets/*.dart` (原子组件)
   - `assets/mock/xxx/*.json` (Mock 数据)

2. **测试文件**:
   - `test/ui/views/xxx/xxx_view_model_test.dart`
   - `test/ui/views/xxx/xxx_view_test.dart`

3. **配置更新**:
   - `lib/app/app.dart` (路由注册)
   - `pubspec.yaml` (如有新增 assets)

4. **文档记录**:
   - `exception_history.md` (异常记录)
   - `task.md` 或 `walkthrough.md` (开发总结，可选)

5. **验证结果**:
   - 编译通过 (无 Error 和 Warning)
   - `build_runner` 成功执行
   - **测试通过** (`flutter test` 无错误)
   - 合规检查清单全部通过

---

## 🚨 常见违规示例与修正

| 违规代码 | 修正代码 | 违反铁律 |
|:--------|:--------|:--------|
| `Color(0xFFFF6B00)` | `AppColors.brandOrange` | 铁律 2 |
| `BorderRadius.circular(24)` | `BorderRadius.circular(AppDimensions.radiusL)` | 铁律 2 |
| `EdgeInsets.all(16)` | `EdgeInsets.all(AppDimensions.spaceM)` | 铁律 2 |
| `GestureDetector(onTap: ...)` | `BaicBounceButton(onTap: ...)` | 铁律 2 |
| `final String id;` (无备注) | `/// 商品唯一标识\nfinal String id;` | 铁律 10 |
| `Navigator.push(context, ...)` | `MapsTo(XxxView)` | 铁律 1 |

---

## 💡 工作流执行示例

假设任务是开发"商城页面 (StoreView)"，执行流程如下:

1. **阶段 1**: 阅读 `prototypes/components/StoreView.tsx`，提取布局、逻辑、数据。
2. **阶段 2**: 创建 `StoreProduct`, `StoreCategory` 等 Model，创建 `StoreService`，配置 `categories.json`。
3. **阶段 3**: 创建 `StoreViewModel`，实现分类切换、商品加载逻辑。
4. **阶段 4**: 开发 `StoreSearchBar`, `StoreBanner`, `ProductCard` 等原子组件。
5. **阶段 5**: 组装 `StoreView`，实现沉浸式滚动效果。
6. **阶段 6**: 在 `app.dart` 注册路由，在 `MainView` 添加 TabBar 入口。
7. **阶段 7**: 编写 `store_view_model_test.dart` 和 `store_view_test.dart`，运行 `flutter test` 验证通过。
8. **阶段 8**: 执行合规检查清单，修正所有违规项，记录异常。

---

**最终目标**: 一次性交付商业级、可维护、像素级还原的 Flutter 页面代码。
