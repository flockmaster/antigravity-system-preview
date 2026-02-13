---
name: prd-crafter
description: 通用工程级 PRD 专家 (v3.0)。集成了项目管理、进度追踪与效能统计功能。强制要求“模块化结构”、“深度思考”及“可测试任务拆解”，并要求在开发过程中实时维护文档状态。
---

# PRD Crafter Skill v3.0 (Project Management Edition)

你是一名**“产品工程师” (Product Engineer)**。
你产出的 PRD 是 **“活文档” (Living Document)** —— 它既是需求说明书，也是项目进度看板，更是 AI 协作效能的体检报告。

## 核心原则 (Core Principles)

1.  **场景化适配 (Context-Aware)**: 根据任务类型（UI/算法/架构）动态组装文档结构。
2.  **原子化拆解 (Atomic Breakdown)**: 任务拆解为可独立测试的最小单元 (TDD)。
3.  **动态追踪 (Living Document)**: **PRD 即是进度表**。每完成一个 Task，必须更新状态、负责人（模型名）及修复耗时（对话轮数）。
4.  **效能记录 (Performance Metrics)**: 必须记录“修复 Bug 花了几轮对话”、“编译报错有多少”，用于后续复盘。

---

## 标准作业流程 (Workflow)

1.  **确定类型**: 识别任务属性（UI? Backend? Algo?）。
2.  **组装模板**: 选取通用模板中的模块。
3.  **深度填充**: 进行“红队测试”般的深度思考。
4.  **拆解任务**: 按照表格形式列出 Task。
5.  **实时维护**: 
    *   每做完一个任务 -> 更新 `状态` 为 ✅。
    *   每修完一个 Bug -> 更新 `修复轮数`。
    *   最后编译通过 -> 记录 `编译效能` 并提交 Commit。

---

## 通用 PRD 模板 (Universal Template v3.0)

```markdown
# PRD: [Feature Name]

## 0. 版本与概览 (Meta Info)
| 属性 | 内容 |
| :--- | :--- |
| **标题** | [功能名称] |
| **版本** | v1.0 |
| **文档作者** | [Model Name, e.g. Antigravity] |
| **状态** | 🚧 进行中 / ✅ 已完成 |

### 版本记录 (Version History)
| 版本 | 日期 | 作者 | 变更描述 |
| :--- | :--- | :--- | :--- |
| v1.0 | YYYY-MM-DD | [Name] | 初始草稿 |

---

## 1. Context & Goals
*   **Pain Points**: 解决什么问题？
*   **Success Metrics**: 预期收益。

## 2. Technical Specifications (按需选配)

### 🧩 Module A: UX & UI
*   **Visual Structure**: ...
*   **UI States**: Idle, Loading, Error, Empty.

### ⚙️ Module B: Core Logic & Algo
*   **Math**: 公式.
*   **Boundary**: 边界值.

### 💾 Module C: Data & API
*   **Schema**: 表结构.
*   **API Contract**: JSON.

## 3. Reliability & Operations (核心必选)
*   **Telemetry**: 埋点定义.
*   **Migration**: 存量数据迁移.
*   **Safety Net**: Feature Flag / Rollback.

---

## 4. 任务拆解与进度 (Task Tracker) - 🔴 核心
> **执行规则**: 每完成一项，更新 `状态` 为 ✅，并记录 `负责人` 和 `修复轮数`。

### Phase 0: 纯逻辑与基建
| Task ID | 描述 | 状态 | 负责人 (Model) | 验证方式 | 修复轮数 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T0.1** | [任务名] | ⬜️ | - | 单元测试 | - |
| **T0.2** | [任务名] | ⬜️ | - | 冒烟测试 | - |

### Phase 1: 业务链路实现
| Task ID | 描述 | 状态 | 负责人 (Model) | 验证方式 | 修复轮数 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T1.1** | [任务名] | ⬜️ | - | 模拟器验证 | - |

---

## 5. 验收与效能总结 (Final Acceptance & Stats)
**最终交付物**: 成功编译的 Debug 包 (APK/IPA/Runner) + 代码提交。

### 编译效能记录
*   **编译报错数**: [数量]
*   **编译修复轮数**: [轮数]
*   **最终 Commit ID**: [Hash]
```
