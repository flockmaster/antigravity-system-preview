import 'dart:ui';
import 'package:stacked/stacked.dart';

import '../../../../app/app.locator.dart';
import '../../../../core/models/word.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/services/speech_service.dart';
import '../../../../core/services/audio_manager.dart';
import '../../../../core/utils/speech_matcher.dart';

/// ViewModel for the Read Aloud stage (第2.5关：大声朗读)
/// 
/// Logic:
/// - 读对了 → 直接下一个单词
/// - 第1次读错 → 播放正确发音，提示"再听一遍"，再次尝试
/// - 第2次仍错 → 轻提示，自动放行
class ReadAloudViewModel extends BaseViewModel {
  final _ttsService = locator<TtsService>();
  final _speechService = locator<SpeechService>();
  final _audioManager = locator<AudioManager>();
  final _speechMatcher = SpeechMatcher();

  final Word word;
  final VoidCallback onNext;
  final Function([String?]) onError;

  ReadAloudViewModel({
    required this.word,
    required this.onNext,
    required this.onError,
  });

  DateTime? _listeningStartTime;
  
  // 用于防止重叠播放的标志
  bool _isNavigatingAway = false;

  bool _isListening = false;
  bool get isListening => _isListening;

  String _recognizedText = '';
  String get recognizedText => _recognizedText;

  bool _isMatched = false;
  bool get isMatched => _isMatched;

  int _attempts = 0;
  int get attempts => _attempts;

  bool _showRetryHint = false;
  bool get showRetryHint => _showRetryHint;

  void init() {
    _isNavigatingAway = false;
    // 初始播放一次标准发音
    speakWord();
  }

  void speakWord() {
    if (_isNavigatingAway) return;
    _ttsService.speakEnglish(word.word);
  }

  Future<void> startListening() async {
    _isListening = true;
    _listeningStartTime = DateTime.now();
    _recognizedText = '';
    _showRetryHint = false;
    notifyListeners();

    await _speechService.startListening(
      onResult: (text) {
        _recognizedText = text;
        notifyListeners();
        
        // 实时检测匹配
        _checkMatch(text);
      },
    );
  }


  /// 统一匹配检测逻辑
  void _checkMatch(String text) {
    if (_isMatched || _isNavigatingAway) return;
    
    if (_speechMatcher.evaluate(text, word.word)) {
      _handleMatchSuccess();
    }
  }

  Future<void> stopListening() async {
    if (_isMatched || _isNavigatingAway) return;
    
    await _speechService.stopListening();
    _isListening = false;
    notifyListeners();

    // 1. 防误触检测：按住时间过短
    if (_listeningStartTime != null) {
      final duration = DateTime.now().difference(_listeningStartTime!);
      if (duration.inMilliseconds < 500) {
        // 短按视为误触，不计次数，给提示
        // 可以在UI上增加一个短暂的Toast提示，或者利用recognizedText位置显示
        // 这里简单复用 recognizedText 显示提示，或者不处理直接返回
        return; 
      }
    }

    // 2. 空内容检测：没有录入任何内容
    if (_recognizedText.trim().isEmpty) {
        // 没听清或没录上，不计次数
        return;
    }

    // 松手时，最后再检测一次（防止实时流有延迟或恰好最后时刻匹配）
    if (!_isMatched && _recognizedText.isNotEmpty) {
       // 再次尝试匹配最终文本
       if (_speechMatcher.evaluate(_recognizedText, word.word)) {
         _handleMatchSuccess();
         return; 
       }
    }

    // 只有在时长足够、有内容、且没有匹配成功时，才评估失败逻辑
    _evaluateResultOnRelease();
  }

  void _handleMatchSuccess() {
      _isMatched = true;
      _speechService.stopListening();
      _isListening = false;
      _audioManager.playCorrect();
      _showRetryHint = false; // 清除重试提示
      notifyListeners();

      // 延迟后自动进入下一个
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!_isNavigatingAway) {
          _isNavigatingAway = true;
          onNext();
        }
      });
  }

  /// 松开手指后评估（只处理失败情况，成功已在检测中处理）
  void _evaluateResultOnRelease() {
    if (_isMatched || _isNavigatingAway) return;
    
    _attempts++;

    // 匹配失败的处理
    if (_attempts >= 2) {
      // 已尝试2次，自动放行
      _showRetryHint = false;
      notifyListeners();

      Future.delayed(const Duration(milliseconds: 500), () {
        if (!_isNavigatingAway) {
          _isNavigatingAway = true;
          onNext();
        }
      });
    } else {
      // 第1次失败，提示重试并播放正确发音
      _showRetryHint = true;
      notifyListeners();

      // 播放正确发音（增加检查，防止用户已经再次开始录音或匹配成功）
      Future.delayed(const Duration(milliseconds: 300), () {
        // 如果当前已经匹配成功，或者正在录音，或者已经跳走了，就不播放了
        if (!_isMatched && !_isListening && !_isNavigatingAway) {
           speakWord();
        }
      });
    }
  }

  @override
  void dispose() {
    _isNavigatingAway = true;
    _speechService.stopListening();
    super.dispose();
  }
}
