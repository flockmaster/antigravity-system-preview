---
description: 创建新功能模块的标准工作流
---

# 🚀 创建新功能模块工作流 (Create Feature Workflow)

> **用途**: 当需要创建一个新的功能模块（包含 View、ViewModel、Service 等）时，使用此工作流确保结构规范、命名一致。

---

## ✅ Step 1: 确认需求和位置

**[强制]** 在创建任何文件前，必须明确以下信息：

1. **功能名称**: 使用小写下划线命名法，如 `user_profile`, `order_detail`
2. **所属模块**: 确定放置在 `lib/ui/views/` 下的哪个目录
3. **是否需要 Service**: 如果有 API 调用，需要创建对应的 Service

**[示例对话]**:
```
用户: 我需要创建一个用户资料页面
AI: 好的，我将创建以下结构：
- 功能名称: user_profile
- 位置: lib/ui/views/user/user_profile/
- 需要 Service: 是 (UserProfileService)
```

---

## ✅ Step 2: 读取模板文件

**[强制前置]** 在编写任何代码前，必须先读取以下模板：

```
1. templates/viewmodel_template.dart
2. templates/view_template.dart
3. templates/service_template.dart (如需要)
4. templates/model_template.dart (如需要)
```

**[自检问题]**: "我是否已经阅读了所有相关模板？"

---

## ✅ Step 3: 创建目录结构

按照以下结构创建目录和文件：

```
lib/ui/views/[category]/[feature_name]/
├── [feature_name]_view.dart          # 视图层
├── [feature_name]_viewmodel.dart     # 业务逻辑层
└── widgets/                          # (可选) 私有组件
    └── [widget_name].dart
```

**[如需 Service]**:
```
lib/core/services/
└── [feature_name]_service.dart
```

**[如需 Model]**:
```
lib/core/models/
└── [model_name].dart
```

---

## ✅ Step 4: 创建 ViewModel

**[强制规则]**:
1. 必须继承 `BaicBaseViewModel` (铁律 #1)
2. 必须包含完整的中文备注 (铁律 #10)
3. 导航必须使用 `MapsTo()` 和 `goBack()` (铁律 #1)

**[创建文件]**: `[feature_name]_viewmodel.dart`

```dart
import '../../../../core/base/baic_base_view_model.dart';
import '../../../../app/app.locator.dart';
// import '../../../../app/app.router.dart';

/// [FeatureNameViewModel] - [功能描述]
/// 
/// 职责: [说明此 ViewModel 负责的业务逻辑]
class FeatureNameViewModel extends BaicBaseViewModel {
  // ... 参考 viewmodel_template.dart
}
```

---

## ✅ Step 5: 创建 View

**[强制规则]**:
1. 必须使用 `ViewModelBuilder<T>.reactive()` (铁律 #1)
2. 严禁硬编码颜色/圆角/间距 (铁律 #2)
3. 可点击元素必须使用 `BaicBounceButton` (规范 4.1)
4. 加载状态必须使用骨架屏 (规范 4.4)

**[创建文件]**: `[feature_name]_view.dart`

```dart
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/components/baic_ui_kit.dart';
import '[feature_name]_viewmodel.dart';

/// [FeatureNameView] - [功能描述]
class FeatureNameView extends StatelessWidget {
  // ... 参考 view_template.dart
}
```

---

## ✅ Step 6: 创建 Service (如需要)

**[强制规则]**:
1. 所有 API 调用必须通过 `ApiClient` (铁律 #7)
2. 禁止在 Service 中包含 Mock 逻辑 (铁律 #7)

**[创建文件]**: `lib/core/services/[feature_name]_service.dart`

---

## ✅ Step 7: 注册路由

在 `lib/app/app.dart` 中添加路由配置：

```dart
// 在 @StackedApp 的 routes 中添加:
MaterialRoute(page: FeatureNameView),
```

然后运行代码生成：

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## ✅ Step 8: 注册 Service (如需要)

在 `lib/app/app.locator.dart` 中注册 Service：

```dart
locator.registerLazySingleton<FeatureNameService>(() => FeatureNameService());
```

---

## ✅ Step 9: 创建 Mock 数据 (可选)

如果需要 Mock 数据，在 `assets/mock/` 目录下创建对应的 JSON 文件：

```
assets/mock/[api_path].json
```

---

## 📋 完成检查清单

创建完成后，确认以下事项：

- [ ] ViewModel 继承自 `BaicBaseViewModel`
- [ ] View 使用 `ViewModelBuilder.reactive()`
- [ ] 所有颜色使用 `AppColors.xxx`
- [ ] 所有圆角使用 `AppDimensions.radiusXXX`
- [ ] 所有间距使用 `AppDimensions.spaceXXX`
- [ ] 可点击元素使用 `BaicBounceButton`
- [ ] 包含完整的中文备注
- [ ] 导航使用 `MapsTo()` 和 `goBack()`
- [ ] API 调用通过 `ApiClient`
- [ ] 路由已注册
- [ ] `flutter analyze` 无报错

---

## 🎯 显性调用指令

用户输入 `/create-feature [功能名]` 时，执行此工作流。

**[示例]**:
```
/create-feature user_profile
/create-feature order_list
/create-feature product_detail
```
