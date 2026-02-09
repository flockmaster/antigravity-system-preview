# Antigravity Agent OS (v2.0) - 可复制的智能开发环境 PRD

## 1. 项目背景与痛点
当前开发模式存在以下核心问题，导致 Agent (我) 无法达到“喝杯茶”的自动化水平：
1.  **失忆 (Statelessness)**: 每次新窗口都是“白纸”，由于缺乏持久化上下文 (Context)，导致需要重复灌输项目背景。
2.  **规则失效 (Rule Dilution)**: `.rules` 和 `.md` 文件过长，导致模型注意力分散，经常忽略“编译后提交”等关键指令。
3.  **执行断裂 (Broken Execution)**: 即使 PRD 已拆解好任务，Agent 仍习惯每做完一步就停下来询问“接下来做什么”，缺乏**自动续航**能力。

## 2. 核心目标
构建一套**独立、可复制、即插即用**的 Agent 操作系统目录 (`.agent_v2/`)。
*   **外部记忆 (External Memory)**: 让 Agent 拥有“长短期记忆”，跨窗口无缝接力。
*   **原子化工作流 (Atomic Workflows)**: 将复杂指令拆解为不可忽略的微步骤。
*   **状态驱动 (State-Driven)**: 开发过程由状态文件驱动，而非仅靠对话驱动。

## 3. 架构设计 (The "Brain" Structure)

这套系统将被封装在一个独立的目录中（如 `antigravity_system_preview/`），您可以直接拷贝到任何新项目中使用。

### 3.1 目录结构预览
```text
antigravity_system_preview/  <-- 可复制的根目录
├── .agent/                  <-- Agent 核心配置
│   ├── memory/              <-- [新增] 外部记忆中枢 (Git 忽略部分内容)
│   │   ├── active_context.md    # [动态] 当前任务状态 (正在做什么？进度？)
│   │   ├── project_decisions.md # [静态] 架构决策记录 (技术栈、规范)
│   │   └── user_preferences.md  # [静态] 用户偏好 (沟通风格、快捷指令)
│   │
│   ├── rules/               <-- [重构] 极简路由规则
│   │   └── router.rule          # 只负责像"交换机"一样分发任务，不写细节
│   │
│   ├── skills/              <-- [优化] 拆解后的微技能
│   │   ├── prd-crater-lite/     # 只负责生成 PRD，不负责执行
│   │   └── code-architect/      # 只负责写代码
│   │
│   └── workflows/           <-- [核心] 自动化流水线
│       ├── boot.md              # 启动脚本：读取 memory -> 恢复状态
│       ├── wrap-up.md           # 收尾脚本：保存状态 -> 生成总结
│       └── feature-flow.md      # 交付脚本：PRD -> Code -> Test -> Commit (全自动)
│
└── README.md                # 使用说明书
```

### 3.2 核心机制详解

#### A. 记忆生命周期管理 (Memory Lifecycle) [重要]
解决"记忆库只增不减变成垃圾场"的问题。
*   **长期记忆 (Long-Term)**:
    *   **入库标准**: 仅限架构决策 (Decision) 和 强制偏好 (Preference)。
    *   **覆盖/遗忘**: 当新规则与旧规则冲突时（如 "改用 Riverpod" vs "使用 Provider"），**新规则自动覆盖旧规则**。旧规则标记 `[Deprecated]`，一周后物理删除。
*   **短期记忆 (Short-Term)**:
    *   **归档机制 (Archive-Link)**: 任务标记为 `DONE` 后，将 `Detailed Plan` 移动到 `.agent/memory/history/task_archive_YYYYMM.md`。
    *   **索引保留**: 在 `active_context.md` 的 `History` 中，保留一行摘要和文件链接：
        `2026-02-08: [Task-001] FSRS Strategy (Details: ./history/task_archive_202602.md#task-001)`
    *   *好处*: 既不占用 Token 窗口，又能随时顺藤摸瓜查历史。

#### B. 配置模板化 (Configuration as Template)
解决"如何适配其他非 Flutter 项目"的问题。
*   **设计原则**: 系统逻辑与技术栈解耦。
*   **实现**: `project_decisions.md` 中预设 `Tech Stack` 变量。
    *   当前默认: `Flutter / Dart / MVVM`
    *   迁移后: 只需手动改为 `Python / Django / MTV`，系统自动调整代码生成策略。

#### B. 工作流引擎 (Workflow Engine)
解决“规则太长不看”的问题。将单一大文件拆解为**步骤**。

