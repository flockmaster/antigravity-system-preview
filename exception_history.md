# 异常历史记录

## [Critical] ShaderCompilerException (impellerc)
- **Error**: `ShaderCompilerException: Shader compilation of ... failed with exit code 1.`
- **Context**: Windows OS, Project path contains Chinese characters (`单词小助教`).
- **Frequency**: User reported "many times".
- **Cause**: Flutter's `impellerc` shader compiler has known issues with non-ASCII paths on Windows.
- **Solution**: Rename project directory to English.

## [Network] CocoaPods SSL Connect Error
- **Error**: `CDN: trunk URL couldn't be downloaded ... Response: SSL connect error`
- **Context**: `flutter run` -> `pod install` on macOS.
- **Frequency**: 1
- **Last Occurred**: 2026-02-03
- **Cause**: Network connectivity issues accessing CocoaPods CDN (likely due to network restrictions or instability).
- **Solution**: Check proxy settings, switch to mirror sources (e.g., TUNA), or retry.

## [UI] RenderFlex overflow
- **Error**: `RenderFlex overflowed by X pixels on the bottom`
- **Context**: Calendar (Today cell) and Wish cards.
- **Frequency**: 2
- **Last Occurred**: 2026-02-05
- **Cause**: Content within Calendar Day Cell (specifically 'Today' with dot indicator) exceeds height derived from aspect ratio on small screens.
- **Solution**: Further reduce `childAspectRatio` (e.g., to 0.75) to ensure minimum height logic covers the tallest cell content (approx 40px).
