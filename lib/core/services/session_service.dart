import 'dart:convert';
import 'package:stacked/stacked.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word.dart';
import '../models/learning_model.dart';
import '../../app/app.locator.dart';
import '../models/study_stat.dart'; // Add import
import 'database_service.dart';
import '../utils/app_logger.dart';

class SessionService with ListenableServiceMixin {
  final _dbService = locator<DatabaseService>();
  
  static const String _storageKey = 'active_learning_session';

  LearningSession? _currentSession;
  LearningSession? get currentSession => _currentSession;

  /// 每个阶段独立的学习队列 (第2关起使用)
  /// Key: LearningStage, Value: 该阶段的单词队列
  Map<LearningStage, List<Word>> _stageQueues = {};

  /// 获取当前阶段队列的第一个单词
  Word? get currentWord {
    if (_currentSession == null) return null;
    final stage = _currentSession!.currentStage;
    
    // 第1关(preview)使用传统索引模式
    if (stage == LearningStage.preview) {
      if (_currentSession!.batch.isEmpty) return null;
      if (_currentSession!.currentIndex >= _currentSession!.batch.length) return null;
      return _currentSession!.batch[_currentSession!.currentIndex];
    }
    
    // 第2关及以后使用队列模式
    if (stage == LearningStage.summary) return null;
    
    final queue = _stageQueues[stage];
    if (queue == null || queue.isEmpty) return null;
    return queue.first;
  }

  double get progress {
    if (_currentSession == null) return 0.0;
    
    // 总步骤 = 5个阶段 * 原始单词数量
    const totalStages = 5; 
    final originalWordCount = _currentSession!.batch.length;
    final totalSteps = totalStages * originalWordCount;

    if (totalSteps == 0) return 0;

    // 如果是总结阶段，进度满
    if (_currentSession!.currentStage == LearningStage.summary) return 1.0;

    int currentStageIndex = _currentSession!.currentStage.progressStep - 1; // 0-based
    
    // 计算已完成的步骤数
    // 已完成的阶段 * 单词数 + 当前阶段已完成的单词数
    int completedInCurrentStage = 0;
    
    if (currentStageIndex == 0) {
      // preview阶段使用传统索引
      completedInCurrentStage = _currentSession!.currentIndex;
    } else {
      // 其他阶段：原始单词数 - 当前队列剩余数
      final stage = _currentSession!.currentStage;
      final queue = _stageQueues[stage];
      if (queue != null) {
        // 注意：队列可能因为错误而变长，我们使用原始单词数作为基准
        completedInCurrentStage = originalWordCount - queue.length.clamp(0, originalWordCount);
      }
    }

    int completedSteps = (currentStageIndex * originalWordCount) + completedInCurrentStage;
    
    return (completedSteps / totalSteps).clamp(0.0, 1.0);
  }

  /// 开始新的学习会话
  Future<void> startSession(List<Word> words, {String source = 'unknown'}) async {
    _currentSession = LearningSession(
      id: DateTime.now().toIso8601String(),
      batch: words,
      currentStage: LearningStage.preview,
      currentIndex: 0,
      startTime: DateTime.now(), // Record start time
      sessionSource: source,
    );
    
    // 初始化各阶段的队列（从第2关开始）
    _initStageQueues(words);
    
    notifyListeners();
    await _saveToDisk();
  }

  /// 初始化各阶段队列
  void _initStageQueues(List<Word> words) {
    _stageQueues = {
      LearningStage.recognition: List.from(words),
      LearningStage.readAloud: List.from(words),    // 第2.5关：朗读跟读
      LearningStage.recall: List.from(words),       // 第3关
      LearningStage.construction: List.from(words), // 第4关
      LearningStage.dictation: List.from(words),
    };
  }

