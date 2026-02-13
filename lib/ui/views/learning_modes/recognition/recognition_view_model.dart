import 'dart:ui';
import '../../../../app/app.locator.dart';
import '../../../../core/base/baic_base_view_model.dart';
import '../../../../core/models/word.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/session_service.dart';

class RecognitionViewModel extends BaicBaseViewModel {
  final _ttsService = locator<TtsService>();
  final _dbService = locator<DatabaseService>();
  final _sessionService = locator<SessionService>();

  final Word word;
  final VoidCallback onNext;
  final VoidCallback? onError;

  RecognitionViewModel({
    required this.word,
    required this.onNext,
    this.onError,
  });

  List<String> _options = [];
  List<String> get options => _options;

  String? _selectedOption;
  String? get selectedOption => _selectedOption;

  bool? _isCorrect;
  bool? get isCorrect => _isCorrect;

  bool _isLocked = false; // 动画期间锁定UI

  Future<void> init() async {
    await _generateOptions();
    _playAudio();
  }

  void _playAudio() {
    _ttsService.speakEnglish(word.word);
  }

  void playAudioManually() {
    _playAudio();
  }

  Future<void> _generateOptions() async {
    // 1. 从数据库获取干扰项
    final allWords = await _dbService.getAllWords();
    final otherWords = allWords.where((w) => w.id != word.id).toList();
    otherWords.shuffle();
    
    // 2. 选取前3个或填充占位符
    final distractors = otherWords.take(3).map((w) => w.meaningForDictation).toList();
    
    while (distractors.length < 3) {
      distractors.add('干扰项 ${distractors.length + 1}');
    }

    _options = [word.meaningForDictation, ...distractors];
    _options.shuffle();
    notifyListeners();
  }

  void selectOption(String option) async {
    if (_isLocked) return; // 防止动画期间双击或点击
    
    _selectedOption = option;
    
    if (option == word.meaningForDictation) {
      // 正确
      _isCorrect = true;
      _isLocked = true;
      notifyListeners();
      
      // 播放单词强化记忆
      _playAudio();
      
      await Future.delayed(const Duration(milliseconds: 1000));
      onNext();
    } else {
      // 错误
      _isCorrect = false;
      _isLocked = true;
      
      // 报告错误（统计）
      onError?.call();
      
      // 将单词加入队列末尾（错误重闯机制）
      _sessionService.requeueCurrentWord();
      
      notifyListeners();

      // 等待抖动动画
      await Future.delayed(const Duration(milliseconds: 800));
      
      // 重置选择以允许重试（循环直到正确）
      _selectedOption = null;
      _isCorrect = null;
      _isLocked = false;
      notifyListeners();
    }
  }
}
