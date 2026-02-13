import 'package:flutter/material.dart';
import '../../../../app/app.locator.dart';
import '../../../../core/base/baic_base_view_model.dart';
import '../../../../core/models/word.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/services/session_service.dart';

class DictationViewModel extends BaicBaseViewModel {
  final Word word;
  final VoidCallback onNext;
  final Function(String) onError;

  final _ttsService = locator<TtsService>();
  final _sessionService = locator<SessionService>();

  DictationViewModel({
    required this.word,
    required this.onNext,
    required this.onError,
  });

  String _inputValue = '';
  String get inputValue => _inputValue;

  bool _isShake = false;
  bool get isShake => _isShake;

  bool _showHint = false;
  bool get showHint => _showHint;

  /// 是否显示正确答案
  bool _showAnswer = false;
  bool get showAnswer => _showAnswer;

  /// 是否已经因本轮辅助操作触发过重闘
  bool _hasRequeueThisRound = false;

  void init() {
    _hasRequeueThisRound = false;
    _showAnswer = false;
    _showHint = false;
    // 进入时自动播放音频
    playAudioWithoutPenalty();
  }

  /// 播放音频(无惩罚版本,用于初始化时自动播放)
  void playAudioWithoutPenalty() async {
    // 先播放任务提示
    await _ttsService.speakChinese('请拼写');
    // 短暂停顿
    await Future.delayed(const Duration(milliseconds: 500));
    // 再播放单词
    _ttsService.speakEnglish(word.word);
  }

  /// 播放音频（普通版本，用于用户主动点击）
  void playAudio() {
    _ttsService.speakEnglish(word.word);
    // Boss战播放音频不触发惩罚，因为听写本身就需要听
  }

  /// 显示正确答案 - 使用辅助功能触发重闯
  void showCorrectAnswer() {
    _showAnswer = true;
    notifyListeners();
    _triggerRequeue('查看了正确答案');
  }

  /// 触发重闯机制（带去重）
  void _triggerRequeue(String reason) {
    if (!_hasRequeueThisRound) {
      _hasRequeueThisRound = true;
      _sessionService.requeueCurrentWord();
    }
  }

  void updateInput(String val) {
    _inputValue = val;
    notifyListeners();
  }

  void checkAnswer() async {
    if (_inputValue.trim().isEmpty) {
      _isShake = true;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 500));
      _isShake = false;
      notifyListeners();
      return; 
    } 

    if (_inputValue.trim().toLowerCase() == word.word.toLowerCase()) {
      onNext();
    } else {
      _isShake = true;
      _showHint = true; // 失败时显示提示
      onError("听写错误: $_inputValue vs ${word.word}");
      _triggerRequeue('听写错误');
      notifyListeners();
      
      await Future.delayed(const Duration(milliseconds: 500));
      _isShake = false;
      _inputValue = '';
      notifyListeners();
      
      // 重新播放音频以帮助用户
      playAudioWithoutPenalty();
    }
  }
}
