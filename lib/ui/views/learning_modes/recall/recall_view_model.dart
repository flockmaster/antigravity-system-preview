import 'dart:ui';
import 'dart:math';
import '../../../../app/app.locator.dart';
import '../../../../core/base/baic_base_view_model.dart';
import '../../../../core/models/word.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/services/session_service.dart';

class RecallViewModel extends BaicBaseViewModel {
  final Word word;
  final VoidCallback onNext;
  final VoidCallback onError;

  final _ttsService = locator<TtsService>();
  final _sessionService = locator<SessionService>();

  RecallViewModel({
    required this.word,
    required this.onNext,
    required this.onError,
  });

  List<bool> _mask = []; // true = masked (hidden)
  List<bool> get mask => _mask;

  String _inputValue = '';
  String get inputValue => _inputValue;

  bool _isShake = false;
  bool get isShake => _isShake;

  /// 是否显示正确答案
  bool _showAnswer = false;
  bool get showAnswer => _showAnswer;

  /// 是否已经因本轮辅助操作触发过重闯
  bool _hasRequeueThisRound = false;

  /// 获取当前输入与目标单词的前缀匹配长度
  int get matchLength {
    final target = word.word.toLowerCase();
    final input = _inputValue.trim().toLowerCase();
    int matchCount = 0;
    for (int i = 0; i < min(target.length, input.length); i++) {
      if (target[i] == input[i]) {
        matchCount++;
      } else {
        break; // 一旦不匹配就停止，严格前缀匹配
      }
    }
    return matchCount;
  }

  void init() {
    _generateMask();
    _hasRequeueThisRound = false;
    _showAnswer = false;
  }

  /// 生成遮罩策略
  /// 1. 首字母必显
  /// 2. 短单词(<=3): 遮中间1个
  /// 3. 中单词(4-6): 首尾显，中间遮元音或随机1-2个
  /// 4. 长单词(>6): 首显，每隔1-2个显示
  void _generateMask() {
    final len = word.word.length;
    _mask = List.filled(len, false); // 默认全显示，然后设置 true 为遮蔽

    if (len <= 1) {
      // 极端情况：1个字母，不遮
      return;
    }

    if (len <= 3) {
      // 短单词：遮中间
      if (len == 2) {
         _mask[1] = true; // AB -> A_
      } else {
         _mask[1] = true; // ABC -> A_C
      }
    } else if (len <= 6) {
      // 中单词：首尾显
      // 遮蔽中间部分，优先遮蔽元音，如果没有元音则随机
      // 我们简单处理：保持index 0 和 len-1 为 false
      for (int i = 1; i < len - 1; i++) {
        final char = word.word[i].toLowerCase();
        if ('aeiou'.contains(char)) {
          _mask[i] = true; // 遮元音
        } else {
          // 辅音 30% 概率遮
          if (Random().nextInt(10) < 3) _mask[i] = true;
        }
      }
      
      // 确保至少遮一个
      bool hasMasked = _mask.getRange(1, len - 1).contains(true);
      if (!hasMasked) {
         _mask[1] = true; // 强制遮第2个
      }

    } else {
      // 长单词：间隔显示
      // Index 0 必显
      for (int i = 1; i < len; i++) {
        // 简单策略：每隔1个遮蔽一个，或者随机
        // 这里的需求是：确保至少显示 50%
        // 我们尝试一种模式：显 遮 遮 显 ...
        if (Random().nextBool()) {
           _mask[i] = true;
        }
      }
      
      // 再次扫描，确保不要连续全遮，也不要太难
      // 首字母必须显示 (index 0 is false by default)
    }

    // 最后的安全检查：首字母必须显示
    _mask[0] = false;
    
    // 确保至少有一个被遮住 (除非单词长度为1)
    if (!_mask.contains(true) && len > 1) {
      _mask[len - 1] = true;
    }
  }

  void updateInput(String val) {
    _inputValue = val;
    notifyListeners();
  }

  /// 播放英文发音 - 使用辅助功能触发重闯
  void playAudio() {
    _ttsService.speakEnglish(word.word);
    _triggerRequeue('使用了朗读功能');
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
      // 正确
      onNext();
    } else {
      // 错误
      _isShake = true;
      onError(); // 报告错误
      _triggerRequeue('答错');
      notifyListeners();
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      _isShake = false;
      _inputValue = ''; // 清空输入以便重试
      notifyListeners();
    }
  }
}
