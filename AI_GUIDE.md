# AI 驱动的 Flutter 高效开发项目模版交付指南
> **目标**: 本文档旨在帮助零 AI 编程经验的开发者，通过本项目模版，从 0 到 1 完成高质量 Flutter 社交/电商类应用的开发。

---

## 1. 为什么选择此模版？
本模版不仅是代码的集合，更是一套**嵌入了 AI 协作逻辑的生产力系统**。它通过 `.rules`（铁律文件）和 `.agent/workflows`（标准作业程序）将资深架构师的经验固化。

- **核心价值**: 消除 AI 的“不确定性”，让 AI 在严格的架构约束下输出 100% 可用的代码。

---

## 2. 核心基建与工具链

### 2.1 AI 编程工具的选择
本项目在 **Antigravity** 环境下构建，但也支持主流 AI IDE：
- **Kiro (Google Internal)**: 最强上下文理解，尤其在处理 Flutter 窗口联动和实时渲染时优势明显。
  - **Rules 生效**: Kiro 默认自动读取根目录下的 `.rules` 或 `.agent/config`。
- **Cursor**: 
  - **Rules 生效 (全局)**: 进入 `Settings -> Rules for AI`，将 `.rules` 的内容粘贴进去。
  - **Rules 生效 (项目级)**: 在项目根目录创建 `.cursorrules` 文件，并将 `.rules` 内容复制进去，Cursor 会在每次对话中自动加载。
- **Windsurf**:
  - **Rules 生效**: 在项目根目录创建 `.windsurfrules` 即可。
- **自定义配置 (重要)**: 
  - 如果使用的工具不支持自动加载，**首轮对话的提示词**必须包含：“请先读取项目根目录的 `.rules` 文件，它是你后续所有行为的终极铁律。在同意这些规则之前，请不要开始编写代码。”

### 2.2 模型能力与分工
在开发过程中，建议根据任务类型灵活切换模型：
- **Gemini 3.0 (Latest)**:
  - **优势**: **极强的多模态解析（支持超长视频/截图解析）**、**UI 视觉像素级还原**、**Flutter 代码性能优化**。
  - **适用场景**: **根据设计稿截图生成原型**、处理超大上下文任务、复杂的 3D 渲染适配。
- **Claude 4.5**:
  - **优势**: **逻辑推导的顶峰**、**语义理解极其精准**、**代码生成的错误率极低**。
  - **适用场景**: 核心业务架构设计、高难度的 Bug 诊断、精细化的逻辑重构。

---

## 3. 产品原型：从 AI Studio 开始 (0-1 第一步)

要实现像素级还原，第一步是在 **Google AI Studio** 上生成高保真 React 原型。

### 3.1 提示词策略（角色扮演模式）

#### 场景 A：从零开始构思页面
> “你现在是一名**资深 UI 设计师和产品专家**，请为我设计一个[XX 业务]的 App 页面。使用 React + TailwindCSS + Lucide Icons。要求：背景采用柔和科技感，间距遵循 8px 网格。”

#### 场景 B：根据参考图/手绘稿生成 (强烈推荐)
> **操作**: 在 AI Studio 中上传你心仪的 App 截图或手绘线框图。
> **提示词**: “你是一名**像素级还原专家**，请分析这张截图的布局、色彩、图标及交互逻辑，并将其转化为一个完整的、可运行的 React + Tailwind 组件代码。请确保间距和字体比例与截图保持高度一致。”

### 3.2 交付模版同步
生成原型代码后，将其放入 `prototypes/` 目录。使用内置脚本管理：
- **运行前准备**: 
  1. 确保已安装 git 环境。
  2. 编辑 `scripts/config.sh`，将 `PROTOTYPE_REPO_URL` 修改为您存放原型的实际 GitHub 仓库地址。
  3. 执行 `chmod +x scripts/*.sh` 赋予脚本运行权限。
- **同步指令**: 执行 `./scripts/sync_prototypes.sh`。AI 将以这些代码为“唯一真理来源”进行 Flutter 转换。

---

## 4. 任务规划：如何驾驭大任务 (Task Management)

在 AI Coding 中，**“拆解”是比“编写”更重要的能力**。

### 4.1 任务拆解与引导
不要一次性让 AI “写一个商城模块”，这会导致逻辑混乱。
1. **启动指令**: “我需要开发一个商城模块，请先不要写代码。请你以**技术负责人**的身份，帮我列出这个模块的任务清单，并按照依赖关系进行排序。”
2. **确认分解**: 审查 AI 拆出的子任务（如：数据模型定义 -> 接口 Mock -> 列表 UI -> 详情跳转）。
3. **监控进度**: 每次完成一个子任务，要求 AI 更新进度说明。

