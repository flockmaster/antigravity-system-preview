import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'i_tts_service.dart';

/// 使用 `flutter_tts` 插件实现的系统 TTS。
/// 适用于 iOS 和 Android。
class SystemTtsService implements ITtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  SystemTtsService() {
    _init();
  }

  Future<void> _init() async {
    try {
      // 通用配置
      await _flutterTts.awaitSpeakCompletion(true);
      
      if (Platform.isIOS) {
        await _flutterTts.setSharedInstance(true);
        await _flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers
          ],
          IosTextToSpeechAudioMode.defaultMode
        );
      } else if (Platform.isAndroid) {
        await _flutterTts.setQueueMode(1);
        final engines = await _flutterTts.getEngines;
         if (engines is List && engines.isNotEmpty) {
          final googleEngine = engines.firstWhere(
            (e) => e.toString().toLowerCase().contains('google'),
            orElse: () => engines.first,
          );
          await _flutterTts.setEngine(googleEngine.toString());
        }
      }
      
      _flutterTts.setErrorHandler((msg) {
        debugPrint("系统 TTS 错误: $msg");
      });
      
      _isInitialized = true;
    } catch (e) {
      debugPrint("系统 TTS 初始化错误: $e");
    }
  }

  @override
  Future<void> speak(String text, {String? language}) async {
    if (!_isInitialized) await _init();
    if (language != null) {
      await _flutterTts.setLanguage(language);
    }
    await _flutterTts.speak(text);
  }

  @override
  Future<void> stop() async {
    await _flutterTts.stop();
  }

  @override
  Future<void> setRate(double rate) async {
    await _flutterTts.setSpeechRate(rate);
  }

  @override
  Future<void> setVolume(double volume) async {
    await _flutterTts.setVolume(volume);
  }

  @override
  Future<void> setPitch(double pitch) async {
    await _flutterTts.setPitch(pitch);
  }

  @override
  Future<dynamic> getLanguages() async {
    return await _flutterTts.getLanguages;
  }
  
  @override
  Future<bool> isLanguageAvailable(String language) async {
    final result = await _flutterTts.isLanguageAvailable(language);
    return result == 1 || result == true;
  }
}
