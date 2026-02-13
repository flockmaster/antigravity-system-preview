/// 文字转语音 (TTS) 服务的接口。
/// 
/// 该抽象层支持在以下引擎间切换：
/// - 系统 TTS (iOS/Android 默认)
/// - 云端 TTS (Edge/Azure)
/// - 离线神经网络 TTS (适用于鸿蒙的 Sherpa Onnx)
abstract class ITtsService {
  /// 朗读给定的文本 [text]。
  /// 
  /// [language] 是可选的，例如 "en-US", "zh-CN"。
  Future<void> speak(String text, {String? language});

  /// 停止当前正在播放的语音。
  Future<void> stop();

  /// 设置语速（通常为 0.0 到 1.0）。
  Future<void> setRate(double rate);
  
  /// 设置音量（0.0 到 1.0）。
  Future<void> setVolume(double volume);
  
  /// 设置音调（0.5 到 2.0）。
  Future<void> setPitch(double pitch);
  
  /// 获取可用的语言/语音列表。
  Future<dynamic> getLanguages();
  
  /// 检查特定语言是否可用。
  Future<bool> isLanguageAvailable(String language);
}
