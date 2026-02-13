import 'package:stacked/stacked.dart';
import '../models/word.dart';
import '../models/dictation_session.dart';

/// 听写服务
/// 
/// 管理当前听写会话的状态。
class DictationService with ListenableServiceMixin {
  /// 用户为当前会话确认的单词列表
  /// 实际执行队列（待测试项目列表）
  List<DictationItem> _queue = [];
  List<DictationItem> get queue => _queue;

  // -- 遗留兼容性字段 --
  // 我们保留这些字段以支持读取 'currentWords' 或 'currentMode' 的现有视图
  // 但现在的执行数据源已改为 '_queue'。
  
  /// 本次会话涉及的唯一单词列表
  List<Word> _currentWords = [];
  List<Word> get currentWords => _currentWords;

  /// 全局模式偏好（如果是统一模式）。如果是混合模式，这可能会误导，
  /// 因此视图应优先使用 `queue[index].mode`。
  DictationMode _currentMode = DictationMode.modeA;
  DictationMode get currentMode => _currentMode;

  /// 输入方式 (纸笔 paper / 电子 digital)
  String _inputMethod = 'paper';
  String get inputMethod => _inputMethod;
  bool get isDigital => _inputMethod == 'digital';

  /// 会话的最终结果
  SessionResult? _lastResult;
  SessionResult? get lastResult => _lastResult;

  /// 遗留方法：设置单词并重置队列为空，直到调用 setMode 或自动生成
  void setWords(List<Word> words) {
    _currentWords = words;
    // 这里我们还不构建队列，因为在遗留流程中模式尚不明确
    notifyListeners();
  }

  /// 遗留方法：设置模式并构建统一队列
  void setMode(DictationMode mode) {
    _currentMode = mode;
    _buildUniformQueue();
    notifyListeners();
  }

  void _buildUniformQueue() {
    _queue = _currentWords.map((w) => DictationItem(
      id: '${w.id}_${_currentMode.name}',
      word: w,
      mode: _currentMode,
    )).toList();
    // 默认打乱顺序以获得更好的练习效果
    _queue.shuffle();
  }

  /// 新方法：开始混合模式会话
  /// 为每个单词生成 A+B+C 练习，并强制使用电子输入。
  /// [specificMode] 指定意图（例如 错题消灭 MistakeCrusher, 智能复习 SmartReview）。默认为自定义。
  void startMixedSession(List<Word> words, {DictationMode specificMode = DictationMode.customSelection}) {
    _currentWords = words;
    _currentMode = specificMode; 
    _inputMethod = 'digital'; // 强制电子输入

    List<DictationItem> newQueue = [];
    for (var w in words) {
      newQueue.add(DictationItem(id: '${w.id}_A', word: w, mode: DictationMode.modeA));
      newQueue.add(DictationItem(id: '${w.id}_B', word: w, mode: DictationMode.modeB));
      newQueue.add(DictationItem(id: '${w.id}_C', word: w, mode: DictationMode.modeC));
    }
    newQueue.shuffle();
    _queue = newQueue;
    
    notifyListeners();
  }

  /// 打乱当前单词列表（如果是统一模式则重新构建队列）
  void shuffleWords() {
    _currentWords.shuffle();
    if (_queue.length == _currentWords.length) {
       _buildUniformQueue(); // 如果匹配则重新构建
    } else {
       _queue.shuffle(); // 仅打乱队列
    }
    notifyListeners();
  }

  void setInputMethod(String method) {
    _inputMethod = method;
    notifyListeners();
  }

  void setResult(SessionResult result) {
    _lastResult = result;
    notifyListeners();
  }

  void clearSession() {
    _currentWords = [];
    _queue = [];
    _currentMode = DictationMode.modeA;
    _inputMethod = 'paper';
    _lastResult = null;
    notifyListeners();
  }
}
