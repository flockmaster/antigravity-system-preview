# 避坑准则 (Prevention Rules)

## ❌ Windows 路径编码问题
- **现象**: Build 失败，报错 `ShaderCompilerException` 或 `Could not write file`，涉及 `flutter_assets`.
- **原因**: 项目路径包含中文或其他非 ASCII 字符 (如 `单词小助教`).
- **规则**: **[强制]** Windows 环境下，Flutter 项目路径**必须全程使用英文**，严禁包含中文、空格或特殊字符。
- **行动**: 立即重命名项目文件夹 (例如 `word_assistant`).
