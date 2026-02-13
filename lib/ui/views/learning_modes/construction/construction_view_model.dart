import 'dart:ui';
import '../../../../app/app.locator.dart';
import '../../../../core/base/baic_base_view_model.dart';
import '../../../../core/models/word.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/services/session_service.dart';

class LetterTile {
  final String char;
  final int id; // 用于区分相同字母的唯一ID
  LetterTile(this.char, this.id);
}

class ConstructionViewModel extends BaicBaseViewModel {
  final Word word;
  final VoidCallback onNext;
  final Function(String) onError;

  final _ttsService = locator<TtsService>();
  final _sessionService = locator<SessionService>();

  ConstructionViewModel({
    required this.word,
    required this.onNext,
    required this.onError,
  });

  List<LetterTile> _pool = [];
  List<LetterTile> get pool => _pool;

  List<LetterTile?> _slots = []; // 固定大小的槽位
  List<LetterTile?> get slots => _slots;

  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;
  
  bool _isShake = false; // 触发抖动动画
  bool get isShake => _isShake;

  /// 是否显示正确答案
  bool _showAnswer = false;
  bool get showAnswer => _showAnswer;

  /// 是否已经因本轮辅助操作触发过重闯
  bool _hasRequeueThisRound = false;

  void init() {
    _slots = List.filled(word.word.length, null);
    
    // 从单词创建字母块
    final chars = word.word.split('');
    _pool = List.generate(chars.length, (index) => LetterTile(chars[index], index));
    _pool.shuffle();
    
    _hasRequeueThisRound = false;
    _showAnswer = false;
    
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

  void onTapPoolTile(LetterTile tile) {
    // 找到第一个空槽位
    final index = _slots.indexWhere((s) => s == null);
    if (index != -1) {
      _slots[index] = tile;
      _pool.remove(tile);
      notifyListeners();
      
      _checkCompletion();
    }
  }

  void onTapSlotTile(int index) {
    if (_slots[index] != null) {
      final tile = _slots[index]!;
      _slots[index] = null;
      _pool.add(tile);
      notifyListeners();
    }
  }

  void _checkCompletion() async {
    // 1. 检查是否填满
    if (_slots.any((s) => s == null)) return;

    // 2. 构建字符串
    final currentString = _slots.map((t) => t!.char).join('');
    
    // 3. 比较（不区分大小写）
    if (currentString.toLowerCase() == word.word.toLowerCase()) {
      _isSuccess = true;
      notifyListeners();
      
      await Future.delayed(const Duration(milliseconds: 600));
      onNext();
    } else {
      // 错误！
      _isShake = true;
      onError("拼写错误: $currentString vs ${word.word}");
      _triggerRequeue('拼写错误');
      notifyListeners();
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 重置：将所有字母放回池中
      _isShake = false;
      final chars = word.word.split('');
      _pool = List.generate(chars.length, (index) => LetterTile(chars[index], index));
      _pool.shuffle();
      _slots = List.filled(word.word.length, null);
      
      notifyListeners();
    }
  }
}
