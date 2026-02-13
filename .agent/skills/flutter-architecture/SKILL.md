---
name: flutter-architecture
description: 一键生成符合 MVVM 架构规范的 Feature 模块骨架代码，自动校验架构合规性
---

# Flutter 架构自动化 (Architecture Automation)

> **触发场景**: 当用户请求创建新功能模块，或需要校验现有代码架构时

## 核心能力

1. **骨架生成** - 一键生成 View + ViewModel + Service + widgets/ 完整结构
2. **架构校验** - 检测 ViewModel 继承、View 构建方式、导航调用合规性
3. **模板对齐** - 确保生成的代码与 `templates/` 目录下的模板保持一致

---

## 骨架生成规则

### 目录结构

输入功能名 `user_profile`，生成以下结构:

```
lib/ui/views/[category]/user_profile/
├── user_profile_view.dart          # 视图层
├── user_profile_viewmodel.dart     # 业务逻辑层
└── widgets/                        # 私有组件目录
    └── .gitkeep

lib/core/services/
└── user_profile_service.dart       # (可选) 服务层
```

### 命名规范

| 输入 | 文件名 | 类名 |
|-----|-------|-----|
| `user_profile` | `user_profile_view.dart` | `UserProfileView` |
| `order_detail` | `order_detail_view.dart` | `OrderDetailView` |
| `store` | `store_view.dart` | `StoreView` |

---

## 架构校验规则 (铁律 1)

### 🔴 ViewModel 继承检查

**必须**: 所有 ViewModel 必须继承 `BaicBaseViewModel`

```dart
// ✅ 正确
class UserProfileViewModel extends BaicBaseViewModel { }

// ❌ 违规
class UserProfileViewModel extends ChangeNotifier { }
class UserProfileViewModel { }  // 无继承
```

### 🔴 View 构建方式检查

**必须**: 使用 `ViewModelBuilder<T>.reactive()` 或 `StackedView<T>`

```dart
// ✅ 正确
ViewModelBuilder<UserProfileViewModel>.reactive(
  builder: (context, viewModel, child) => ...
)

// ❌ 违规
StatefulWidget + setState()
Consumer<ViewModel>()
```

### 🔴 导航合规检查

**必须**: 使用 `MapsTo()` 和 `goBack()` 进行导航

```dart
// ✅ 正确
await MapsTo(Routes.detailView);
goBack();

// ❌ 违规
Navigator.of(context).push(...)
Navigator.pop(context)
context.go(...)
```

### 🔴 UI 隔离检查

**禁止**: ViewModel 中出现以下内容:

- `BuildContext`
- `Navigator`
- `showDialog`
- `ScaffoldMessenger`
- `MaterialApp` / `CupertinoApp`

---

## 脚本调用

### 生成 Feature 骨架
```bash
./.agent/skills/flutter-architecture/scripts/generate_feature.sh <feature_name> [category]

# 示例
./generate_feature.sh user_profile user      # 生成到 lib/ui/views/user/user_profile/
./generate_feature.sh order_detail order     # 生成到 lib/ui/views/order/order_detail/
```

### 校验架构合规性
```bash
./.agent/skills/flutter-architecture/scripts/validate_architecture.sh lib/

# 输出示例
🔍 扫描 ViewModel 继承...
✅ lib/ui/views/home/home_viewmodel.dart - 继承正确
❌ lib/ui/views/test/test_viewmodel.dart - 未继承 BaicBaseViewModel
```

---

## 模板文件引用

生成代码前，必须参考以下模板:

1. `templates/viewmodel_template.dart` - ViewModel 标准结构
2. `templates/view_template.dart` - View 标准结构  
3. `templates/service_template.dart` - Service 标准结构
4. `templates/model_template.dart` - Model 标准结构

---

## 工作流集成

此 Skill 在以下工作流中被调用:

- `/create-feature` - Step 3-6 调用骨架生成
- `/prototype-to-code` - 阶段 2-5 参考架构规范

---

## 检查清单 (AI 自检)

创建新 Feature 时，AI 必须确认:

- [ ] ViewModel 是否继承 `BaicBaseViewModel`？
- [ ] View 是否使用 `ViewModelBuilder.reactive()`？
- [ ] 导航是否使用 `MapsTo()` / `goBack()`？
- [ ] ViewModel 中是否无 `BuildContext`？
- [ ] 是否已在 `app.dart` 注册路由？
- [ ] 中文备注是否完整？
