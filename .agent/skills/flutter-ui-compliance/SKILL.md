---
name: flutter-ui-compliance
description: 扫描并检测 Flutter 代码中的视觉规范违规项（硬编码颜色、圆角、间距），确保 UI 代码符合设计系统规范
---

# Flutter UI 规范守护 (UI Compliance Guardian)

> **触发场景**: 当 AI 完成 UI 代码编写后，或用户请求检查代码规范时自动触发

## 核心能力

1. **扫描硬编码违规** - 检测 `Color(0xFF...)`, `BorderRadius.circular(数字)`, `EdgeInsets.all(数字)` 等违规代码
2. **提供修复建议** - 根据违规类型给出正确的 AppColors/AppDimensions 替换方案
3. **Tailwind 映射** - 将原型中的 Tailwind CSS 类转换为 Flutter 设计系统引用

---

## 自动扫描规则

### 🔴 硬编码颜色 (铁律 2 - 零容忍)

**检测模式**:
```regex
Color\(0x[0-9A-Fa-f]{8}\)
Color\.fromRGBO\(
Color\.fromARGB\(
Colors\.[a-z]+
```

**唯一合法来源**: `AppColors.xxx`

**常见违规 → 修复映射**:
| 违规代码 | 修复为 |
|---------|-------|
| `Color(0xFFFF6B00)` | `AppColors.brandOrange` |
| `Color(0xFF111827)` | `AppColors.textTitle` |
| `Color(0xFFFFFFFF)` | `AppColors.bgSurface` |
| `Colors.white` | `AppColors.bgSurface` |
| `Colors.black` | `AppColors.textTitle` |
| `Colors.grey` | `AppColors.textSecondary` |

### 🔴 硬编码圆角 (铁律 2)

**检测模式**:
```regex
BorderRadius\.circular\(\d+
Radius\.circular\(\d+
```

**唯一合法来源**: `AppDimensions.radiusXS/S/M/L/Full`

**修复映射**:
| 原始值 | 修复为 |
|-------|-------|
| `circular(4)` | `AppDimensions.radiusXS` |
| `circular(8)` | `AppDimensions.radiusS` |
| `circular(12)` | `AppDimensions.radiusM` |
| `circular(16)` | `AppDimensions.radiusL` |
| `circular(24)` | `AppDimensions.radiusL` |
| `circular(999)` | `AppDimensions.radiusFull` |

### 🔴 硬编码间距 (铁律 2)

**检测模式**:
```regex
EdgeInsets\.all\(\d+
EdgeInsets\.symmetric\(.*\d+
SizedBox\(height:\s*\d+
SizedBox\(width:\s*\d+
```

**唯一合法来源**: `AppDimensions.spaceXS/S/M/ML/L/XL/XXL`

**修复映射**:
| 原始值 | 修复为 |
|-------|-------|
| `4` | `AppDimensions.spaceXS` |
| `8` | `AppDimensions.spaceS` |
| `12` | `AppDimensions.spaceML` (或 M) |
| `16` | `AppDimensions.spaceM` |
| `24` | `AppDimensions.spaceL` |
| `32` | `AppDimensions.spaceXL` |
| `48` | `AppDimensions.spaceXXL` |

---

## 脚本调用

### 扫描项目违规项
```bash
./.agent/skills/flutter-ui-compliance/scripts/scan_violations.sh lib/
```

**输出格式**:
```
🔴 发现 X 个违规项:

[颜色违规] lib/ui/views/home/home_view.dart:42
  违规: Color(0xFFFF6B00)
  建议: AppColors.brandOrange

[圆角违规] lib/ui/views/store/store_view.dart:128
  违规: BorderRadius.circular(24)
  建议: BorderRadius.circular(AppDimensions.radiusL)
```

---

## 触发时机

1. **自动触发**: 完成任何 UI 代码编写后
2. **手动触发**: 用户说 "检查 UI 规范" 或 "扫描违规"
3. **工作流集成**: `/prototype-to-code` 的阶段 8 (合规检查) 自动调用

---

## 资源文件

- [Tailwind → Flutter 映射表](resources/tailwind_flutter_map.yaml)

---

## 检查清单 (AI 自检)

每次编写 UI 代码后，AI 必须自问:

- [ ] 代码中是否存在 `0xFF` 或 `Color.fromRGBO`？
- [ ] 代码中是否存在 `circular(数字)`？
- [ ] 代码中是否存在 `EdgeInsets.all(数字)` 且数字非 0？
- [ ] 是否有遗漏导入 `AppColors` 或 `AppDimensions`？

如有违规，必须立即修复后再提交。
