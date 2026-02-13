import '../../../../app/app.locator.dart';
import '../../../../core/base/baic_base_view_model.dart';
import '../../../../core/models/learning_model.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/models/dictation_session.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/utils/points_calculator.dart';
import '../../../../core/utils/streak_rewards.dart';

class SummaryViewModel extends BaicBaseViewModel {
  final _sessionService = locator<SessionService>();
  // ignore: unused_field
  final _dbService = locator<DatabaseService>();
  final _ttsService = locator<TtsService>();
  final _userService = locator<UserService>();

  LearningSession? get session => _sessionService.currentSession;

  int get totalWords => session?.batch.length ?? 0;
  int get errorCount => session?.errorWordIds.length ?? 0;
  int get correctCount => totalWords - errorCount;
  
  int get score => totalWords > 0 ? ((correctCount / totalWords) * 100).round() : 0;

  void onExit() {
    navigationService.back();
  }

  Future<void> init() async {
    // 1. Play audio feedback
    _playFeedback();

    // 2. Save Session to DB
    await _saveSession();
  }

  Future<void> _playFeedback() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (score >= 90) {
      _ttsService.speakChinese('太棒了，在此次挑战中你获得了$score分。继续保持！');
    } else if (score >= 60) {
      _ttsService.speakChinese('不错，完成了挑战，得分$score分。加油！');
    } else {
      _ttsService.speakChinese('挑战完成。得分$score分。别灰心，继续努力！');
    }
  }

  Future<void> _saveSession() async {
    if (session == null) return;
    
    // Check if we should ignore saving (e.g. if already saved). 
    // Currently SessionService doesn't mark 'saved', so we might duplicate if visiting summary twice.
    // For MVP, we assume init is called once per session completion view.
    
    final mistakes = <Mistake>[];
    for (var wordId in session!.errorWordIds) {
      final word = session!.batch.firstWhere((w) => w.id == wordId, orElse: () => session!.batch.first);
      mistakes.add(Mistake(
        word: word.word, 
        studentInput: '', // No specific input recorded for Recall mode yet
        isCorrect: false,
        mode: DictationMode.smartReview, // Assuming Smart Review or generic
      ));
    }

    final result = SessionResult(
      sessionId: session!.id,
      score: score,
      total: totalWords,
      mistakes: mistakes,
      stats: {}, 
    );

    final dictationSession = DictationSession(
      sessionId: session!.id,
      mode: DictationMode.smartReview, 
      date: DateTime.now().toIso8601String(),
      words: session!.batch,
    );

    // 计算完成时长(秒)
    int? durationSeconds;
    if (session!.startTime != null) {
      final endTime = DateTime.now();
      durationSeconds = endTime.difference(session!.startTime!).inSeconds;
    }

    await _dbService.saveSession(dictationSession, result, durationSeconds: durationSeconds);
    
    // --- 积分奖励逻辑 (SSOT: PointsCalculator) ---
    final pointsResult = PointsCalculator.calculate(
      totalWords: totalWords,
      errorCount: mistakes.length,
    );
    if (pointsResult.totalPoints > 0) {
      await _userService.addPoints(pointsResult.totalPoints);
    }
    // ------------------

    await StreakRewards.maybeGrantGoldBonusForDate(
      dbService: _dbService,
      userService: _userService,
      date: DateTime.now(),
    );

    // Optional: Clear session from memory so we don't save again? 
    // Or let user exit.
  }
}