### 4.2 开发建议：小碎步前进 (Step-by-Step)
- **拒绝盲信**: AI 的每一次“完成”都只是它眼中的完成。**每个子任务完成后，必须先进行人工验证/预览运行**。
- **微步迭代**: 宁愿分 10 次提交，也不要让 AI 一次修改 20 个文件。
- **人工复核**: 关键逻辑（如支付、权限）务必逐行 Review。

---

## 5. 与 AI 协作的艺术：角色扮演与提示词

### 5.1 角色扮演的重要性
单向的指令往往导致平庸的代码。通过**多重角色扮演**，可以显著提升 AI 的产出密度：
- **产品经理模式**: “请站在产品经理的角度，分析这个登录流程是否会导致用户流失，并给出优化建议。”
- **前端架构师模式**: “请以架构师身份，检查我的 `BaicBaseViewModel` 是否存在过度耦合，并进行优雅重构。”

### 4.2 关键环节的提示词 (MVP)
- **原型转代码**: `/prototype-to-code [文件名]`
- **处理编译错误**: `/analyze-error [错误日志]`
- **新功能开启前**: “请先读取 `.rules` 和 `PROJECT_SPECIFICATIONS.md`，确保你完全理解我们的视觉规范和架构铁律，然后再开始。”

---

## 5. 模版迁移：从 Flutter 到一切

本模版的“灵魂”是其**管理哲学**（先同步、后记录、再修复）。你可以通过“模版转换提示词”将其平滑迁移到其他技术栈（如 iOS Swift 或 React Native）：

**迁移提示词示例：**
> “我有一套非常成熟的 Flutter 项目开发规范模版（主要包含铁律、原型同步脚本、AI 工作流、异常晋升机制）。现在我需要开发一个 **Native iOS (Swift + SwiftUI)** 项目，请你保留这套管理逻辑，将其中的 Dart 代码、MVVM 约束和目录结构，平滑转换为 Swift 版本对应的工程模版。”

---

## 6. Skills 自动化能力

本模版内置 **5 个 Skills**，提供可执行的自动化能力，与 Workflows 协作使用。

### 6.1 Skills 列表

| Skill | 用途 | 调用脚本 |
|-------|------|---------|
| `flutter-ui-compliance` | 扫描硬编码颜色/圆角/间距违规 | `./scan_violations.sh lib/` |
| `flutter-architecture` | 一键生成 Feature 骨架代码 | `./generate_feature.sh <name>` |
| `prototype-analyzer` | 解析 React 原型，提取结构 | 手动参考 SKILL.md |
| `flutter-testing` | 自动生成测试骨架 | `./generate_tests.sh <file>` |
| `exception-guardian` | 错误模式匹配，Step 0 强制 | 自动触发 |

### 6.2 Skills 与 Workflows 的关系

```
Workflows = 定义"做什么" (步骤指引)
Skills    = 提供"怎么做" (执行能力)
```

**示例**: `/prototype-to-code` 工作流在各阶段调用相应 Skills：
- 阶段 1 → `prototype-analyzer` 解析原型
- 阶段 4 → `flutter-ui-compliance` 校验视觉规范
- 阶段 7 → `flutter-testing` 生成测试骨架
- 阶段 8 → `flutter-ui-compliance` 扫描违规项

### 6.3 Skills 目录

```
.agent/skills/
├── flutter-ui-compliance/    # UI 规范守护
├── flutter-architecture/     # 架构自动化
├── prototype-analyzer/       # 原型智能解析
├── flutter-testing/          # 测试自动化
└── exception-guardian/       # 异常守护者
```

每个 Skill 包含 `SKILL.md` (核心指令) 和 `scripts/`/`resources/` (可执行资源)。

---

## 7. 开发者致辞：给 AI Coding 新手的建议

1. **不要轻易妥协**: 如果 AI 给出的 UI 与原型有 1 像素的偏差，请指出它，引用 `app_dimensions.dart` 强制它修正。
2. **疑问即停顿**: 养成习惯，凡是 AI 说“我不确定”或逻辑模糊时，不要点头，要提问。
3. **维护 exception_history.md**: 这是你送给未来自己的礼物。记录一次错误，胜过修十次 Bug。
4. **善用 Skills**: 利用内置的 Skills 自动化能力，减少重复劳动，提升交付质量。

---
*Powered by Antigravity AI Team*
