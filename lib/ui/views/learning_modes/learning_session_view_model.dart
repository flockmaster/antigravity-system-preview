import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../../app/app.locator.dart';
import '../../../../app/app.router.dart';
import '../../../../core/models/word.dart';
import '../../../../core/models/learning_model.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/services/audio_manager.dart';
import '../../../../core/services/dictation_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/models/dictation_session.dart';
import '../../../../core/utils/points_calculator.dart';
import '../../../../core/utils/streak_rewards.dart';
import '../common/pet_mood_display.dart'; // Direct import for Enum access

class LearningSessionViewModel extends ReactiveViewModel {
  final _sessionService = locator<SessionService>();
  final _navigationService = locator<NavigationService>();
  final _audioManager = locator<AudioManager>();
  final _dictationService = locator<DictationService>();
  final _userService = locator<UserService>();
  final _dbService = locator<DatabaseService>();

  bool _showConfetti = false;
  bool get showConfetti => _showConfetti;

  // Combo 相关状态
  int _consecutiveCorrect = 0;  // 连续正确计数
  int _lastComboMilestone = 0;  // 上次触发 Combo 的里程碑
  bool _showComboToast = false;
  int _comboCount = 0;          // 当前 Combo 计数 (用于显示)
  
  bool get showComboToast => _showComboToast;
  int get comboCount => _comboCount;

  @override
  List<ListenableServiceMixin> get listenableServices => [_sessionService];

  LearningSession? get session => _sessionService.currentSession;
  Word? get currentWord => _sessionService.currentWord;
  double get progress => _sessionService.progress;

  PetMood get currentMood {
    return PetMood.neutral; 
  }

  /// 确保启动时有一个有效的会话
  void init({List<Word>? words, String? source}) {
     if (words != null && words.isNotEmpty) {
       _sessionService.startSession(words, source: source ?? 'unknown');
     } else if (session == null) {
       _navigationService.back();
     }
  }

  /// 正确回答后调用 - 前进到下一个
  void onNext() async {
    _audioManager.playCorrect();
    
    // Combo 逻辑: 累计连续正确数
    _consecutiveCorrect++;
    
    // 检查是否达到新的 Combo 里程碑 (每 3 个)
    final currentMilestone = (_consecutiveCorrect / 3).floor();
    if (currentMilestone > _lastComboMilestone && _consecutiveCorrect >= 3) {
      _lastComboMilestone = currentMilestone;
      _comboCount = currentMilestone;
      _showComboToast = true;
      notifyListeners();
      
      // 自动隐藏 Toast
      Future.delayed(const Duration(milliseconds: 1500), () {
        _showComboToast = false;
        notifyListeners();
      });
    }
    
    await _sessionService.next();
    
    // 检查是否结束（展示摘要）
    if (_sessionService.currentSession?.currentStage == LearningStage.summary) {
       _showConfetti = true;
       _audioManager.playLevelUp();
       notifyListeners();
       
       // Handle Completion directly here instead of using SummaryView
       await _handleSessionCompletion();
    }
  }

  /// 错误回调 - 只记录错误统计
  void onError([String? reason]) {
    _audioManager.playWrong();
    _sessionService.reportError();
    // 重置连续正确计数 (错误打断 Combo)
    _consecutiveCorrect = 0;
  }

  /// 错误回调 - 记录错误并将单词加入队列末尾（错误重闯机制）
  void onErrorWithRequeue([String? reason]) {
    _audioManager.playWrong();
    _sessionService.reportError();
    _sessionService.requeueCurrentWord();
    // 重置连续正确计数 (错误打断 Combo)
    _consecutiveCorrect = 0;
  }

  void onExit() {
    _navigationService.back();
  }

  Future<void> _handleSessionCompletion() async {
    if (session == null) return;
    
    // 1. Prepare Data
    final totalWords = session!.batch.length;
    final errorIds = session!.errorWordIds;
    final mistakes = <Mistake>[];
    final allItems = <Mistake>[];

    for (var word in session!.batch) {
      final isCorrect = !errorIds.contains(word.id);
      
      final mistakeObj = Mistake(
        word: word.word, 
        studentInput: isCorrect ? word.word : '', // 学习模式下没有固定输入，正确默认填词，错误留空
        isCorrect: isCorrect,
        mode: DictationMode.smartReview, // 阶梯学习统一视为智能复习
        wordId: word.id,
        correctAnswer: word.word,
      );

      allItems.add(mistakeObj);
      if (!isCorrect) {
        mistakes.add(mistakeObj);
      }
    }

    final score = totalWords > 0 ? (((totalWords - mistakes.length) / totalWords) * 100).round() : 0;

    final result = SessionResult(
      sessionId: session!.id,
      score: score,
      total: totalWords,
      mistakes: mistakes,
      allItems: allItems,
      stats: {
        'total_SmartReview': totalWords
      }, 
    );

    final dictationSession = DictationSession(
      sessionId: session!.id,
      mode: DictationMode.smartReview, 
      date: DateTime.now().toIso8601String(),
      words: session!.batch,
    );

    // 2. Calculate Duration
    int? durationSeconds;
    if (session!.startTime != null) {
      final endTime = DateTime.now();
      durationSeconds = endTime.difference(session!.startTime!).inSeconds;
    }

    // 3. Save to DB
    await _dbService.saveSession(dictationSession, result, durationSeconds: durationSeconds);

    // 4. Calculate Points using PointsCalculator (SSOT)
    final pointsResult = PointsCalculator.calculate(
      totalWords: totalWords,
      errorCount: mistakes.length,
    );
    
    if (pointsResult.totalPoints > 0) {
      await _userService.addPoints(pointsResult.totalPoints);
    }

    await StreakRewards.maybeGrantGoldBonusForDate(
      dbService: _dbService,
      userService: _userService,
      date: DateTime.now(),
    );
    
    // Inject points info into result for display
    final resultWithPoints = SessionResult(
      sessionId: result.sessionId,
      score: result.score,
      total: result.total,
      mistakes: result.mistakes,
      allItems: result.allItems, // Ensure all items are passed
      stats: result.stats,
      basePoints: pointsResult.basePoints,
      comboBonus: pointsResult.comboBonus,
      pointsEarned: pointsResult.totalPoints,
      durationSeconds: durationSeconds,
    );

    // 5. Navigate to ResultView (reusing the common result view)
    _dictationService.setResult(resultWithPoints);
    
    // Delay slightly to let confetti play briefly?
    await Future.delayed(const Duration(milliseconds: 1500));
    _navigationService.replaceWithResultView(); // Replace to avoid going back to learning session
  }
}
