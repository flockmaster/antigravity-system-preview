---
project_name: Word Assistant (English Learning Tool)
last_updated: 2026-02-09
---

# Project Decisions (长期记忆 - 架构决策)

这里记录本项目中不可动摇的"宪法级"技术决策。

## 1. Tech Stack
- SDK: Flutter (v3.10.0+)
- Language: Dart
- Core Framework: Stacked (MVVM architecture)

## 2. Architecture Patterns
- **Service Locator**: GetIt + Injectable (via `app.locator.dart`)
- **State Management**: Stacked `ViewModel` pattern
- **Navigation**: stacked_services `NavigationService` / go_router
- **Data Layer**: SQLite (sqflite) + Shared Preferences

## 3. Coding Standards
- Lint: `flutter_lints`
- Formatting: `dart format`
- Naming: LowerCamelCase for variables, UpperCamelCase for classes.
- Documentation: Mandatory for public APIs.

## 4. Third-Party Libs (Verified)
- `stacked`: Core Architecture
- `dio`: HTTP Client
- `sqflite`: Local Persistence
- `google_generative_ai`: Gemini Integration
- `flutter_tts`: Text-to-Speech

## 5. Project Roadmap
- **Goal**: 持续优化英文单词背诵体验。
- **Focus**: FSRS/遗忘曲线算法调优、AI 辅助内容生成（例句、讲解）。

## 6. Known Issues & Patterns
| 日期 | 类型 | 描述 | 解决方案 | 状态 |
|------|------|------|---------|------|
| 2026-02-09 | 初始化 | 完成基础架构扫描 | 确认为 Stacked 架构 | Resolved |

