import 'edge_tts_constants.dart';

/// TTS 配置类
/// 
/// 存储语音合成的配置参数。
class EdgeTtsConfig {
  /// 语音名称
  final String voice;
  
  /// 语速（如 "+0%", "-20%", "+50%"）
  final String rate;
  
  /// 音量（如 "+0%", "-50%", "+100%"）
  final String volume;
  
  /// 音调（如 "+0Hz", "-10Hz", "+20Hz"）
  final String pitch;
  
  /// 输出格式
  final String outputFormat;
  
  EdgeTtsConfig({
    String? voice,
    String? rate,
    String? volume,
    String? pitch,
    String? outputFormat,
  }) : voice = voice ?? EdgeTtsVoices.defaultEnglish,
       rate = rate ?? '+0%',
       volume = volume ?? '+0%',
       pitch = pitch ?? '+0Hz',
       outputFormat = outputFormat ?? EdgeTtsOutputFormat.defaultFormat;
  
  /// 创建英文配置
  factory EdgeTtsConfig.english({
    String? voice,
    String? rate,
    String? volume,
    String? pitch,
  }) {
    return EdgeTtsConfig(
      voice: voice ?? EdgeTtsVoices.defaultEnglish,
      rate: rate,
      volume: volume,
      pitch: pitch,
    );
  }
  
  /// 创建中文配置
  factory EdgeTtsConfig.chinese({
    String? voice,
    String? rate,
    String? volume,
    String? pitch,
  }) {
    return EdgeTtsConfig(
      voice: voice ?? EdgeTtsVoices.defaultChinese,
      rate: rate,
      volume: volume,
      pitch: pitch,
    );
  }
  
  /// 复制并修改配置
  EdgeTtsConfig copyWith({
    String? voice,
    String? rate,
    String? volume,
    String? pitch,
    String? outputFormat,
  }) {
    return EdgeTtsConfig(
      voice: voice ?? this.voice,
      rate: rate ?? this.rate,
      volume: volume ?? this.volume,
      pitch: pitch ?? this.pitch,
      outputFormat: outputFormat ?? this.outputFormat,
    );
  }
  
  @override
  String toString() => 'EdgeTtsConfig(voice: $voice, rate: $rate, volume: $volume, pitch: $pitch)';
}
