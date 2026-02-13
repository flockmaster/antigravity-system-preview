---
name: prototype-analyzer
description: 解析 React 原型文件，提取组件结构、样式映射，辅助生成 Flutter 骨架代码
---

# 原型智能解析器 (Prototype Analyzer)

> **触发场景**: 执行 `/prototype-to-code` 工作流的阶段 1，或用户提供 React 原型文件时

## 核心能力

1. **结构提取** - 解析 React 组件的 JSX 结构，输出组件层级树
2. **样式映射** - 识别 Tailwind 类并转换为 Flutter 设计系统引用
3. **数据识别** - 提取 useState、Mock 数据结构，生成对应的 Model 骨架

---

## 解析流程

### Step 1: 组件结构提取

**输入**: React 组件文件 (如 `StoreView.tsx`)

**提取项**:
```yaml
component:
  name: StoreView
  type: functional  # functional | class
  children:
    - type: header
      tailwind: "flex items-center justify-between p-4 bg-white"
      flutter: "Container + Row"
    - type: scrollview
      tailwind: "overflow-y-scroll"
      flutter: "CustomScrollView"
      children:
        - type: banner
          tailwind: "rounded-2xl p-6 bg-orange-500"
          flutter: "Container (borderRadius: AppDimensions.radiusL)"
```

### Step 2: 状态提取

识别 React Hooks 并映射到 ViewModel:

| React Hook | Flutter ViewModel |
|------------|-------------------|
| `useState('value')` | `String _var; String get var => _var;` |
| `useState([])` | `List<T> _items; List<T> get items => _items;` |
| `useState(false)` | `bool _flag; bool get flag => _flag;` |
| `useEffect(() => fetch())` | `Future<void> initialise() async { }` |

### Step 3: 事件处理提取

| React | Flutter ViewModel |
|-------|-------------------|
| `onClick={() => setActive(id)}` | `void setActive(String id) { _activeId = id; rebuildUi(); }` |
| `onScroll={(e) => handleScroll(e)}` | 在 View 中使用 ScrollController |

---

## Tailwind → Flutter 快速映射

参考 `flutter-ui-compliance/resources/tailwind_flutter_map.yaml` 完整映射表。

### 常用布局

```
flex flex-col → Column
flex flex-row → Row
flex items-center → Row(crossAxisAlignment: CrossAxisAlignment.center)
flex justify-between → Row(mainAxisAlignment: MainAxisAlignment.spaceBetween)
gap-4 → 每个子组件间加 SizedBox(height/width: AppDimensions.spaceM)
```

### 常用容器

```
p-4 bg-white rounded-xl shadow-lg →
Container(
  padding: EdgeInsets.all(AppDimensions.spaceM),
  decoration: BoxDecoration(
    color: AppColors.bgSurface,
    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
    boxShadow: [AppShadows.shadowL2],
  ),
)
```

---

## 输出格式

解析完成后，AI 应输出结构化分析:

```markdown
## 📊 原型解析结果

### 组件层级
- StoreView (页面根组件)
  - Header (固定顶部)
  - CustomScrollView
    - Banner (促销横幅)
    - CategoryTabs (分类标签)
    - ProductGrid (商品网格)

### 状态映射
| React State | ViewModel Field |
|-------------|-----------------|
| `isScrolled` | `bool _isScrolled` |
| `activeCategory` | `String _activeCategoryId` |
| `products` | `List<StoreProduct> _products` |

### 待创建文件
- lib/ui/views/store/store_view.dart
- lib/ui/views/store/store_viewmodel.dart
- lib/ui/views/store/widgets/store_banner.dart
- lib/core/models/store_product.dart
```

---

## 触发时机

1. **工作流集成**: `/prototype-to-code` 阶段 1 自动调用
2. **手动触发**: 用户说 "分析原型" 或提供 .tsx/.jsx 文件
3. **原型目录**: 自动扫描 `prototypes/` 目录下的相关文件

---

## 资源文件

- [React → Flutter 转换规则](resources/react_to_flutter.yaml)
