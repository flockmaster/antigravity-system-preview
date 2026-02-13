import '../../../app/app.locator.dart';
import '../../../core/base/baic_base_view_model.dart';
import '../../../core/services/database_service.dart';
import '../../../core/models/dictation_session.dart';
import '../main/main_view_model.dart'; // Import for GlobalEventBus

import '../../../core/utils/app_logger.dart';
import '../../../core/services/user_service.dart';
import '../../../core/utils/streak_rules.dart';
import '../../../core/utils/streak_rewards.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:confetti/confetti.dart';

class Reward {
  final int days;
  final String title;
  final String desc;
  final String iconType; // 'tv', 'gift', 'gamepad', 'ferris-wheel'
  final String color; // using hex strings like '#60A5FA'
  final bool claimed;

  Reward({
    required this.days,
    required this.title,
    required this.desc,
    required this.iconType,
    required this.color,
    required this.claimed,
  });
}

class DayAggregate {
  int totalWords = 0;
  final Map<DictationMode, int> wordsByMode = {};

  void add(DictationMode mode, int words) {
    totalWords += words;
    wordsByMode[mode] = (wordsByMode[mode] ?? 0) + words;
  }

  int wordsFor(DictationMode mode) => wordsByMode[mode] ?? 0;
}

class DayCellStatus {
  final String status; // gold, done, today, missed, future
  final bool isRetro;

  const DayCellStatus({
    required this.status,
    required this.isRetro,
  });
}

enum RetroCheckInResult {
  success,
  notEligible,
  tooOld,
  limitReached,
  insufficientPoints,
  alreadyCheckedIn,
  error,
}

class CalendarViewModel extends BaicBaseViewModel {
  final _dbService = locator<DatabaseService>();
  final _userService = locator<UserService>();
  
  // Confetti
  late ConfettiController confettiController; // UI Controller managed by VM for simplicity

  int _selectedTabIndex = 0; // 0: Check-in, 1: Wish Shop
  int get selectedTabIndex => _selectedTabIndex;
  
  DateTime _currentDate = DateTime.now();
  DateTime get currentDate => _currentDate;
  final Map<String, DayAggregate> _dayAggregates = {};
  final Set<String> _retroDates = {};
  
  int _streakDays = 0;
  int get streakDays => _streakDays;

  // Shop Items
  List<ShopItem> get shopItems => [
    ShopItem(
      id: '1',
      title: '看动画片',
      subtitle: '30分钟畅享时间',
      price: 150,
      iconData: LucideIcons.tv,
      imagePath: 'assets/images/shop_tv.png',
      color: 0xFF60A5FA, // blue-400
      gradientColors: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
    ),
    ShopItem(
      id: '2',
      title: '美味冰淇淋',
      subtitle: '兑换任意口味一个',
      price: 500,
      iconData: LucideIcons.iceCream2, 
      imagePath: 'assets/images/shop_ice_cream.png',
      color: 0xFFF472B6, // pink-400
      gradientColors: [Color(0xFFF472B6), Color(0xFFEC4899)],
    ),
    ShopItem(
      id: '3',
      title: '免做家务',
      subtitle: '一次家务豁免权',
      price: 1000,
      iconData: LucideIcons.shieldCheck,
      imagePath: 'assets/images/shop_housework.png',
      color: 0xFFA78BFA, // violet-400
      gradientColors: [Color(0xFFA78BFA), Color(0xFF8B5CF6)],
    ),
    ShopItem(
      id: '4',
      title: '周末游乐场',
      subtitle: '全家出游大奖',
      price: 5000,
      iconData: LucideIcons.ferrisWheel,
      imagePath: 'assets/images/shop_park.png',
      color: 0xFFFCD34D, // amber-300
      gradientColors: [Color(0xFFFCD34D), Color(0xFFF59E0B)],
    ),
  ];
  
  // Confirmed Reward for Ticket Display
  ShopItem? _redeemedItem;
  ShopItem? get redeemedItem => _redeemedItem;
  
  // Selected Streak Reward (for modal)
  Reward? _selectedReward;
  Reward? get selectedReward => _selectedReward;
  
  void setSelectedReward(Reward? reward) {
    _selectedReward = reward;
    notifyListeners();
  }

  // Current User Points
  int get userPoints => _userService.points;

  bool get isTodayGold {
    final todayKey = _formatDate(DateTime.now());
    return _isGoldStatus(todayKey);
  }



  Future<void> init() async {
    confettiController = ConfettiController(duration: const Duration(seconds: 3));
    await _fetchStats();
    _userService.addListener(notifyListeners);
    
    // Listen for shop open requests
    GlobalEventBus.listen((event) {
      if (event == 'open_shop_tab') {
        setTabIndex(1);
      }
    });
  }
  
