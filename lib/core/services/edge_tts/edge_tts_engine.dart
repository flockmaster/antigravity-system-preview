import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'edge_tts_communicate.dart';
import 'edge_tts_config.dart';
import 'edge_tts_constants.dart';

/// Edge TTS 引擎服务
/// 
/// 提供简单易用的 TTS 接口，基于微软 Edge 在线 TTS 服务。
/// 完全免费，无需 API Key，支持高质量的神经网络语音。
/// 
/// ## 使用示例
/// 
/// ```dart
/// final engine = EdgeTtsEngine();
/// 
/// // 朗读英文
/// await engine.speakEnglish('Hello, world!');
/// 
/// // 朗读中文
/// await engine.speakChinese('你好，世界！');
/// 
/// // 自定义语音和语速
/// await engine.speak(
///   '这是测试文本',
///   config: EdgeTtsConfig(
///     voice: EdgeTtsVoices.zhCNYunxi,
///     rate: '+20%',
///   ),
/// );
/// ```
class EdgeTtsEngine {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  /// 当前英语口音
  EnglishAccent _currentAccent = EnglishAccent.american;
  
  /// 英文语音配置
  EdgeTtsConfig _englishConfig = EdgeTtsConfig.english();
  
  /// 中文语音配置
  EdgeTtsConfig _chineseConfig = EdgeTtsConfig.chinese();
  
  /// 是否正在播放
  bool _isPlaying = false;
  
  /// 临时文件目录
  Directory? _tempDir;
  
  /// 播放完成回调
  VoidCallback? onComplete;
  
  /// 播放错误回调
  Function(String)? onError;
  
  EdgeTtsEngine() {
    _init();
  }
  
