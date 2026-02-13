import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/services/database_service.dart';
import '../../../core/models/word.dart';
import '../../../core/services/dictation_service.dart';
import '../../../core/models/dictation_session.dart';
import '../../../core/services/tts_service.dart';

class SmartReviewViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _dbService = locator<DatabaseService>();
  final _dictationService = locator<DictationService>();
  final _ttsService = locator<TtsService>();

  // 使用单一统一的“智能计划”列表
  List<Word> _smartPlan = [];
  List<Word> get smartPlan => _smartPlan;

  bool get isEmpty => _smartPlan.isEmpty;

  // 推荐理由逻辑
  String getRecommendationReason(Word word) {
    if (!word.isMastered) {
      if (word.wrongCount > 0) return '消灭错题'; 
      return '新单词'; 
    }
    
    // 复习类 (已毕业单词)
    if (word.lastReviewedAt != null) {
      final days = DateTime.now().difference(word.lastReviewedAt!).inDays;
      if (days >= 7) return '唤醒记忆'; // >7天未复习
      if (days >= 3) return '记忆周期'; // >3天 (遗忘曲线关键点)
    }
    
    if (word.wrongCount > 2) return '高频易错'; 
    
    // 兜底
    return '智能加固'; 
  }

  @override
  List<ListenableServiceMixin> get listenableServices => [_dbService];

  Future<void> init() async {
    setBusy(true);
    // 使用新算法获取推荐单词 (20个/组：含最多10个新词)
    _smartPlan = await _dbService.getSmartReviewWords(limit: 20);
    setBusy(false);
  }

  void navigateBack() {
    _navigationService.back();
  }

  /// 播放单词发音
  void speakWord(Word word) {
    _ttsService.speakEnglish(word.word);
  }

  Future<void> startDictationSession() async {
    if (isEmpty) return;
    
    // 使用智能计划开始混合会话
    // 根据要求，复用现有的听写视图/服务逻辑
    _dictationService.startMixedSession(
      _smartPlan,
      specificMode: DictationMode.smartReview,
    );
    _navigationService.navigateToDictationView();
  }

  Future<void> startLearningSession() async {
    if (isEmpty) return;
    
    // 跳转到循序渐进的学习会话（阶梯模式）
    await _navigationService.navigateToLearningSessionView(
      words: _smartPlan, 
      source: 'smart_review',
    );
  }

  Future<void> startFlashSession() async {
     // 遗留别名，重定向到学习会话或保留旧抽认卡？
     // 用户要求：“更新为导航到新的循序渐进学习模式”
     await startLearningSession();
  }
}