  /// 从磁盘恢复会话
  Future<bool> resumeSession() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey);
    if (jsonStr != null) {
      try {
        final json = jsonDecode(jsonStr);
        _currentSession = LearningSession.fromJson(json);
        
        // 恢复时重新初始化队列（简化处理，不持久化队列状态）
        _initStageQueues(_currentSession!.batch);
        
        notifyListeners();
        return true;
      } catch (e) {
        AppLogger.e('恢复会话时出错', error: e);
        await clearSession();
        return false;
      }
    }
    return false;
  }

  Future<void> clearSession() async {
    _currentSession = null;
    _stageQueues.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    notifyListeners();
  }

  /// 将当前单词重新加入队列末尾（错误重闯机制）
  /// 自带队尾去重：如果队列末尾已经是当前单词，则不重复插入
  void requeueCurrentWord() {
    if (_currentSession == null) return;
    
    final stage = _currentSession!.currentStage;
    
    // 第1关不需要这个机制
    if (stage == LearningStage.preview || stage == LearningStage.summary) return;
    
    final queue = _stageQueues[stage];
    if (queue == null || queue.isEmpty) return;
    
    final currentWordItem = queue.first;
    
    // 队尾去重：如果队列末尾已经是当前单词，不重复插入
    if (queue.length > 1 && queue.last.id == currentWordItem.id) {
      AppLogger.d('队尾已是当前单词，跳过插入: ${currentWordItem.word}');
      return;
    }
    
    // 将当前单词插入队列末尾
    queue.add(currentWordItem);
    AppLogger.d('单词已加入队列末尾: ${currentWordItem.word}，队列长度: ${queue.length}');
    
    notifyListeners();
  }

  /// 标记当前单词为错误（用于统计）
  void reportError() {
    if (_currentSession == null) return;
    
    final currentWordId = currentWord?.id;
    if (currentWordId != null) {
       final newErrors = Set<String>.from(_currentSession!.errorWordIds);
       newErrors.add(currentWordId);
       
       _currentSession = _currentSession!.copyWith(errorWordIds: newErrors);
       notifyListeners();
       _saveToDisk();
    }
  }

  /// 前进到下一步
  Future<void> next() async {
    if (_currentSession == null) return;

    final currentStage = _currentSession!.currentStage;

    // === 第1关（preview）使用传统索引模式 ===
    if (currentStage == LearningStage.preview) {
      int nextIndex = _currentSession!.currentIndex + 1;
      
      if (nextIndex >= _currentSession!.batch.length) {
        // 第1关完成，进入第2关
        _currentSession = _currentSession!.copyWith(
          currentStage: LearningStage.recognition,
          currentIndex: 0,
        );
      } else {
        _currentSession = _currentSession!.copyWith(currentIndex: nextIndex);
      }
      
      notifyListeners();
      await _saveToDisk();
      return;
    }

    // === 第2关及以后使用队列模式 ===
    if (currentStage == LearningStage.summary) return;
    
    final queue = _stageQueues[currentStage];
    if (queue == null || queue.isEmpty) return;
    
    // 移除队列头部（当前单词已完成）
    queue.removeAt(0);
    
    // 检查队列是否清空
    if (queue.isEmpty) {
      // 进入下一阶段
      final stageOrder = [
        LearningStage.preview,
        LearningStage.recognition,
        LearningStage.readAloud,    // 第2.5关
        LearningStage.recall,       // 第3关
        LearningStage.construction, // 第4关
        LearningStage.dictation,
        LearningStage.summary,
      ];
      
      int currentStageIndex = stageOrder.indexOf(currentStage);
      if (currentStageIndex < stageOrder.length - 1) {
        final nextStage = stageOrder[currentStageIndex + 1];
        
        _currentSession = _currentSession!.copyWith(
          currentStage: nextStage,
          currentIndex: 0,
        );
        
        // 当进入 summary 阶段时，更新推荐分数
        if (nextStage == LearningStage.summary) {
          await _updateScoresForCompletedSession();
        }
      }
    }
    
    notifyListeners();
    await _saveToDisk();
  }

  Future<void> _updateScoresForCompletedSession() async {
    if (_currentSession == null) return;
    
    // 获取本次学习的所有单词（排除出错的，它们会在听写中单独处理）
    final successWords = _currentSession!.batch
        .where((w) => !_currentSession!.errorWordIds.contains(w.id))
        .toList();
    
    if (successWords.isNotEmpty) {
      await _dbService.updateScoreAfterLearningSession(successWords);
    }

    // === SAVE STATISTICS ===
    try {
      if (_currentSession!.startTime != null) {
        final endTime = DateTime.now();
        final duration = endTime.difference(_currentSession!.startTime!);
        
        final stat = StudyStat(
          date: endTime.toIso8601String().split('T')[0],
          sessionType: _currentSession!.sessionSource ?? 'unknown',
          durationSeconds: duration.inSeconds,
          wordCount: _currentSession!.batch.length,
          startTime: _currentSession!.startTime!,
          endTime: endTime,
        );
        
        await _dbService.insertStudyStat(stat);
        AppLogger.i('学习统计已保存: $duration, ${_currentSession!.batch.length}词');
      }
    } catch (e) {
      AppLogger.e('保存学习统计失败', error: e);
    }
  }

  Future<void> _saveToDisk() async {
    // 临时禁用持久化以便调试 'stuck' 会话问题
    // if (_currentSession == null) return;
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString(_storageKey, jsonEncode(_currentSession!.toJson()));
  }
}
