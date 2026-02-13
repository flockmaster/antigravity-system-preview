/// Edge TTS - Dart 版本
/// 
/// 基于微软 Edge 在线 TTS 服务的文本转语音库。
/// 完全免费，无需 API Key，支持高质量的神经网络语音。
/// 
/// 这是从 Python 的 edge-tts 库移植而来的 Dart 实现。
/// 
/// ## 特性
/// 
/// - 🆓 完全免费，无额度限制
/// - 🎯 高质量神经网络语音
/// - 🌍 支持多种语言和声音
/// - ⚡ 流式音频传输
/// - 🔧 简单易用的 API
/// 
/// ## 快速开始
/// 
/// ```dart
/// import 'package:word_assistant/core/services/edge_tts/edge_tts.dart';
/// 
/// final engine = EdgeTtsEngine();
/// 
/// // 朗读英文
/// await engine.speakEnglish('Hello, world!');
/// 
/// // 朗读中文
/// await engine.speakChinese('你好，世界！');
/// ```
/// 
/// ## 可用语音
/// 
/// 查看 [EdgeTtsVoices] 类获取所有预定义的语音常量。
/// 
/// ### 中文语音示例
/// - `EdgeTtsVoices.zhCNXiaoxiao` - 晓晓（女声，活泼）
/// - `EdgeTtsVoices.zhCNYunxi` - 云希（男声）
/// - `EdgeTtsVoices.zhCNYunyang` - 云扬（男声，新闻播报）
/// 
/// ### 英文语音示例
/// - `EdgeTtsVoices.enUSEmma` - Emma（多语言）
/// - `EdgeTtsVoices.enUSJenny` - Jenny
/// - `EdgeTtsVoices.enUSGuy` - Guy
/// 
/// ## 高级用法
/// 
/// ```dart
/// // 自定义配置
/// final config = EdgeTtsConfig(
///   voice: EdgeTtsVoices.zhCNYunxi,
///   rate: '+20%',
///   volume: '+10%',
///   pitch: '+5Hz',
/// );
/// 
/// await engine.speak('自定义语音配置', config: config);
/// 
/// // 获取音频数据（用于缓存）
/// final audioData = await engine.getAudio('测试文本');
/// 
/// // 保存到文件
/// await engine.saveToFile('测试文本', '/path/to/output.mp3');
/// ```
library edge_tts;

export 'edge_tts_constants.dart';
export 'edge_tts_config.dart';
export 'edge_tts_drm.dart';
export 'edge_tts_communicate.dart';
export 'edge_tts_engine.dart';