  @override
  void dispose() {
    confettiController.dispose();
    _userService.removeListener(notifyListeners);
    super.dispose();
  }

  void setTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  // Redeem Logic
  Future<bool> redeemItem(ShopItem item) async {
    if (userPoints < item.price) return false;
    _redeemedItem = item;
    notifyListeners();
    return true; 
  }

  // Finalize Redemption
  Future<void> confirmRedemption() async {
    if (_redeemedItem != null) {
      final success = await _userService.consumePoints(_redeemedItem!.price);
      if (success) {
        confettiController.play();
        notifyListeners();
      }
    }
  }

  void clearRedemption() {
    _redeemedItem = null;
    notifyListeners();
  }

  Future<void> _fetchStats() async {
    final sessions = await _dbService.getSessionHistory();
    _dayAggregates.clear();
    _retroDates
      ..clear()
      ..addAll(await _dbService.getRetroCheckinDates());
    
    // 1. 提取所有打卡日期及其模式
    for (var session in sessions) {
      if (session['date'] != null) {
        try {
          final dateStr = session['date'] as String;
          final dateObj = DateTime.parse(dateStr);
          final dateKey = _formatDate(dateObj);
          
          final rawMode = session['mode'] as String?;
          final mode = parseDictationMode(rawMode);
          final totalWords = (session['total_words'] as int?) ?? 0;
          final aggregate = _dayAggregates.putIfAbsent(dateKey, () => DayAggregate());
          aggregate.add(mode, totalWords);
        } catch (e) {
          AppLogger.w('日期解析错误', error: e);
        }
      }
    }

    // 2. 计算连续打卡天数 (Streak)
    _calculateStreak();

    // 3. 发放今日金牌奖励（幂等）
    await _maybeGrantGoldBonusForToday();
    
    notifyListeners();
  }

