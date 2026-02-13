---
title: Existing Word Assistant Codebase Analysis
category: Architecture
tags: [flutter, stacked, mvvm, word_assistant]
last_updated: 2026-02-09
---

# Existing codebase Analysis (`word_assistant`)

## 1. 核心架构 (Core Architecture)
项目采用 **Stacked (MVVM)** 模式，具有清晰的职责分离。

### 目录结构 (Directory Structure)
- `lib/app`:
  - `app.locator.dart`: GetIt 服务定位器。
  - `app.router.dart`: Stacked 自动生成的路由映射。
  - `car_owner_app.dart`: App 根 Widget。
- `lib/core`:
  - `models/`: 数据模型（如 `Word`, `User`, `LearningRecord`）。
  - `services/`: 业务逻辑服务（`DatabaseService`, `UserService`, `GeminiService` 等）。
  - `theme/`: 全局设计系统，定义配色、间距和字体。
- `lib/ui`:
  - `views/`: 各个页面的 UI 和对应的 ViewModel。
  - `widgets/`: 复用性 UI 组件。

## 2. 关键技术点 (Key Technical Points)
- **依赖注入**: 使用 `injectable` 自动生成服务绑定。
- **本地存储**: `sqflite` 作为核心数据库，存储单词表和学习进度。
- **AI 赋能**: 集成了 `google_generative_ai` (Gemini)，推测用于例句生成、语法分析或智能排期。
- **遗忘曲线**: `DatabaseService` 中包含 `refreshDailyScores` 逻辑，表明项目具备基于遗忘曲线的复习机制（可能类似 FSRS 或 Anki）。
- **跨平台适配**: 代码中存在对 HarmonyOS 的屏蔽或适配注释（如 `sherpa_onnx` 建议）。

## 3. 迭代优化点 (Optimization Insights)
本项目作为英文背单词工具的基石，未来的迭代重点在于：
- **算法精进**: 优化遗忘曲线排期（如引入更精准的 FSRS 参数权重）。
- **内容深度**: 利用 Gemini 实时生成更具语境的英文例句、词源故事或同义词辨析。
- **体验升级**: 优化 TTS 发音质量，增强用户学习闭环。

## 4. 自动化开发流
- 遵循 `stacked` 架构规范进行 Feature 开发。
- 利用 AI 能力辅助生成高质量的学习内容。