  Future<void> _init() async {
    _tempDir = await getTemporaryDirectory();
    
    // 设置播放器回调
    _audioPlayer.onPlayerComplete.listen((_) {
      _isPlaying = false;
      onComplete?.call();
    });
    
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.stopped || state == PlayerState.completed) {
        _isPlaying = false;
      } else if (state == PlayerState.playing) {
        _isPlaying = true;
      }
    });
  }
  
  /// 是否正在播放
  bool get isPlaying => _isPlaying;
  
  /// 获取当前英语口音
  EnglishAccent get currentAccent => _currentAccent;
  
  /// 获取当前英文语音ID
  String get currentEnglishVoice => _englishConfig.voice;
  
  /// 获取当前中文语音ID
  String get currentChineseVoice => _chineseConfig.voice;
  
  /// 设置英语口音（会自动切换到该口音的默认语音）
  void setAccent(EnglishAccent accent) {
    if (_currentAccent != accent) {
      _currentAccent = accent;
      // 切换到该口音的默认语音
      final defaultVoice = EdgeTtsVoices.getDefaultEnglishByAccent(accent);
      _englishConfig = _englishConfig.copyWith(voice: defaultVoice);
      debugPrint('Edge TTS: 切换口音为 ${accent == EnglishAccent.british ? "英式" : "美式"}，语音: $defaultVoice');
    }
  }
  
  /// 设置英文语音
  void setEnglishVoice(String voice) {
    _englishConfig = _englishConfig.copyWith(voice: voice);
    debugPrint('Edge TTS: 设置英文语音为 $voice');
  }
  
  /// 设置中文语音
  void setChineseVoice(String voice) {
    _chineseConfig = _chineseConfig.copyWith(voice: voice);
    debugPrint('Edge TTS: 设置中文语音为 $voice');
  }
  
  /// 设置语速（应用于所有语音）
  void setRate(String rate) {
    _englishConfig = _englishConfig.copyWith(rate: rate);
    _chineseConfig = _chineseConfig.copyWith(rate: rate);
  }
  
  /// 设置音量（应用于所有语音）
  void setVolume(String volume) {
    _englishConfig = _englishConfig.copyWith(volume: volume);
    _chineseConfig = _chineseConfig.copyWith(volume: volume);
  }
  
  /// 获取当前口音可用的语音列表
  List<VoiceInfo> getAvailableEnglishVoices() {
    return EdgeTtsVoices.getVoicesByAccent(_currentAccent);
  }
  
  /// 获取可用的中文语音列表
  List<VoiceInfo> getAvailableChineseVoices() {
    return EdgeTtsVoices.chineseVoices;
  }
  
  /// 朗读文本
  /// 
  /// [text] 要朗读的文本
  /// [config] 可选的配置，如果不提供则使用英文默认配置
  Future<void> speak(String text, {EdgeTtsConfig? config}) async {
    if (text.isEmpty) return;
    
    // 停止当前播放
    await stop();
    
    try {
      final useConfig = config ?? _englishConfig;
      
      // 使用 getAudio 获取音频（已包含缓存逻辑）
      // 这修复了之前 speak 方法绕过缓存直接请求网络的问题
      final audioData = await getAudio(
        text,
        config: useConfig,
      );
      
      if (audioData.isEmpty) {
        throw Exception('未获取到音频数据');
      }
      
      // 播放音频
      await _playAudioData(audioData);
      
    } catch (e) {
      debugPrint('Edge TTS 朗读错误: $e');
      onError?.call(e.toString());
      rethrow;
    }
  }
  
  /// 朗读英文
  Future<void> speakEnglish(String text) async {
    await speak(text, config: _englishConfig);
  }
  
  /// 朗读中文
  Future<void> speakChinese(String text) async {
    await speak(text, config: _chineseConfig);
  }
  
  /// 缓存目录
  Directory? _cacheDir;
  
  /// 获取缓存目录
  Future<Directory> _getCacheDir() async {
    if (_cacheDir != null) return _cacheDir!;
    
    final appDir = await getApplicationDocumentsDirectory();
    _cacheDir = Directory('${appDir.path}/edge_tts_cache');
    
    if (!await _cacheDir!.exists()) {
      await _cacheDir!.create(recursive: true);
    }
    
    return _cacheDir!;
  }
  
  /// 生成缓存文件名
  String _getCacheFileName(String text, EdgeTtsConfig config) {
    // 将所有影响语音的参数都纳入哈希计算
    final content = '${config.voice}:${config.rate}:${config.volume}:${config.pitch}:$text';
    final hash = md5.convert(utf8.encode(content)).toString();
    return '$hash.mp3';
  }

  /// 获取音频数据（支持缓存）
  /// 
  /// 如果缓存存在，直接返回缓存数据；
  /// 否则从网络获取并保存到缓存。
  Future<Uint8List> getAudio(String text, {EdgeTtsConfig? config}) async {
    if (text.isEmpty) {
      return Uint8List(0);
    }
    
    final useConfig = config ?? _englishConfig;
    
    try {
      // 1. 检查缓存
      final cacheDir = await _getCacheDir();
      final fileName = _getCacheFileName(text, useConfig);
      final cacheFile = File('${cacheDir.path}/$fileName');
      
      if (await cacheFile.exists()) {
        debugPrint('Edge TTS: [⚡️ 缓存命中] -> "$text"');
        return await cacheFile.readAsBytes();
      }
      
      // 2. 缓存未命中，请求网络
      debugPrint('Edge TTS: [☁️ 网络请求] -> "$text" (${useConfig.voice})');
      final communicate = EdgeTtsCommunicate(
        text: text,
        config: useConfig,
      );
      
      final audioData = await communicate.getAudio();
      
      // 3. 写入缓存
      if (audioData.isNotEmpty) {
        await cacheFile.writeAsBytes(audioData);
        debugPrint('Edge TTS: [💾 已写入缓存] -> ${cacheFile.path}');
      }
      
      return audioData;
    } catch (e) {
      debugPrint('Edge TTS 获取音频失败: $e');
      rethrow;
    }
  }
  
  /// 保存音频到文件
  Future<File> saveToFile(String text, String filePath, {EdgeTtsConfig? config}) async {
    final audioData = await getAudio(text, config: config);
    final file = File(filePath);
    await file.writeAsBytes(audioData);
    debugPrint('Edge TTS: 音频已保存到 $filePath');
    return file;
  }
  
  /// 播放音频数据
  Future<void> _playAudioData(Uint8List audioData) async {
    // 保存到临时文件
    final tempFile = File('${_tempDir?.path ?? '/tmp'}/edge_tts_${DateTime.now().millisecondsSinceEpoch}.mp3');
    await tempFile.writeAsBytes(audioData);
    
    // 播放
    _isPlaying = true;
    await _audioPlayer.play(DeviceFileSource(tempFile.path));
    
    // 等待播放完成
    await _audioPlayer.onPlayerComplete.first;
    
    // 清理临时文件
    try {
      await tempFile.delete();
    } catch (e) {
      // 忽略删除错误
    }
  }
  
  /// 停止播放
  Future<void> stop() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      _isPlaying = false;
    }
  }
  
  /// 暂停播放
  Future<void> pause() async {
    await _audioPlayer.pause();
  }
  
  /// 恢复播放
  Future<void> resume() async {
    await _audioPlayer.resume();
  }
  
  /// 释放资源
  Future<void> dispose() async {
    await stop();
    await _audioPlayer.dispose();
  }
}