*   **旧模式**: 在 Prompt 里写 "写完代码记得编译和提交"。 (容易忘)
*   **新模式 (feature-flow.md)**:
    ```markdown
    Step 1: 调用 prd-crafter 生成需求文档
    Step 2: 用户确认 PRD (Wait for UI input)
    Step 3: 调用 code-architect 生成代码
    Step 4: // turbo (自动执行)
             运行 `flutter analyze`
    Step 5: // turbo (自动执行)
             运行 `flutter test`
    Step 6: // turbo (自动执行)
             运行 `git add . && git commit -m "feat: ..."`
    ```
    *   *效果*：Step 6 是必须执行的独立步骤，我无法跳过。

#### D. 任务链自动化 (Task Chaining) [新增]
解决“做一半停下来问我”的问题。
*   **启动 (Click-to-Work)**: 不再需要手动输入 `/boot`。
    *   **规则**: 在 `.agent/rules/router.rule` 中定义：任何新 Session 的第一个回应前，**必须先读取** `active_context.md`。
*   **效果**: 您只需说 "继续" 或 "早"，我就能自动接上昨天的进度。工作流执行完毕后，触发 `auto-next` 检查器。
    3.  检查器读取 PRD，如果发现 Task 1 已完成且 Task 2 状态为 Pending，**自动加载 Task 2 上下文并开始执行**。
*   **无限续航条件 (Infinite Loop)**:
    *   只要 **`flutter analyze` 无报错** 且 **`flutter test` 通过** -> 自动提交代码 -> **自动拉取下一个 Pending 任务**。
    *   不做数量限制（3个任务暂停已废除），直到 PRD 中所有 P0/P1 任务全部完成。
*   **错误处理与自动修复 (Auto-Fix Loop)**:
    *   **遇到错误时**: 不立即暂停。
    *   **执行循环**: 
        1.  读取错误日志 (`flutter analyze` 或 `flutter test` 输出)。
        2.  调用 `diff-analyzer` 分析原因。
        3.  尝试修复代码。
        4.  重新运行验证。
    *   **最大尝试次数**: 针对同一个 Task，允许自动修复 **3次**。
*   **真正的熔断 (True Circuit Breaker)**:
    *   **修复 3 次后仍失败** -> 此时视为"超出能力边界"，暂停并请求人工介入。
    *   **环境级崩溃** (如 SDK 缺失、磁盘满) -> 立即暂停。

#### E. 需求澄清门禁 (Ambiguity Check Gate) [新增]
防止盲目开发导致的返工。
*   **触发时机**: 
    1.  用户输入初步需求后，生成正式 PRD **之前**。
    2.  任务执行过程中，遇到未定义的边界情况时。
*   **检测逻辑**:
    *   **参数缺失**: 用户说"加个列表"，但未说数据源、分页方式 -> **强制提问**。
    *   **逻辑冲突**: 新需求与 `project_decisions.md` (如架构规范) 冲突 -> **强制提问**。
*   **交互原则**: 
    *   Agent 必须输出 *"我对以下 N 点存在疑问..."*
    *   **只有当用户回答并消除歧义后，才允许进入 PRD 生成阶段或代码执行阶段。**

## 4. 交互流程演示

### 场景：通用功能开发 (如：用户登录模块) - 全自动模式

1.  **User**: (打开新窗口，输入任意内容，如 "开始" 或 "继续")
2.  **Agent**: (后台自动执行 `boot` 逻辑，无需用户输入指令)
    *   "检测到上下文... `login_module_prd.md` 中有 5 个待办任务。"
    *   "是否开启**自动续航模式**？"
3.  **User**: "是，去喝茶了。"
4.  **Agent**: (无需用户再次确认)
    *   **Exec Task 1**: 实现数据层 (Repository/API)... -> 编译通过 -> 提交。
    *   *(自动判定 Task 1 完成)*
    *   **Exec Task 2**: 实现业务逻辑 (ViewModel/Bloc)... -> 编译通过 -> 提交。
    *   *(自动判定 Task 2 完成)*
    *   **Exec Task 3**: 实现 UI 界面... -> **报错！**
    *   *(触发安全阀)*
    *   **Agent**: "老板，Task 3 遇到构建错误，自动修复 3 次后仍失败。请指示。"
5.  **User**: (回来查看) "哦，这里引用的 Widget 参数传错了..."

## 5. 配置与迁移策略 (Configuration & Migration)
在构建系统骨架时，将执行以下迁移策略：
1.  **数据迁移**: 扫描当前项目的 Rules/Instructions，提取沟通风格、架构模式等偏好，**预填入** 新系统的 `user_preferences.md`。
2.  **通用性设计**: `workflows/feature-flow.md` 中不写死 `flutter run`，而是调用变量 `${RUN_COMMAND}` (由 `project_decisions.md` 定义)。
    *   *好处*: 拷贝到新项目，改一下配置文件就能用。

---
请审阅以上 PRD。确认无误后，我将开始在 `antigravity_system_preview` 目录下**构建这套系统的骨架**。
