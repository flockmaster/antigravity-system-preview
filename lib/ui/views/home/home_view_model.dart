import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';

import '../../../core/services/database_service.dart';
import '../../../core/services/dictation_service.dart';
import '../../../core/models/dictation_session.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/services/user_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

/// 首页视图模型
/// 
/// 负责管理首页的状态，包括错题统计、词库统计以及最近听写记录的加载。
class HomeViewModel extends ReactiveViewModel {
  final _dbService = locator<DatabaseService>();
  final _userService = locator<UserService>();
  final _navigationService = locator<NavigationService>();

  @override
  List<ListenableServiceMixin> get listenableServices => [_dbService, _userService];

  String get nickname => _userService.nickname;
  int get points => _userService.points;


  int _mistakeCount = 0;
  /// 错题本中的单词总数
  int get mistakeCount => _mistakeCount;

  int _vocabularyCount = 0;
  /// 词库中的单词总数
  int get vocabularyCount => _vocabularyCount;

  int _reviewCount = 0;
  /// 需要复习的单词数 (智能复习)
  int get reviewCount => _reviewCount;

  int _todayMasteredCount = 0;
  /// 今日新掌握的单词数
  int get todayMasteredCount => _todayMasteredCount;

  List<Map<String, dynamic>> _recentSessions = [];
  List<Map<String, dynamic>> get recentSessions => _recentSessions;


  /// 初始化首页数据
  Future<void> init() async {
    setBusy(true);
    // 监听数据库变更以自动刷新统计数据
    _dbService.addListener(_onDbChanged);
    await _userService.init();
    await refreshData();
    setBusy(false);
  }


  void _onDbChanged() {
    refreshData();
  }

  @override
  void dispose() {
    _dbService.removeListener(_onDbChanged);
    super.dispose();
  }

  /// 刷新统计数据和历史记录
  Future<void> refreshData() async {
    // 获取有错误的单词
    final mistakenWords = await _dbService.getMistakenWords();
    _mistakeCount = mistakenWords.length;

    // 获取所有单词
    final allWords = await _dbService.getAllWords();
    _vocabularyCount = allWords.length;
    
    // 计算掌握度分布 (Removed A/B/C)

    // 计算智能复习与今日成就

    // 计算智能复习与今日成就
    // 使用与 SmartReviewView 相同的算法获取推荐词数
    final smartReviewWords = await _dbService.getSmartReviewWords(limit: 20);
    _reviewCount = smartReviewWords.length;
    
    
    // 计算今日新学会的单词数
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day); // 今日零点
    final tomorrow = today.add(const Duration(days: 1)); // 明日零点
    
    _todayMasteredCount = allWords.where((w) {
      if (w.firstMasteredAt == null) return false;
      // 检查 firstMasteredAt 是否在今天的范围内 [today, tomorrow)
      return w.firstMasteredAt!.isAfter(today.subtract(const Duration(seconds: 1))) && 
             w.firstMasteredAt!.isBefore(tomorrow);
    }).length;

    // 获取会话历史 (取最近 5 条)
    final history = await _dbService.getSessionHistory();
    _recentSessions = List<Map<String, dynamic>>.from(history).take(5).toList();
    
    notifyListeners();
  }

  /// 跳转到拍照扫描页面
  void navigateToScanBook() {
    _navigationService.navigateToScanBookView();
  }

  /// 跳转到粘贴文本页面 (TODO: 实现此页面)
  /// 跳转到粘贴文本页面
  void navigateToPasteText() {
    _navigationService.navigateToTextInputView();
  }

  /// 跳转到错题本页面
  void navigateToReviewMistakes() {
    _navigationService.navigateToMistakeBookView(); 
  }

  /// 跳转到我的词库页面
  /// 跳转到我的词库页面
  void navigateToReviewVocabulary() {
    _navigationService.navigateToLibraryView();
  }

  /// 跳转到智能复习页面
  void navigateToSmartReview() {
    _navigationService.navigateToSmartReviewView();
  }

  /// 查看历史记录详情
  Future<void> viewSessionHistory(Map<String, dynamic> sessionData) async {
    setBusy(true);
    try {
      final sessionId = sessionData['session_id'];
      if (sessionId == null) return;

      final allItems = await _dbService.getSessionItems(sessionId);
      final mistakes = allItems.where((item) => !item.isCorrect).toList();
      
      final result = SessionResult(
        sessionId: sessionId,
        score: sessionData['score'] as int? ?? 0,
        total: sessionData['total_words'] as int? ?? 0,
        mistakes: mistakes,
        allItems: allItems,
      );
      
      final dictationService = locator<DictationService>();
      dictationService.setResult(result);
      
      _navigationService.navigateToResultView();
    } catch (e) {
      // 静默处理错误或显示提示
      AppLogger.e('加载历史记录错误', error: e);
    } finally {
      setBusy(false);
    }
  }


  /// 跳转到日历进度页面 (TODO: 实现此页面)
  void navigateToCalendar() {
    // TODO: 建立日历视图
  }

  /// 跳转到 TTS 设置页面
  Future<void> navigateToPersonalCenter() async {
    await _navigationService.navigateToPersonalCenterView();
    // 刷新数据，以防用户更改了昵称或影响首页的其他设置
    refreshData();
  }
}