  void _calculateStreak() {
    _streakDays = 0;
    DateTime checkDate = DateTime.now();
    // 检查今天是否因为还未打卡而应该从昨天算起？
    // 通常逻辑：如果今天打了， streak = 昨天streak + 1。
    // 如果今天没打，看昨天。如果昨天也没打，就是0。
    
    String todayKey = _formatDate(checkDate);
    // 只要是有效打卡或补签，就计入 Streak
    if (!_isDoneStatus(todayKey)) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (true) {
      String key = _formatDate(checkDate);
      if (_isDoneStatus(key)) {
        _streakDays++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
  }

  /// 判断指定日期是否达到“金牌打卡”标准 (A+B+C 全部完成)
  bool _isGoldStatus(String dateKey) {
    final aggregate = _dayAggregates[dateKey];
    if (aggregate == null) return false;
    final aCount = aggregate.wordsFor(DictationMode.modeA);
    final bCount = aggregate.wordsFor(DictationMode.modeB);
    final cCount = aggregate.wordsFor(DictationMode.modeC);
    final total = aCount + bCount + cCount;
    return aCount >= StreakRules.goldPerModeWordThreshold &&
           bCount >= StreakRules.goldPerModeWordThreshold &&
           cCount >= StreakRules.goldPerModeWordThreshold &&
           total >= StreakRules.goldTotalWordThreshold;
  }

  /// 判断指定日期是否为有效打卡
  bool _isValidCheckIn(String dateKey) {
    final aggregate = _dayAggregates[dateKey];
    if (aggregate == null) return false;
    return aggregate.totalWords >= StreakRules.validCheckinWordThreshold;
  }

  /// 判断指定日期是否为补签
  bool _isRetroStatus(String dateKey) {
    return _retroDates.contains(dateKey);
  }

  /// 判断指定日期是否为可计入连胜的完成状态
  bool _isDoneStatus(String dateKey) {
    return _isValidCheckIn(dateKey) || _isRetroStatus(dateKey);
  }

  String _formatDate(DateTime date) {
    return StreakRules.formatDateKey(date);
  }

  DateTime _normalizeDate(DateTime date) {
    return StreakRules.normalizeDate(date);
  }

  bool isWithinRetroRange(DateTime date) {
    final today = _normalizeDate(DateTime.now());
    final target = _normalizeDate(date);
    final earliest = today.subtract(const Duration(days: StreakRules.retroLookbackDays));
    return (target.isAtSameMomentAs(earliest) || target.isAfter(earliest)) && target.isBefore(today);
  }

  Future<RetroCheckInResult> retroCheckIn(DateTime date) async {
    final today = _normalizeDate(DateTime.now());
    final target = _normalizeDate(date);
    if (!target.isBefore(today)) return RetroCheckInResult.notEligible;

    final dateKey = _formatDate(target);
    if (_isDoneStatus(dateKey)) return RetroCheckInResult.alreadyCheckedIn;
    if (!isWithinRetroRange(target)) return RetroCheckInResult.tooOld;

    try {
      final monthCount = await _dbService.getRetroCheckinCountForMonth(DateTime.now());
      if (monthCount >= StreakRules.retroLimitPerMonth) return RetroCheckInResult.limitReached;

      final hasPoints = await _userService.consumePoints(StreakRules.retroCheckinCost);
      if (!hasPoints) return RetroCheckInResult.insufficientPoints;

      final inserted = await _dbService.insertRetroCheckin(dateKey, StreakRules.retroCheckinCost);
      if (!inserted) {
        await _userService.addPoints(StreakRules.retroCheckinCost);
        return RetroCheckInResult.alreadyCheckedIn;
      }

      _retroDates.add(dateKey);
      _calculateStreak();
      notifyListeners();
      return RetroCheckInResult.success;
    } catch (e) {
      AppLogger.w('补签失败', error: e);
      return RetroCheckInResult.error;
    }
  }

  Future<void> _maybeGrantGoldBonusForToday() async {
    await StreakRewards.maybeGrantGoldBonusForDate(
      dbService: _dbService,
      userService: _userService,
      date: DateTime.now(),
    );
  }



  List<Reward> get streakRewards => rewards;

  List<Reward> get rewards {
    // 根据连续打卡天数动态计算奖励是否解锁
    return [
      Reward(
        days: 3, 
        title: '📺 动画片特权', 
        desc: '凭此券可以向妈妈申请，在这个周末多看30分钟你最喜欢的动画片！',
        iconType: 'tv',
        color: '0xFF60A5FA', // blue-400
        claimed: _streakDays >= 3
      ),
      Reward(
        days: 7, 
        title: '🎁 盲盒兑换券', 
        desc: '哇！恭喜你！你可以拿着这个去找妈妈，兑换一个小盲盒或者零食！',
        iconType: 'gift',
        color: '0xFFF472B6', // pink-400
        claimed: _streakDays >= 7
      ),
      Reward(
        days: 14, 
        title: '🕹️ 爸爸带我抓娃娃', 
        desc: '这是一个大奖！让爸爸这个周末放下手机，带你去商场抓娃娃一次！',
        iconType: 'gamepad',
        color: '0xFF818CF8', // indigo-400
        claimed: _streakDays >= 14
      ),
      Reward(
        days: 21, 
        title: '🎡 全家游乐园', 
        desc: '终极大奖！如果你能坚持到这里，全家一起去游乐园或者动物园玩一天！',
        iconType: 'ferris-wheel',
        color: '0xFFFB923C', // orange-400
        claimed: _streakDays >= 21
      ),
    ];
  }

  Map<int, DayCellStatus> get daysStatus {
    Map<int, DayCellStatus> status = {};
    int daysInMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0).day;
    DateTime today = _normalizeDate(DateTime.now());
    
    for (int i = 1; i <= daysInMonth; i++) {
      DateTime date = DateTime(_currentDate.year, _currentDate.month, i);
      String dateKey = _formatDate(date);
      final isRetro = _isRetroStatus(dateKey);
      
      bool isToday = date.year == today.year && date.month == today.month && date.day == today.day;
      
      if (isToday) {
        if (_isGoldStatus(dateKey)) {
          status[i] = DayCellStatus(status: 'gold', isRetro: isRetro);
        } else if (_isDoneStatus(dateKey)) {
          status[i] = DayCellStatus(status: 'done', isRetro: isRetro);
        } else {
          status[i] = const DayCellStatus(status: 'today', isRetro: false);
        }
      } else if (date.isAfter(today)) {
        status[i] = const DayCellStatus(status: 'future', isRetro: false);
      } else {
        // 过去的日子
        if (_isGoldStatus(dateKey)) {
          status[i] = DayCellStatus(status: 'gold', isRetro: isRetro);
        } else if (_isDoneStatus(dateKey)) {
          status[i] = DayCellStatus(status: 'done', isRetro: isRetro);
        } else {
          status[i] = const DayCellStatus(status: 'missed', isRetro: false);
        }
      }
    }
    return status;
  }

  int get doneCount {
    // 统计当前展示月份的打卡总数
    int count = 0;
    int daysInMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0).day;
    for (int i = 1; i <= daysInMonth; i++) {
      String dateKey = _formatDate(DateTime(_currentDate.year, _currentDate.month, i));
      if (_isDoneStatus(dateKey)) {
        count++;
      }
    }
    return count;
  }

  void prevMonth() {
    _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
    notifyListeners();
  }

  void nextMonth() {
    _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
    notifyListeners();
  }
}

class ShopItem {
  final String id;
  final String title;
  final String subtitle;
  final int price;
  final IconData iconData;
  final String? imagePath;
  final int color;
  final List<Color> gradientColors;

  ShopItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.iconData,
    this.imagePath,
    required this.color,
    required this.gradientColors,
  });
}
